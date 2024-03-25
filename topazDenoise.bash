#!/bin/bash


TOPAZ="/home/mose831/miniconda3/envs/topaz/bin/topaz"

yaml="metadata-tomo.yaml"
topazModel=$(cat $yaml | grep topaz_model | awk '{print $2}')

if [[ "$topazModel" == "NA" ]]
then
	echo "Skipping Denoising with Topaz"
else

	topazDir="denoised"_$topazModel
	mkdir SumFrames/$topazDir
	$TOPAZ denoise --patch-size 1024 --model $topazModel -d 0 -o SumFrames/$topazDir/ SumFrames/*.mrc

fi

