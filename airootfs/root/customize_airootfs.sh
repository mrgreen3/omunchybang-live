#!/usr/bin/env bash
# Configure live iso
# 
set -e -u -x
shopt -s extglob

# Set locales
[[ -f /etc/locale.gen ]] && sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

# Allow Parallel Downloads in pacman
[[ -f /etc/pacman.conf ]] && sed -i "s/^#Parallel/Parallel/" /etc/pacman.conf

# Un-comment mirrorlist to allow pacman to work live....
[[ -f /etc/pacman.d/mirrorlist ]] && sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist

# Sudo to allow no password
sed -i 's/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers
chown -c root:root /etc/sudoers
chmod -c 0440 /etc/sudoers

# Configure gparted to run with sudo for elevated permissions
#sed -i 's|^Exec=/usr/bin/gparted|Exec=sudo /usr/bin/gparted|' /usr/share/applications/gparted.desktop

# Hide gparted from application menu
sed -i '/^Categories=/a Hidden=true' /usr/share/applications/gparted.desktop

# Hostname (hardcoded for live ISO; users can change after installation)
echo "greenmarchy" > /etc/hostname

# Vconsole
echo "KEYMAP=us" > /etc/vconsole.conf
echo "FONT=Lat2-Terminus16" >> /etc/vconsole.conf

# Locale
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "LC_COLLATE=C" >> /etc/locale.conf

# Set clock to UTC
hwclock --systohc --utc

# Timezone
ln -sf /usr/share/zoneinfo/America/Montreal /etc/localtime

# Target directory where systemd user service symlinks will be created
TARGET_DIR="/etc/skel/.config/systemd/user/default.target.wants"

# Source directory for official systemd user service files
UNIT_SRC="/usr/lib/systemd/user"

# List of user services to be auto-enabled at login
SERVICES=(
  "wireplumber.service"
  "pipewire.service"
  "pipewire-pulse.service"
  "xdg-user-dirs.service"
)

# Create target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Loop through the list and create symlinks for each service
# Only symlink services that actually exist to prevent broken links
for service in "${SERVICES[@]}"; do
  if [[ -f "$UNIT_SRC/$service" ]]; then
    ln -sf "$UNIT_SRC/$service" "$TARGET_DIR/$service"
  else
    echo "Warning: Service file not found: $UNIT_SRC/$service"
  fi
done

# Add live user
useradd -m -p "" -G "wheel" -s /bin/bash -g users live
chown live /home/live

# Start required systemd services
systemctl enable {pacman-init,NetworkManager}.service -f

# Compile dconf database for system defaults
if command -v dconf &>/dev/null; then
  dconf update
fi

# Set graphical target
systemctl set-default graphical.target

# omarchy hard-depends on limine/limine-mkinitcpio-hook, which claims
# kernel-install duties from the linux package and skips the classic flat
# copy to /boot/vmlinuz-linux our archiso preset expects. We don't boot via
# Limine here (GRUB/syslinux, set up by the ISO build script itself, does
# that) — Limine just needs to be installed to satisfy the dependency, not
# actually used. So restore the plain kernel path ourselves: the raw kernel
# binary is always a package file at /usr/lib/modules/<version>/vmlinuz
# regardless of kernel-install scheme, then force our own preset
# (/etc/mkinitcpio.d/linux.preset, PRESETS=('archiso')), which is what the
# ISO build script expects to find at /boot/initramfs-*.img.
kernel_ver=$(/bin/ls -1 /usr/lib/modules | head -n1)
install -Dm644 "/usr/lib/modules/${kernel_ver}/vmlinuz" /boot/vmlinuz-linux
mkinitcpio -p linux
