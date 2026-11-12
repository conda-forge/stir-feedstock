#! /usr/bin/env bash
# Usage:
# cd recipe
# ../scripts/prep_upgrade.sh 7.2.1
ver=$1
majorminor_ver=${ver%\.[0-9]*}
for f in activate*; do sed -i -e "s#STIR-[0-9]*\.[0-9]*#STIR-${majorminor_ver}#" $f;done
sed -i \
    -e "s# version: *\".*# version: \"${ver}\"#g" \
    -e 's#build_number:.*#build_number: 0#g' \
    -e 's#dev_string:.*#dev_string: "dev0"#g' \
    recipe.yaml
