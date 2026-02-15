#!/usr/bin/bash

startup_sleep=$1
command_sleep=$2
exit_sleep=$3

APP_WINDOW=${APP_WINDOW:-"My Window"}


if [[ -n "$WAYLAND_DISPLAY" ]]; then

  sleep "${startup_sleep}" && APP_ID=$(kdotool search --name "${APP_WINDOW}") &&
  echo "FOUND ${APP_ID}"
#   sleep "${command_sleep}" && kdotool windowmove "${APP_ID}" 10 10 &&
  # sleep "${command_sleep}" && ydotool mousemove -a 0 0 &&
  # sleep "${command_sleep}" && ydotool mousemove 40 30 &&
  # sleep "${command_sleep}" && ydotool click left &&
  sleep 3
  ydotool key 56:1   # press Alt (keycode 56)
    sleep 2
    ydotool key 35:1    # press H (keycode 35)
    sleep 2
    ydotool key 35:0    # release H
    sleep 0.5
    ydotool key 56:0   # release Alt
    sleep 0.5
    ydotool key 28:1   # press Enter (keycode 28)
    sleep 0.5
    ydotool key 28:0   # release Enter
    sleep 0.5
    ydotool key 28:1   # press Enter (keycode 28)
    sleep 0.5
    ydotool key 28:0   # release Enter
    sleep 1
  ydotool key 56:1   # press Alt (keycode 56)
    sleep 0.5
    ydotool key 33:1    # press F (keycode 33)
    sleep 0.5
    ydotool key 33:0    # release F
    sleep 0.5
    ydotool key 56:0   # release Alt
    sleep 0.5
    ydotool key 28:1   # press Enter (keycode 28)
    sleep 0.5
    ydotool key 28:0   # release Enter
    sleep 0.5
    ydotool key 28:1   # press Enter (keycode 28)
    sleep 0.5
    ydotool key 28:0   # release Enter
    sleep 1
  ydotool key 56:1   # press Alt (keycode 56)
    sleep 0.5
    ydotool key 62:1    # press Q (keycode 44)
    sleep 0.5
    ydotool key 62:0    # release Q
    sleep 0.5
    ydotool key 56:0   # release Alt
    sleep 1
    ydotool key 28:1   # press Enter (keycode 28)
    sleep 0.5
    ydotool key 28:0   # release Enter
else
  sleep "${startup_sleep}" && xdotool search --name "${APP_WINDOW}" key X &&
  sleep "${command_sleep}" && xdotool search --name "${APP_WINDOW}" key Y &&
  sleep "${command_sleep}" && xdotool search --name "${APP_WINDOW}" key X &&
  sleep "${command_sleep}" && xdotool search --name "${APP_WINDOW}" key Z &&
  sleep "${exit_sleep}" && xdotool search --name "${APP_WINDOW}" key Ctrl+Q
fi
