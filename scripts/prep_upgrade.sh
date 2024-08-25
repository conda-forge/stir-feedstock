#! /bin/sh
ver=$1
for f in activate*; do sed -i "s#STIR-6\..#STIR-${ver}#" $f;done
sed -i -e "s#6\..#${ver}#" -e 's#{% set build_number = . %}#{% set build_number = 0 %}#' meta.yaml
