#!/bin/bash

start_time=$(date +%s)

export IMOD_DIR=/msc/krios/imod_4.9.12/

yaml="metadata-tomo.yaml"
motCorBin=$(cat $yaml | grep motCorr_bin | awk '{print $2}')
dir="SumFrames"

if [ -d "$dir" ] ;
then
	echo "Motion correction has already been performed, skipping..."
else

	GainRefDM4=*.dm4
	dm2mrc $GainRefDM4 GainRef.mrc
	newstack -in GainRef.mrc -bi 1 -ou GainRef.mrc
	GainRef=GainRef.mrc

	mkdir $dir

#Check file suffix in frames folder and determine if raw frames are .tifs or .mrcs
#Set suf and motcor (either -InTiff or -InMrc) variables depending on which is found
	for file in frames/*; do
		if [ "${file##*.}" == "mrc" ]
		then 
			suf=mrc
			motCor=-InMrc
		elif [ "${file##*.}" == "tif" ]
		then 
			suf=tif
			motCor=-InTiff
		fi
	done

#Run motioncorrection on each image found in frames directory
#Get basename from original images for output name and image name to call motion correction on
	for image in frames/*.$suf; do
		base_name=`basename ${image} .$suf`
		imageName=${base_name}".$suf"
		echo $base_name

		/msc/krios/motioncor2/MotionCor2_1.3.2-Cuda102 "$motCor" frames/$imageName \
		-OutMrc SumFrames/${base_name}_sumavg.mrc \
		-Patch 5 5 20 \
		-GPU 0 1 \
		-Gain $GainRef \
		-FlipGain 1 \
		-Iter 10 \
		-Tol 0.5 \
		-FtBin $motCorBin \

	done
fi

end_time=$(date +%s)
echo "It took $(($end_time - $start_time)) seconds to complete this job..."

