#!/bin/bash
SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)
IMAGES_TXT=$SHELL_FOLDER/images.txt
SOURCEFILES_TXT=$SHELL_FOLDER/sourcefiles.txt
MATCHEDIMAGES_TXT=$SHELL_FOLDER/matchedImages.txt

function fetch_images(){
    for x in `ls $1|grep '.bundle'`
	do
	    for t in `ls ./$x|grep -E ".png|.jpg|.jpeg|.pdf"`
	        do
		    if [ -f $IMAGES_TXT ];then
                        echo "$(pwd)/$x/$t" >> $IMAGES_TXT
                    else
                        touch $IMAGES_TXT
                        echo "$(pwd)/$x/$t" >> $IMAGES_TXT
                    fi 
                done
       done
}

function fetch_sourcefiles(){
    for x in `ls $1| grep -v -E ".framework|.xcodeproj|.sh|UITests|.bundle"`
        do  
  	    if [ -d $x ];
	    then
                cd $x;
		fetch_sourcefiles "$(pwd)";
                cd ..
            else
                if [ "${x##*.}"q = "m"q ]||[ "${x##*.}"q = "mm"q ];then
		    if [ -f $SOURCEFILES_TXT ];then
                        echo "$(pwd)/$x" >> $SOURCEFILES_TXT
                    else
                        touch $SOURCEFILES_TXT
                        echo "$(pwd)/$x" >> $SOURCEFILES_TXT
                    fi
		fi
            fi
        done
}

function fetch_unused_images(){
    if [ -f $IMAGES_TXT ]&&[ -f $SOURCEFILES_TXT ];then
        for x in `cat $IMAGES_TXT`
	    do
                temp=${x##*/}
                imagename=${temp%.*}
                matched=0
                for t in `cat $SOURCEFILES_TXT`
                    do
                        ff="@\\\"$imagename\\\""
                        if [ `grep -c $ff $t` -eq 0 ];then
                            continue;
                        else
                            matched=1;
                            break;
                        fi
                    done
                if [ $matched == 0 ];then
	            if [ -f $MATCHEDIMAGES_TXT ];then
                        echo $x >> $MATCHEDIMAGES_TXT
                    else
                        touch $MATCHEDIMAGES_TXT
                        echo $x >> $MATCHEDIMAGES_TXT
                    fi
                fi
        done
    fi
}

function clear_txt(){
    if [ -f $SOURCEFILES_TXT ];then
	rm -f $SOURCEFILES_TXT
    fi

    if [ -f $IMAGES_TXT ];then
	rm -f $IMAGES_TXT;
    fi
}

fetch_images "./"
fetch_sourcefiles "./"
fetch_unused_images
clear_txt
