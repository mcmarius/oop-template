cat "${INPUT_FILENAME}" | valgrind --leak-check=full --track-origins=yes --error-exitcode=0 ./bin/"${EXECUTABLE_NAME}" &
sleep 10 && xdotool search --name "My Window" key X &&
sleep 1 && xdotool search --name "My Window" key Y &&
sleep 1 && xdotool search --name "My Window" key X &&
sleep 1 && xdotool search --name "My Window" key Z &&
sleep 2 && xdotool search --name "My Window" key Alt+F4

