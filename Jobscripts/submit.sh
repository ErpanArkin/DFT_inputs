#!/bin/bash


# $ ssh r1e1cn01

# wd=`pwd`
# cmd='cd '$wd'; qsub '$1
# ssh r1e1cn01 $cmd


print_help() {
	PROGNAME=$(basename $0)

	echo "Usage: $PROGNAME files"
	echo "  make qsub with each file in its containing directory"
}

done_script() {
	echo "ERROR: you do not specify any script to process" 1>&2
	exit 1
}


process() {
	WD=$PWD
	COUNTER=0


	for file in "$@"; do
		if [ -f "$file" ]; then
			((COUNTER++))

			BDIR=$(dirname "$file")
			BNAME=$(basename "$file")
			
			# change to containing directory
			cd "$BDIR"
			
			echo -n "[$COUNTER] submitting $file ... "
			
			# submit
			PCMD=$( sbatch "$BNAME" )

			# check for success
			if [ $? -eq 0 ] ; then
				echo "[OK] [$PCMD]"
			else
				echo "[ERROR]"
			fi

			# return to starting directory
			cd "$WD"
		else
			echo "file does not exist: $file" 1>&2
		fi
	done
}


if [ -z $1 ]; then
	done_script
fi

case $1 in
	"-h" | "--help" )
		print_help
		;;
	* )
		process "$@"
		;;
esac


