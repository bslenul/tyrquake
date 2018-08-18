#!/bin/sh -e

source /etc/preinit
script_init

self="$(readlink -f "$0")"
name="$(basename "$self" .sh)"
cdir="$(dirname "$self")"
code="$(basename "$cdir")"
quakesaves="/var/saves/$code"

mkdir -p "$quakesaves"
[ -f "$quakesaves/save.sram" ] || touch "$quakesaves/save.sram"
cd "$cdir/$name"
[ -f "$name.txt" ] || touch "$name.txt"
if [ "$(cat /dev/clovercon1)" = 0800 ] || [ -z "$(cat "$name.txt")" ]; then
  decodepng "$cdir/$name/$name.png" > /dev/fb0
  until button_id="$(cat /dev/clovercon1 | grep "0200\|0002\|0001\|0100\|0400")"; do
    usleep 50000
  done
  if [ "$button_id" = 0100 ]; then
    [ "$(ls -d * | grep -iw id1)" ] && quake="$(ls -d * | grep -iw id1)"
  fi
  if [ "$button_id" = 0200 ]; then
    [ "$(ls -d * | grep -iw hypnotic)" ] && quake="$(ls -d * | grep -iw hypnotic)"
  fi
  if [ "$button_id" = 0002 ]; then
    [ "$(ls -d * | grep -iw rogue)" ] && quake="$(ls -d * | grep -iw rogue)"
  fi
  if [ "$button_id" = 0001 ]; then
    [ "$(ls -d * | grep -iw dopa)" ] && quake="$(ls -d * | grep -iw dopa)"
  fi
  [ "$button_id" = 0400 ] || [ -z "$quake" ] && exit 1
  if [ "$(ls "$quake" | grep -i "pak0.pak")" ]; then
    pak="$(readlink -f "$quake/`ls "$quake" | grep -i "pak0.pak"`")"
  else
    exit 1
  fi
  echo "$pak" > "$name.txt"
else
  pak="$(cat "$name.txt")"
  quake="$(basename `dirname "$pak"`)"
fi
decodepng "$cdir/$name/q1splash.png" > /dev/fb0
mkdir -p "$quakesaves/$quake"
[ -z "$(ls "$quakesaves/$quake")" ] || cp "$quakesaves/$quake/"* "$quake"
uistop
echo "retroarch-clover-child ../../..$cdir/$name/$name $pak --custom-loadscreen ../../../../../../..$cdir/$name/q1splash.png; \
mv -f $cdir/$name/$quake/*.sav $quakesaves/$quake" > /var/exec.flag
