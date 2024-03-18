#!/bin/bash
start_time=$(date +%s)

export IMOD_DIR=/opt/apps/imod/imod_4.11.12/

thickness=1000

home=$(pwd)
dir=AlignedStacks

#For every subdirectory within /AlignedStacks/, run batchruntomo
#Batchruntomo makes another subdirectory within each tilt directory
#with the same name containing etomo files and output

for entry in $dir/*/
do

name=$(basename $entry)
echo $name
subDir=$name"_areTomo"
stkName=$name".st"
tltName=$name".rawtlt"
alistkName=$name"_ali.st"
stkXf=$name".st.xf"
recName=$name".rec"
cd $dir/$name/
mkdir $subDir

cp $stkName $subDir
cp $tltName $subDir
cd $subDir

/opt/apps/areTomo/areTomo_1_1_1/AreTomo_1.1.1_Cuda116_04-06-2022 -InMrc $stkName -OutMrc $name".mrc" -VolZ 0 -Patch 10 6 -OutXf 1 -OutImod 1 -DarkTol 0.01 -AngFile $tltName

newstack -in $stkName -ou $alistkName -xform $stkXf -bi 4

tilt -input $alistkName \
-output $recName \
-IMAGEBINNED 4 \
-TILTFILE *.rawtlt \
-THICKNESS $thickness \
-RADIAL 0.35,0.035 \
-FalloffIsTrueSigma 1 \
-XAXISTILT 0.0 \
-SCALE 0.0,1000 \
-PERPENDICULAR \
-MODE 2 \
-SUBSETSTART 0,0 \
-AdjustOrigin \
-ActionIfGPUFails 1,2 \
-OFFSET 0.0 \
-SHIFT 0.0 0.0 \

#Rotates the output volume by -90 degrees around the x axis using the imod program "trimvol"
trimvol $recName $recName -rx
rm *.rec~

done

cd $home

end_time=$(date +%s)
echo "It took $(($end_time - $start_time)) seconds to complete this job..."

