#!/bin/bash

home=$(pwd)
targetdir=emClarity/fixedStacks/
dir=AlignedStacks

for entry in $dir/*/
do

name=$(basename $entry)
echo "Moving Data for $name"
dataLoc=$entry$name

alterheader $dataLoc/$name".st" $dataLoc/$name".st" -del 1.1,1.1,1.1

xfFile=$dataLoc/$name"_fid.xf"
tltFile=$dataLoc/$name"_fid.tlt"
stFile=$dataLoc/$name".st"

cp $xfFile $targetdir$name".xf"
cp $tltFile $targetdir$name".tlt"
cp $stFile $targetdir$name".fixed"

done

