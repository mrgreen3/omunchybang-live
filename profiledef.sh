#!/usr/bin/env bash
#
# OmarchyBang Live ISO
# Archiso scaffold from ArchBang, desktop stack from Omarchy (pkgs.omarchy.org)

iso_name="omarchybang-beta"
iso_label="OMARCHYBANG_BETA_$(date +%d%m%y)"
iso_publisher="OmarchyBang <https://github.com/mrgreen3/omarchybang-live>"
iso_application="OmarchyBang Live ISO (Beta)"
# Version format: DDMMYY (day-month-year). Changes daily for testing/development builds.
# Chronologically sortable for easy identification of ISO age.
# For releases, replace with semantic versioning (e.g., "1.0.0") instead of $(date +%d%m%y)
iso_version="$(date +%d%m%y)"
install_dir="arch"
buildmodes=("iso")
bootmodes=('bios.syslinux'
           'uefi.systemd-boot')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/.gnupg"]="0:0:700"
)
#bootstrap_tarball_compression=(gzip -cn9)
