#!/bin/bash

start_time=$(date +%s)
export IMOD_DIR=/opt/apps/imod/imod_4.11.12/

#Observe the directory depth of your subframes, alter -f parameter in cut to match
home=`pwd`
#Create output directory for aligned stacks

cd stacks
for st in *.mdoc ; do
#basest is the basename for each batch stack
basest=`basename $st .mrc.mdoc`
#pathfile names the .list containing path to the file as noted in the .mdoc file under SubFramePath row
pathfile=$basest"_path.list"
#listfile names the .list containing the name and tilt angle for each image
listfile=$basest".list"
#rawtilt file used by imod
rawtilt=$basest".rawtlt"
#zero needed to append between each image name in ordered.list file
zero=0

#read out current tilt series working on
echo $basest with $listfile

#Read/grep .mdoc for the subframe path for each image
#awk removes "SubFramePath = X:" 
#sed switchies windows "\" with "/" for use with unix (first) and removes carrige return (second)
#writes to a list file ($pathfile)
cat $st | grep SubFramePath | awk -F':' '{print $2}' | sed 's/\\/\//g' | sed "s/\r//g" > $pathfile

mkdir $basest

Z=1

#read each line of <$pathfile, get only file name, and transfer to new subdirectory
while read -r Line; do

#remove path before filename
noPath="${Line##*/}"
#remove suffix
noSuf=${noPath%.*}
suf="${noPath##*.}"
echo $noSuf

#get the angle corresponding to each image
#grep the TiltAngle entry for each image
#cut removes "TiltAngle =" before angle value
#sed removes carrige return
ang=`cat $st | grep -B25 $noPath | grep TiltAngle | cut -d= -f2 | sed "s/\r//g" `

#creates listfile that newstack will read to order images by tilt angle
printf "%3.4f\t%40s\n" $ang "${basest}-${Z}.mrc" >> ${basest}/$listfile 
echo $Z $ang

#Target directory to copy frames from
newline="../SumFrames/${noSuf}_sumavg.mrc"
#Target location for individual frames corresponding to stack z number
newname="${basest}/${basest}-${Z}.mrc"

#copy motioncorrected images in /SumFrames/ to corresponding tilt series directory
cp $newline $newname

((Z++))
done <$pathfile

((Z--))
#convert .mrc files into .st for imod order rawtilt file#
cd ${basest}
#read angles and image names in listfile and sort from - to +, write to _ordered.temp
sort -n $listfile | awk '{printf $2"\n"}' > ${basest}_ordered.temp
#determine the number of images in each stack (list file must begin with this number)
num=$(ls *.mrc | wc -l)
echo $num > ${basest}.sorted

#Add file names to sorted file separated by zeros corresponding to their correct sorted order (- to +)
for i in $(seq 1 $num); do
name=$(head -n$i ${basest}_ordered.temp | tail -1)
echo $name
echo $zero
done >> ${basest}.sorted
#Pull tilt angles from list file and create rawtilt file needed by Imod
sort -n $listfile | cut -f1 > $rawtilt

#Call imods newstack to stack each set of images into a .st file from - to +
/opt/apps/imod/imod_4.11.12/bin/newstack -filei ${basest}.sorted -tilt *.rawtlt -ou ${basest}.st

#Cleanup and reset for next tilt series
rm ${basest}_ordered.temp
rm ../$pathfile
cd $home
mv stacks/${basest}/* AlignedStacks/$basest
rm -r stacks/${basest}

#Copy required etomo generated files from /denoised/
cd AlignedStacks/$basest/
mkdir $basest
cp denoised/$basest/*.xf $basest/
cp denoised/$basest/*.com $basest/
cp denoised/$basest/*.tlt $basest/
cp denoised/$basest/*.xtilt $basest/
cp *.st $basest/
cd $basest/

#run the .com files and rotate the volume after reconstructing
submfg newst.com
submfg tilt.com
name_full="${basest}_full_rec.mrc"
name_final="${basest}_rec.mrc"

trimvol -rx $name_full $name_final

cd $home/stacks/

done

echo "Done."

end_time=$(date +%s)
echo "It took $(($end_time - $start_time)) seconds to complete this job..."

