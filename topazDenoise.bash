#!/bin/bash


TOPAZ="/home/mose831/miniconda3/envs/topaz/bin/topaz"

mkdir SumFrames/denoised/

$TOPAZ denoise --patch-size 1024 --model affine -d 0 -o SumFrames/denoised/ SumFrames/*.mrc


