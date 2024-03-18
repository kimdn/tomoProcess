#!/bin/bash
#converts all .mrc files in a directory to jpegs using Imods mrc2tif program



for i in *.mrc
do

name=$i
basename=${i%_*}
outname="${basename}.jpg"

mrc2tif -j -a 0 $name $outname

done




