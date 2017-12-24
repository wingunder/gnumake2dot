BASE_DIR ?= .
basedirINFILE = $(shell dirname $(INFILE))

all: $(OUTFILE)

# Get GNU Make to print its "data base".
# NOTE: There is no way to get meta data from GNU Make.
tmp.deps: $(INFILE)
	@$(MAKE) --no-print-directory -s -n -p -f $< >$@ || true

# Filter out all the lines that:
# - are concatinated with \ newline.
# - exist before the line containing /^# Files$/.
tmp.filter0: tmp.deps
	@sed -e :a -e '/\\$$/N; s/\\\n/ /; ta' -e '1,/^# Files$$/d' $< >$@

# Filter out all the lines that contain, and are followed by /# Not a target$/.
tmp.filter1: tmp.filter0
	@awk 'BEGIN { i=0; } /# Not a target$$/ {i=1;next}; !/# Not a target$$/ { if (i==0) {print $0} else {i=0} };' $< >$@

# Filter out all the lines that start with a hash, space or tab.
tmp.filter2: tmp.filter1
	@grep -vP '^[\s\t\#]' $< >$@

# Filter out all the lines that:
# - contain wildcards (%).
# -	have equations
# - have GNU Make built-in targets
tmp.filter3: tmp.filter2
	@grep \
-ve '%' \
-ve ^make\\[ \
-ve '[^\ ]\+\ *[:\?\+]\?\=' \
-wve '^\.DEFAULT:\|^\.DELETE_ON_ERROR:\|^\.EXPORT_ALL_VARIABLES:\|^\.IGNORE:\|^\.INTERMEDIATE:\|^\.LOW_RESOLUTION_TIME:\|^\.NOTPARALLEL:\|^\.ONESHELL:\|^\.PHONY:\|^\.POSIX:\|^\.PRECIOUS:\|^\.SECONDARY:\|^\.SECONDEXPANSION:\|^\.SILENT:\|^\.SUFFIXES:' \
$< >$@

# Finally filter the 'dependency' lines.
tmp.filter4: tmp.filter3
	@grep -e '.\+:\ *.\+' $< >$@

# Generate the output file.
$(OUTFILE): tmp.filter4
@awk -F':' -v DIR="$(basedirINFILE)" -f $(BASE_DIR)/GNUMake2dot.awk $< >$@

clean:
	@rm -f tmp.filter[01234] tmp.deps
