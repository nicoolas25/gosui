#!/bin/bash
#
# create-sprites.sh original 304x437 15x10
#

cd $1

mkdir sprites

for D in *; do
  if [ -d "${D}" ]
  then
    cp ${D}/*.jpg ./sprites/
  fi
done

mkdir sprites/gosu
mkdir sprites/kamakor

for I in ./sprites/*.jpg; do
  if [ "$I" \< "./sprites/076.jpg" ]
  then
    mv "${I}" ./sprites/gosu/
  else
    mv "${I}" ./sprites/kamakor/
  fi
done

#echo "montage -resize $1! -geometry $1 -tile $2 ./sprites/*.jpg all.jpg"
montage -quality 70 -resize $2! -geometry $2 -tile $3 ./sprites/gosu/*.jpg gosu.jpg
montage -quality 70 -resize $2! -geometry $2 -tile $3 ./sprites/kamakor/*.jpg kamakor.jpg
