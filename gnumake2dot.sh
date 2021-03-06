#!/bin/sh

usage() {
(>&2 echo "\
Usage: ${0##*/} [-h] [-k] [-o OUTFILE] [--] [INFILE]
Generate a dot file from a supplied, valid GNU Makefile, INFILE.
If INFILE is not supplied, STDIN is taken as input.

The output either gets written to STDOUT if '-' is supplied an OUTFILE,
or if the -o switch is omitted. and write the result to standard output.
With no INFILE or when INFILE is -, read standard input.

	-h|-?      Write help information to STDOUT.
	-k         Keep intermediate files.
	-n         Just print the commands. No execution.
	-o OUTFILE Write the result to OUTFILE instead of STDOUT.

eg: All the following, does exactly the same thing.
	# ${0##*/} /tmp/hiredis/Makefile >deps.dot
	# ${0##*/} -- /tmp/hiredis/Makefile >deps.dot
	# ${0##*/} -o deps.dot /tmp/hiredis/Makefile
	# ${0##*/} -o deps.dot -- /tmp/hiredis/Makefile

eg: Generate a png of the hiredis' Makefile dependencies.
	# ${0##*/} /tmp/hiredis/Makefile | dot -Tpng -o deps.png
")
}

OPTIND=1
outfile=""
keepIntermediate=0
switches=""
while getopts h?kno: o; do
	case "$o" in
		h|\?)
			usage
			exit 0
			;;
		o)  outfile=$OPTARG
			;;
		k)  keepIntermediate=1
			;;
		n)  switches=$switches " -n"
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

BASE_DIR=$PWD/`dirname ${0}`
keepDotFile=1
if [ "$outfile" = "" ]
then
	keepDotFile=0
	outfile=$$.dot
fi

BASE_DIR=$BASE_DIR \
INFILE=`realpath $infile` \
OUTFILE=$outfile \
make $switches -f $BASE_DIR/Makefile all

if [ "$noExecution" = "" ]
then
	if [ $keepDotFile -eq 0 ]
	then
		cat $BASE_DIR/$$.dot
		rm -f $BASE_DIR/$$.dot
	fi
	if [ $keepIntermediate -eq 0 ]
	then
		BASE_DIR=$BASE_DIR make -f $BASE_DIR/Makefile clean
	fi
fi
