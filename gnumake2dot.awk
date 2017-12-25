#!/usr/bin/awk -f

BEGIN {
	print "digraph \"MakefileDeps\" {"
}

{
	fromFile=$1;
	split($2,deps," ");
	orderFlag=0;
	for (i in deps) {
		if (deps[i] != "|") {
			shape="";
			if (orderFlag == 1) {
				print "\"" deps[i] "\" [shape=box];";
			}
			print "\"" fromFile "\" -> \"" deps[i] "\";";
		}
		else {
			orderFlag=1;
		}
	}
}

END {
	print "}"
}
