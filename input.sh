#!/bin/bash
xdotool key "t"
kdialog --inputbox ' ' | xclip -i -selection clipboard
xdotool key "ctrl+v"
xdotool key Return
