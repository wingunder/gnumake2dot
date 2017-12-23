gnumake2dot_HOME ?= .
basedirINFILE = $(shell dirname $(INFILE))

all: $(OUTFILE)

$(OUTFILE): $(gnumake2dot_HOME)/tmp.filter3
	@awk -F':' -v DIR="$(basedirINFILE)" -f $(gnumake2dot_HOME)/GNUMake2dot.awk $< >$@

$(gnumake2dot_HOME)/tmp.deps: $(INFILE)
	@$(MAKE) --no-print-directory -s -n -p -f $< >$@ || true

$(gnumake2dot_HOME)/tmp.filter0: $(gnumake2dot_HOME)/tmp.deps
	@sed -e :a -e '/\\$$/N; s/\\\n/ /; ta' -e '1,/# Implicit Rules/d' $< >$@

$(gnumake2dot_HOME)/tmp.filter1: $(gnumake2dot_HOME)/tmp.filter0
	@grep -vP '^[\t\#]' $< >$@

$(gnumake2dot_HOME)/tmp.filter2: $(gnumake2dot_HOME)/tmp.filter1
	@grep \
-ve '%' \
-ve ^make\\[ \
-ve ^\.PHONY \
-ve ^\.SUFFIXES \
-ve ^\.DEFAULT \
-ve ^\.PRECIOUS \
-ve ^\.INTERMEDIATE \
-ve ^\.SECONDARY \
-ve ^\.SECONDEXPANSION \
-ve ^\.DELETE_ON_ERROR \
-ve ^\.IGNORE \
-ve ^\.LOW_RESOLUTION_TIME \
-ve ^\.SILENT \
-ve ^\.EXPORT_ALL_VARIABLES \
-ve ^\.NOTPARALLEL \
-ve ^\.ONESHELL \
-ve ^\.POSIX \
$< >$@

$(gnumake2dot_HOME)/tmp.filter3: $(gnumake2dot_HOME)/tmp.filter2
	@grep -e '.\+: .\+' $< >$@

clean:
	@rm -f $(gnumake2dot_HOME)/tmp.filter[0123] $(gnumake2dot_HOME)/tmp.deps
