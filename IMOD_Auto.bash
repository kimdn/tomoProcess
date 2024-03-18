#!/bin/bash

start_time=$(date +%s)

export IMOD_DIR=/opt/apps/imod/imod_4.11.12/

home=$(pwd)
dir=AlignedStacks

#For every subdirectory within /AlignedStacks/, run batchruntomo
#Batchruntomo makes another subdirectory within each tilt directory 
#with the same name containing etomo files and output

for entry in $dir/*/
do

name=$(basename $entry)
echo $name
/opt/apps/imod/imod_4.11.12/bin/batchruntomo -di cryoDirective.adoc -ro $name -cu $dir/$name/ -m -g 1 
cp $dir/$name/$name/*.st $dir/$name


done > out.log

end_time=$(date +%s)
echo "It took $(($end_time - $start_time)) seconds to complete this job..."

