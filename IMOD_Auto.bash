#!/bin/bash

start_time=$(date +%s)

export IMOD_DIR=/opt/apps/imod/imod_4.11.12/

home=$(pwd)
dir=AlignedStacks
yaml="metadata-tomo.yaml"
topazModel=$(cat $yaml | grep topaz_model | awk '{print $2}')
topazDir="denoised"_$topazModel

#For every subdirectory within /AlignedStacks/, run batchruntomo
#Batchruntomo makes another subdirectory within each tilt directory 
#with the same name containing etomo files and output

for entry in $dir/*
do
	tiltName=${entry#*/}
	echo $tiltName

	if [[ "$topazModel" == "NA" ]]
	then
       		target=$dir/$tiltName
	else
		target=$dir/$tiltName/$topazDir
	fi
#Checks for a .skip file containing a comma separated list of tilts to skip, if found, appends the cryoDirective.adoc with skip list	
	if [ -f $dir/$tiltName/${tiltName}.skip ] ;
	then 
		echo "Skipping views in $tiltName..."
		skipList=$(cat $dir/$tiltName/${tiltName}.skip)
		sed -i "s/^setupset.copyarg.skip =.*/setupset.copyarg.skip =${skipList}/" cryoDirective.adoc

	else
		echo "Not skipping any tilts for $tiltName..."
		sed -i "s/^setupset.copyarg.skip =.*/setupset.copyarg.skip =/" cryoDirective.adoc
	fi
#Checks if an imod directory exists already exists for this tilt series, if it doesn't, run batchruntomo
	if [ -d $target/$tiltName ] ;
	then
		echo "IMOD has already been run in "$target/$tiltName/", skipping..."
	else
		batchruntomo -di cryoDirective.adoc -ro $tiltName -cu $target -m -g 1 > $target/${tiltName}_log.out 
		cp $target/$tiltName/*.st $target
		cp $target/$tiltName/*.rawtlt $target
	fi
done

end_time=$(date +%s)
echo "It took $(($end_time - $start_time)) seconds to complete this job..."

