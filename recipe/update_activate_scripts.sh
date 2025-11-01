#! /bin/sh
# example line
for f in activate\*; do sed -i -e s/6\.2/6.3/ $f;done
