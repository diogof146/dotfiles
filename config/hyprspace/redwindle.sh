#!/bin/bash

HYPRSPACE="/opt/homebrew/bin/hyprspace"

WINS=($($HYPRSPACE list-windows --workspace focused --format '%{window-id}'))
N=${#WINS[@]}

[ $N -le 1 ] && exit 0

for wid in "${WINS[@]}"; do
    $HYPRSPACE focus --window-id "$wid"
    sleep 0.03
    $HYPRSPACE layout floating
    sleep 0.03
done

for wid in "${WINS[@]}"; do
    $HYPRSPACE focus --window-id "$wid"
    sleep 0.05
    $HYPRSPACE layout tiling
    sleep 0.05
done
