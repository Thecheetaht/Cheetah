#!/bin/sh
TMP=/tmp/cheetah-build-last
LAST=native
MAKE="/usr/bin/make -j4"
CLEAN="/usr/bin/make clean"
FLAGS_OPTIMIZE="-Ofast -fomit-frame-pointer -funroll-loops -mmmx -msse -ftree-vectorize -flto"
DIR=./bin/Release
MACHINE_NAME=`uname -m`
case ${MACHINE_NAME} in
i486|i586|i686)
  MACHINE_NAME=32
  ;;
x86_64)
  MACHINE_NAME=64
  ;;
*)
  MACHINE_NAME=
  ;;
esac

OS=linux
LIB=libcheetah.so
EXE=luajit
if [ "$1" == "win" -o "$1" == "windows" ]
then
	whereis i586-mingw32msvc-gcc | grep / > /dev/null
	if [ $? = "1" ]
	then
		whereis i586-pc-mingw32-gcc | grep / > /dev/null
		if [ $? = "1" ]
		then
			echo "You must install mingw32 - Minimalist GNU win32 (cross) compiler"
			exit 1
		else
			MINGWGCC=i586-pc-mingw32-gcc
		fi
	else
		MINGWGCC=i586-mingw32msvc-gcc
	fi
	FLAGS_OPTIMIZE="-O3 -ffast-math -fomit-frame-pointer -funroll-loops -mmmx -msse -ftree-vectorize"
	export CC=$MINGWGCC
	OS=win
	MACHINE_NAME=32
	LIB=cheetah.dll
	EXE=luajit.exe
	LAST=win
fi

if [ "$2" == "release" -o "$2" == "final" ]
then
	FLAGS="$FLAGS_OPTIMIZE"
else
	if [ "$2" == "debug" ]
	then
		FLAGS=-g
	else
		FLAGS=""
	fi
fi

if [ "$1" == "linux32" ]
then
	FLAGS="$FLAGS -m32"
	MACHINE_NAME=32
	LAST=linux32
fi

LIBPATH="$DIR/bin/$OS$MACHINE_NAME/$LIB"
EXEPATH="./bin/$OS$MACHINE_NAME/$EXE"

if [ "`cat $TMP`" != "$LAST $2" ]
then
	$CLEAN
fi
echo "$LAST $2" > $TMP
if [ "$2" == "final" ]
then
	$CLEAN
	CFLAGS="$FLAGS -fprofile-generate" $MAKE && mv libcheetah.so $LIBPATH
	pushd .
	cd $DIR
	pushd .
	cd Demos/Tests/LoadImages
	$EXEPATH main.lua
	popd
	pushd .
	cd Demos/Tests/Math
	$EXEPATH main.lua
	popd
	popd
	$CLEAN
	CFLAGS="$FLAGS -fprofile-use" $MAKE && mv libcheetah.so $LIBPATH
else
	CFLAGS="$FLAGS" $MAKE && mv libcheetah.so $LIBPATH
fi

if [ "$2" != "debug" ]
then
	strip -s $LIBPATH
fi

sh genheader.sh