cat $1 | cut -d, -f2- | sed 's/,/\n/g' | sort -u