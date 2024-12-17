#!/bin/sh
set -e

echo "Activating feature 'lynxenc'"
SOURCE_DIR=/usr/src
mkdir -p ${SOURCE_DIR}
cd ${SOURCE_DIR}
git init
git config core.sparseCheckout true
git remote add -f origin https://github.com/42Bastian/new_bll.git
echo "lynxenc/" >> .git/info/sparse-checkout
git pull origin master
cd lynxenc
make
install lynxenc lynxdec /usr/bin

#rm -rf ${SOURCE_DIR}/lynxenc