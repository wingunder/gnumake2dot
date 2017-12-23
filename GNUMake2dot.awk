#!/usr/bin/awk -f

BEGIN {
	print "digraph \"MakefileDeps\" {"
}

{
	fromFile=$1
	split($2,deps," ");
	for (i in deps) {
		print "\"" fromFile "\" -> \"" deps[i] "\";";
	}
}

END {
	print "}"
}
