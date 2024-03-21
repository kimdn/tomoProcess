#!/bin/bash
#Converts multiple atlases collected in serialEM to individual images for stitching 

for i in *.st
do


basename1=${i#*-}
basename2=${basename1#*-}
basename3=${basename2%.*}
echo $basename3
pieces=$basename3".pieces"
blendout=$basename3".mrc"

extractpieces -input $i -output $pieces
blendmont -imin $i -plin $pieces -roo $basename3 -imout $blendout

rm $pieces
rm *.xef
rm *.yef

done


