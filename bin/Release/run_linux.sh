#!/bin/sh

READLINK="$(readlink -f "$0")"
DIR="$(dirname "$READLINK")"

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

SYSTEM_NAME=`uname -s`

case ${SYSTEM_NAME} in
Linux)
  SYSTEM_NAME=linux
  ;;
*)
  SYSTEM_NAME=unknown_
  ;;
esac

if [ "$1" ]
then
	if [ -f "$1" ]
	then
		SCRIPT="$1"
	else
		SCRIPT=main.lua
	fi
else
	SCRIPT=main.lua
fi

HAS_ZENITY=`whereis -b zenity | grep usr | wc -l`
if [ $HAS_ZENITY -eq 1 ]
then
	MSG='zenity --info --text'
else
	MSG=echo
fi

DIRNAME=`dirname "$SCRIPT"`
BASENAME=`basename "$SCRIPT"`
LUAJIT=${DIR}/bin/${SYSTEM_NAME}${MACHINE_NAME}/luajit
if [ -x $LUAJIT ]
then
  if [ "$DIRNAME" ]
  then
		if [ ! -d "$DIRNAME/bin/" ]
		then
			ln -s "${DIR}/bin" "$DIRNAME"
		fi
		if [ ! -d "$DIRNAME/lib/" ]
		then
			ln -s "${DIR}/lib" "$DIRNAME"
		fi
		cd "$DIRNAME"
	fi
  $LUAJIT "$BASENAME" "$@"
else
  $MSG "Your platform does not have a pre-compiled Cheetah engine."
  exit 1
fi
