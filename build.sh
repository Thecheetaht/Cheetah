#!/bin/sh
TMP=/tmp/cheetah-build-last
LAST=native
CORES=`nproc`
THREADS=`expr $CORES \* 2`
MAKE="/usr/bin/make -j$THREADS"
CLEAN="/usr/bin/make clean"
DIR=./Release
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
EXE=cheetah
COMPILER=gcc
FLAGS_THIRDPARTY=""

if [ "$1" == "clean" ]
then
	cd src
	make clean
	exit 0
fi
if [ "$1" == "win" -o "$1" == "windows" ]
then
	MINGWGCC=`ls /usr/bin/*mingw*gcc | head -1`
	if [ ! -f "$MINGWGCC" ]
	then
		echo "You must install mingw32 - Minimalist GNU win32 (cross) compiler"
		exit 1
	fi
	COMPILER=$MINGWGCC
	OS=win
	MACHINE_NAME=32
	LIB=cheetah.dll
	EXE=luajit.exe
	LAST=win
fi

GCC_VERSION=$($COMPILER -v |& tail -1 | awk '{print $3}' | sed s/\\.//g)
FLAGS_OPTIMIZE_GENERAL="-fomit-frame-pointer -mtune=generic"

# FLAGS_OPTIMIZE_GENERAL="$FLAGS_OPTIMIZE_GENERAL -ftree-vectorize"

FLAGS_OPTIMIZE="-O2 $FLAGS_OPTIMIZE_GENERAL"

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
	#clang has faster compile time than gcc and produces good code w/o -O3
	which clang > /dev/null 2>&1
	if [ "$?" = "0" ]
	then
		COMPILER=clang
		echo "Using clang"
	fi
fi

#~ which ccache > /dev/null 2>&1
#~ if [ "$?" = "0" ]
#~ then
	#~ COMPILER="ccache $COMPILER"
	#~ echo "Using ccache"
#~ fi

export CC="$COMPILER"

if [ "$1" == "linux32" ]
then
	FLAGS="$FLAGS -m32"
	MACHINE_NAME=32
	FLAGS_THIRDPARTY="-m32"
	LAST=linux32
fi

LIBPATH="$DIR/bin/$OS$MACHINE_NAME/$LIB"
EXEPATH="$DIR/bin/$OS$MACHINE_NAME/$EXE"

# if [ ! -f "$DIR/bin/$OS$MACHINE_NAME/$EXE" ]
# then
	# echo "Building luajit..."
	# (
		# cd thirdparty/LuaJIT
		# make clean
		# if [ "$1" == "win" -o "$1" == "windows" ]
		# then
			# make HOST_CC="gcc -m32" CROSS=${MINGWGCC%-gcc} TARGET_SYS=Windows
			# cp src/luajit.dll "../../$DIR/bin/$OS$MACHINE_NAME/"
		# else
			# if [ "$1" == "linux32" ]
			# then
				# make CC="gcc -m32"
			# else
				# make
			# fi
			# cp src/$EXE "../../$DIR/bin/$OS$MACHINE_NAME/"
		# fi
	# )
# fi

if [ "$CFLAGS" ]
then FLAGS="$FLAGS $CFLAGS"
fi

echo "Building on $CORES cores with flags: $FLAGS"

if [ "`cat $TMP`" != "$LAST $2" ]
then
	(cd src; $CLEAN)
fi
echo "$LAST $2" > $TMP
if [ "$2" == "final" ]
then
	if [ $GCC_VERSION -ge 450 ]
	then
		FLAGS="$FLAGS -flto"
	fi
	(cd src; $CLEAN)
	CFLAGS="$FLAGS -fprofile-generate" $MAKE && mv $EXE ../$EXEPATH
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
	(
		cd src
		$CLEAN
		CFLAGS="$FLAGS -fprofile-use" $MAKE && $EXE ../$EXEPATH
	)
else
	(
		cd src
		CFLAGS="$FLAGS" $MAKE && mv $EXE ../$EXEPATH
	)
fi

if [ "$2" != "debug" ]
then
	strip -s $EXEPATH
fi

sh genheader.sh
