#!/bin/sh

set -e

ImageType="{{ cookiecutter.image_type }}"

ImageSourceDir="{{ cookiecutter.image_slug }}"
ImageDestDir="./images/base-images"

if echo "$ImageType" | grep -q 'Child Image' ; then
    ImageDestDir="./images/child-images"
fi

cd ..

if [ -d "$ImageDestDir" ] ; then
    echo "Moving '$ImageSourceDir' to '$ImageDestDir'"
    mv -i "$ImageSourceDir" "$ImageDestDir"
else
    echo "Warning! Directory '$ImageDestDir' not found; keeping '$ImageSourceDir' in current directory."
fi
