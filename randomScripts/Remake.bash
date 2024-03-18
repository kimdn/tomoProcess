#!/bin/bash

export IMOD_DIR=/msc/krios/imod_4.9.12/

#Recreate the .rawtlt and .st files in each tilt series subdirectory in AlignedStacks

home=$(pwd)
dir=AlignedStacks

for entry in $dir/*/
do

name=$(basename $entry)
echo $name
cd $dir/$name/

rm *.rawtlt
sort -n *.list | cut -f1 > $name".rawtlt"

rm *.st
/msc/krios/imod_4.9.12/bin/newstack -filei *.sorted -tilt *.rawtlt -ou ${name}.st

cd $home

done


