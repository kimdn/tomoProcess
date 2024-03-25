#!/bin/bash


TOPAZ="/home/mose831/miniconda3/envs/topaz/bin/topaz"

yaml="metadata-tomo.yaml"
topazModel=$(cat $yaml | grep topaz_model | awk '{print $2}')
topazDir="denoised_"$topazModel
target=SumFrames/$topazDir/

if [[ "$topazModel" == "NA" ]]
then
	echo "Skipping Denoising with Topaz"
else
	if [ -d $target ] ;
	then
		echo "Topaz denoise has already been run with "$topazModel" model, skipping..."
	else
	mkdir $target
	$TOPAZ denoise --patch-size 1024 --model $topazModel -d 0 -o $target SumFrames/*.mrc
	fi
fi

