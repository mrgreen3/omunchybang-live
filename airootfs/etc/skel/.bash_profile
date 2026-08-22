# GreenMarchy login shell configuration
# Starts the Omarchy Hyprland session via uwsm

. $HOME/.bashrc

# Start Hyprland (uwsm-managed) on TTY1
if [[ -z $WAYLAND_DISPLAY && -z $DISPLAY && $XDG_VTNR -eq 1 ]]; then
    export XDG_SESSION_TYPE=wayland
    exec uwsm start -g -1 -e -D Hyprland hyprland.desktop
fi



