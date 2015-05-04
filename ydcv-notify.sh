#!/bin/sh
#STYLE="/home/farseerfc/.config/awesome/awesome.outlang"
word=`xsel`
ydcv=`ydcv "$word" --color always | 
aha -n | 
sed 's/style="color:/color="/g' |
sed 's/style="text-decoration:underline;/color="#111111/g' |
sed 's/olive;/#990099/g' |
sed 's/teal;/#999900/g' |
sed 's/purple;/#009900/g' |
cat`

sdcv=`sdcv "$word" -n|
fold -s -w70|
aha -n |
sed -E 's/^Found (.*) items, similar to (.*)\.$/<b>sdcv: \2\(\1\)<\/b>/g' |
sed -E 's/--&gt;(.*)$/<span color=\"#990000\">\1<\/span>/g' |
sed -E "s/[ ]+/ /g" |
sed -z "s/\n\n/\n/g" |
cat`

meaning=`echo -e "$ydcv\n$sdcv\n"`
notify-send -t 30000 "ydcv: $word" "$meaning"
