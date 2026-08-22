# GreenMarchy Live

A live-bootable Hyprland/Omarchy desktop ISO: ArchBang's proven archiso boot
scaffold (autologin live user, working live-session boot chain), running
Omarchy's actual desktop stack pulled straight from their hosted repo
(`pkgs.omarchy.org`) — no installer, no offline mirror, just boot and try it.

## About

- **Live-first**: boots straight to a working Hyprland desktop, no installer wizard
- **Arch Linux based**: standard archiso build system
- **Omarchy desktop**: Hyprland + uwsm + quickshell, `omarchy`/`omarchy-settings` packages for the real config/theme/keybindings
- **live user**: live session user, wheel group, passwordless sudo

## Packages

See `packages.x86_64` — ArchBang's live-medium fundamentals (boot, disk/rescue
tools) plus a trimmed Omarchy desktop package set (no Docker, LibreOffice,
Kdenlive, OBS Studio, Obsidian, Moonlight, or vendor-specific hardware
drivers — see the sibling `greenmarchy-source` fork for why).

## Building

See `profiledef.sh` and `airootfs/root/customize_airootfs.sh`. Uses the
`[omarchy]` repo added in `pacman.conf` (`SigLevel = Optional TrustAll`,
same trust model Omarchy's own installer uses for that repo).
