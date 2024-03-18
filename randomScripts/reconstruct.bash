#!/bin/bash
#For every tilt series, edit the etomo .com files to create different binned aligned stacks and reconstructions and then run the .com files
start_time=$( date +%s)

home=$(pwd)
for entry in $home/*/
do

cd $entry
name=${PWD##*/}
name_full="${name}_full_rec.mrc"
name_final="${name}_rec.mrc"

#Binning values and corresponding image x,y dimensions
bin2="2"
bin1="1"
bindim2="2046,2880"
bindim1="4092,5760"

#Edit the newst.com and tilt.com files to change binning
sed -i "s/^BinByFactor.*/BinByFactor     ${bin2}/" newst.com
sed -i "s/^SizeToOutputInXandY.*/SizeToOutputInXandY ${bindim2}/" newst.com
sed -i "s/^IMAGEBINNED.*/IMAGEBINNED ${bin2}/" tilt.com

#run the .com files and rotate the volume after reconstructing
submfg newst.com

submfg tilt.com

trimvol -rx $name_full $name_final

sed -i "s/^BinByFactor.*/BinByFactor     1/" newst.com
sed -i "s/^SizeToOutputInXandY.*/SizeToOutputInXandY ${bindim1}/" newst.com

submfg newst.com

cd $home

done

end_time=$(date +%s)
echo "It took $(($end_time - $start_time)) seconds to complete this job..."



