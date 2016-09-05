#!/bin/sh

. ./settings

ignoredKeys=`(ls $IGNORED_KEYS_FILE | while read file; do cat $file; done;)`
messageFiles=`find $MESSAGE_PROPERTIES_ROOT_DIR -name $MESSAGE_PROPERTIES_FILE_PATTERN`

for messageFile in $messageFiles; do

    echo "---- Inspecting file $messageFile"

    lines=`(ls $messageFile | while read file; do cat $file; done;) | sed '/_/d' | sed 's/#.*//' | sed 's/=.*//' | sed 's/ //' | egrep -v "^$" | sort -u`
    for line in $lines; do

        # Ignore
        for ignoredKey in $ignoredKeys; do
            line=$(echo $line | sed "/$ignoredKey/d")
        done;

        if [ ! "$line" ];then
           continue
        fi

        found=false
        for file in `find $SRC_PROPERTIES_ROOT_DIR -name *.jsp -or -name *.js -or -name *.java`; do
            grep $line $file >/dev/null
            if [ $? = "0" ]; then
                found=true
                continue
            fi
        done;
        if [ $found = false ]; then
            echo $line
        fi
    done;
done;