#!/bin/sh

#header generator from *.c files
DIR="./Release/lib"
FILENAME="$DIR/cheetah.h"
echo "/* AUTOGENERATED FILE. See genheader.sh for details */" > $FILENAME

cat src/cheetah.h | sed 's/CHEETAH_EXPORT //' | awk 'BEGIN {x=0}{if ($0~"^typedef struct"||$0~"^enum"||$0~"^struct") {x=1}if (x==1) {print $0}if ($0~"^}") {x=0}}' >> $FILENAME
grep -h 'CHEETAH_EXPORT' src/*.c | sed -r 's/CHEETAH_EXPORT (.*)/\1;/' >> $FILENAME
grep -h "^[a-zA-Z].*\(\s*\*.*\).*=\s*\&.*;\s*$" src/*.c | sed -E 's/\s*=\s*&[^;]+//' >> $FILENAME

#generate keycodes
SCANFILE="inc/SDL2/SDL_scancode.h"

echo "--AUTOGENERATED FILE. See genheader.sh for details" > "$DIR/keys.lua"
echo "--AUTOGENERATED FILE. See genheader.sh for details" > "$DIR/keys_reverse.lua"
echo "local key = {}" >> "$DIR/keys.lua"
echo "local key = {}" >> "$DIR/keys_reverse.lua"
grep ^\\s*SDL_SCANCODE_ "$SCANFILE" | cut -d, -f1 | sed s/^\\s*SDL_SCANCODE_// | tr "[:upper:]" "[:lower:]" | tr -s " =" " " | awk '{print "key["$2"] = \""$1"\""}' >> "$DIR/keys.lua"

grep ^\\s*SDL_SCANCODE_ "$SCANFILE" | cut -d, -f1 | sed s/^\\s*SDL_SCANCODE_// | tr "[:upper:]" "[:lower:]" | tr -s " =" " " | awk '{print "key[\""$1"\"] = "$2""}' >> "$DIR/keys_reverse.lua"

echo "return key" >> "$DIR/keys.lua"
echo "return key" >> "$DIR/keys_reverse.lua"