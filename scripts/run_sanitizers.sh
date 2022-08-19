cat "${INPUT_FILENAME}" | ./"${ZIP_NAME}"/"${EXECUTABLE_NAME}" &
sleep 3 && xdotool search --name "My Window" key X &&
sleep 1 && xdotool search --name "My Window" key Y &&
sleep 1 && xdotool search --name "My Window" key X &&
sleep 1 && xdotool search --name "My Window" key Z &&
sleep 2 && xdotool search --name "My Window" key Alt+F4
