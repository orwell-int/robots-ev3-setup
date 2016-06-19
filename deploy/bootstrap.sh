#!/usr/bin/env zsh
set -e
root_dir=$PWD
remote_home=$root_dir/remote/home/root/
if [ -e "$remote_home/capture" ] ; then
	exit 0
fi
COMPILER_FOLDER=$1
DESTINATION_FOLDER=$2
if [ -z "$COMPILER_FOLDER" ] ; then
	COMPILER_FOLDER=~/CodeSourcery/Sourcery_G++_Lite
fi
if [ -z "$DESTINATION_FOLDER" ] ; then
	DESTINATION_FOLDER=~/dev/cross/arm
fi
echo "COMPILER_FOLDER=$COMPILER_FOLDER" >&2
echo "DESTINATION_FOLDER=$DESTINATION_FOLDER" >&2
if [ ! -e "$COMPILER_FOLDER" ] ; then
	cd /tmp
    wget https://sourcery.mentor.com/GNUToolchain/package4571/public/arm-none-linux-gnueabi/arm-2009q1-203-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2
    mkdir -p ${COMPILER_FOLDER}
    tar -C ${COMPILER_FOLDER} --strip-components=1 -xjf arm-2009q1-203-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2
	sudo apt-get install lib32z1 lib32ncurses5 lib32bz2-1.0
	cd -
fi
if [ ! -e germs -o ! -e capture-video ] ; then
	git submodule update --init
fi
cd germs
if [ ! -e env/bin/activate ] ; then
	$SHELL ./bootstrap.sh
fi
source env/bin/activate
cd germs
cat << EOF >| setenv
export PATH=\$PATH:$COMPILER_FOLDER/bin
export INSTALLDIR=$DESTINATION_FOLDER
export CROSS=arm-none-linux-gnueabi
export CPP=\${CROSS}-cpp
export CXX=\${CROSS}-g++
export CC=\${CROSS}-gcc
export AR=\${CROSS}-ar
export LD=\${CROSS}-ld
export RANLIB=\${CROSS}-ranlib
export TARGET=\$CROSS
export TARGETMACH=arm
export BUILDMACH=$(uname -p)-$(uname -s | tr '[:upper:]' '[:lower:]')
EOF
source setenv
fab install:libv4l,prefix=$INSTALLDIR,merge=True
cd $root_dir/capture-video
echo "$CC -O2 -w -lv4l2 capture.c -o capture -L $INSTALLDIR/lib/ -I $INSTALLDIR/include" >&2
$CC -O2 -w -lv4l2 capture.c -o $remote_home/capture -L $INSTALLDIR/lib/ -I $INSTALLDIR/include
