#!/bin/sh
# Installs or upgrades the widget for the current user.
set -e
cd "$(dirname "$0")"
kpackagetool6 -t Plasma/Applet -u package 2>/dev/null || kpackagetool6 -t Plasma/Applet -i package
