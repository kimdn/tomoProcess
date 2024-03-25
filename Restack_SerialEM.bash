#!/bin/bash

start_time=$(date +%s)
export IMOD_DIR=/opt/apps/imod/imod_4.11.12/

yaml="metadata-tomo.yaml"
topazModel=$(cat $yaml | grep topaz_model | awk '{print $2}')
topazDir="denoised"_$topazModel

home=`pwd`
mkdir -p AlignedStacks
for st in stacks/*.mdoc ; do
	dir=${st%%.*}
	tiltName=${dir#*/}
	pathfile=$tiltName"_path.list"
	listfile=$tiltName".list"
	rawtilt=$tiltName".rawtlt"

	mkdir -p AlignedStacks/$tiltName

	if [[ "$topazModel" == "NA" ]]
	then
		target=AlignedStacks/$tiltName
		subFrames=SumFrames
	else
		target=AlignedStacks/$tiltName/$topazDir
		subFrames=SumFrames/$topazDir
	fi

	if [ -d "$target" ] && [ -f "$target/${tiltName}.sorted" ]; then
		echo "Restacking has already been run on "$tiltName", skipping..."
	else
		mkdir -p $target
		cat $st | grep SubFramePath | awk -F':' '{print $2}' | sed 's/\\/\//g' | sed "s/\r//g" > $target/${tiltName}_path.list

		Z=1
		#read each line of <$pathfile, get only file name, and transfer to new subdirectory
		while read -r Line; do
			noPath="${Line##*/}"
			noSuf=${noPath%.*}
			suf="${noPath##*.}"
			echo $noSuf

			#get the angle corresponding to each image
			#grep the TiltAngle entry for each image
			#cut removes "TiltAngle =" before angle value
			#sed removes carrige return
			ang=`cat $st | grep -B25 $noPath | grep TiltAngle | cut -d= -f2 | sed "s/\r//g" `

			#creates listfile that newstack will read to order images by tilt angle
			printf "%3.4f\t%40s\n" $ang "${tiltName}-${Z}.mrc" >> $target/${tiltName}.list
			echo $Z $ang

			#Target directory to copy frames from
			newline="$home/$subFrames/${noSuf}_sumavg.mrc"
			#Target location for individual frames corresponding to stack z number
			newname="$target/${tiltName}-${Z}.mrc"

			#copy motioncorrected images in /SumFrames/ to corresponding tilt series directory
			cp $newline $newname
			((Z++))
			done <$target/${tiltName}_path.list
		((Z--))

		#convert .mrc files into .st for imod order rawtilt file#
		cd $target
		#read angles and image names in listfile and sort from - to +, write to _ordered.temp
		sort -n ${tiltName}.list | awk '{printf $2"\n"}' > ${tiltName}_ordered.temp
		#determine the number of images in each stack (list file must begin with this number)
		num=$(ls *.mrc | wc -l)
		echo $num > ${tiltName}.sorted

		#Add file names to sorted file separated by zeros corresponding to their correct sorted order (- to +)
		for i in $(seq 1 $num); do
			name=$(head -n$i ${tiltName}_ordered.temp | tail -1)
			echo $name
			echo 0
			done >> ${tiltName}.sorted
		#Pull tilt angles from list file and create rawtilt file needed by Imod
		sort -n ${tiltName}.list | cut -f1 > ${tiltName}.rawtlt

		#Call imods newstack to stack each set of images into a .st file from - to +
		newstack -filei ${tiltName}.sorted -tilt *.rawtlt -ou ${tiltName}.st

		#Cleanup and reset for next tilt series
		rm ${tiltName}_ordered.temp
		rm ${tiltName}_path.list
		cd $home
	fi
done

end_time=$(date +%s)
echo "It took $(($end_time - $start_time)) seconds to complete this job..."

