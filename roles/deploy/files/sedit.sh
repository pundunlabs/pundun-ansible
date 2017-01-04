#!/bin/bash
# spec : sedit.sh <environment> <property> <new value> <file.yml>

case ${#} in [!3] ) 
    echo "usage: sedit.sh <parameter> <new value> <file.yml>" 1>&2
    exit 1 
    ;; 
esac

IFS='.'
read -r -a array <<< "$1"
IFS=
len="${#array[@]}"

pattern="/^params/,/^$/ {"
close="}"
for (( i=0; i<$len-1; i++ ))
do
    pattern=$pattern"
/"${array[i]}"/,/^$/ {"
    close=$close"
}"
done

param="${array[i]}"
new=$(sed 's/[\/&]/\\&/g' <<< "$2")
file=`readlink "$3"`
if [ "${file}" == "" ]
then
    file="$3"
fi

bakfile="${file}".bak
grep -v '^$' $file > $bakfile
sed ''"$pattern"'
    0,/'"${param}"'/ {
	s/\('"${param}"'.*:\)\([^,^}]*\)\(.*$\)/\1'" ${new}"'\3/
    }
'"$close"'
' "$bakfile" > "$file"
rm "$bakfile"
