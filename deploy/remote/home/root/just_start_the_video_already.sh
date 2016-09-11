#!/bin/sh

cd $(dirname $0)

./kill_video.sh
./kill_bluetooth.sh
./kill_ev3_menu.sh
./configure_video.sh
./start_video.sh
