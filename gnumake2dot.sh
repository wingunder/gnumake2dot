#!/bin/sh

usage() {
(>&2 echo "\
Usage: ${0##*/} [-h] [-o OUTFILE] [--] [INFILE]
Generate a dot file from a supplied, valid GNU Makefile, INFILE.
If INFILE is not supplied, STDIN is taken as input.

The output either gets written to STDOUT if '-' is supplied an OUTFILE,
or if the -o switch is omitted. and write the result to standard output.
With no INFILE or when INFILE is -, read standard input.

	-h|-?      display this help and exit
	-o OUTFILE write the result to OUTFILE instead of STDOUT.

eg: All the following, does exactly the same thing.
	# ${0##*/} /usr/src/linux/Makefile >linux_make_deps.dot
	# ${0##*/} -- /usr/src/linux/Makefile >linux_make_deps.dot
	# ${0##*/} -o linux_make_deps.dot /usr/src/linux/Makefile
	# ${0##*/} -o linux_make_deps.dot -- /usr/src/linux/Makefile

eg: Make a png of the Linux kernel's Makefile dependencies.
	# ${0##*/} /usr/src/linux/Makefile | dot -Tpng -o linux_make_deps.png
")
}

OPTIND=1
outfile=""
while getopts h?vo: o; do
	case "$o" in
		h|\?)
			usage
			exit 0
			;;
		o)  outfile=$OPTARG
			;;
		*)
			usage >&2
			exit 1
			;;
	esac
done
shift "$((OPTIND-1))"

if [ "$1" = "" ] || [ "$1" = "-" ] || [ ! -f $1 ]
then
	(>&2 echo "ERROR: '$1' is not a file.")
	usage
	exit 1
else
	infile=$1
fi

if [ "$outfile" = "" ]
then
	gnumake2dot_HOME=$PWD/`dirname ${0}`
	gnumake2dot_HOME=$gnumake2dot_HOME \
INFILE=`realpath $infile` \
OUTFILE=$gnumake2dot_HOME/$$.dot \
make -f $gnumake2dot_HOME/Makefile all && \
cat $gnumake2dot_HOME/$$.dot && \
gnumake2dot_HOME=$gnumake2dot_HOME \
make -f $gnumake2dot_HOME/Makefile clean && \
rm -f $gnumake2dot_HOME/$$.dot
else
	INFILE=$infile OUTFILE=$outfile make all clean
fi
