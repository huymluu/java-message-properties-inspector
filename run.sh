#!/bin/sh

. ./settings

# Output
mkdir -p $RESULTS_ROOT_DIR
resultFile=$RESULTS_ROOT_DIR`date +%Y%m%d_%H%M%S`".out"
exec 3>&1 1>>${resultFile} 2>&1

ignoredKeys=`(ls $IGNORED_KEYS_FILE | while read file; do cat $file; done;)`
messageFiles=`find $MESSAGE_PROPERTIES_ROOT_DIR -name $MESSAGE_PROPERTIES_FILE_PATTERN`

echo "======== BEGIN ========" | tee /dev/fd/3

for messageFile in $messageFiles; do

    echo "---- Inspecting file $messageFile" | tee /dev/fd/3

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
            echo $line | tee /dev/fd/3
        fi
    done;
done;

echo "======== END ========" | tee /dev/fd/3