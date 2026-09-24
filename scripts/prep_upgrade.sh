#! /bin/bash
ver=$1
# get major.minor
ver_mm=${ver%.*}
for f in activate*; do sed -i "s#STIR-.\..#STIR-${ver_mm}#" $f;done
sed -i -e "s#version: \".*\"#version: \"${ver}\"#" -e 's#build_number:.*#build_number: 0#' recipe.yaml
