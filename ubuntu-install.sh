#!/bin/bash
set -euo pipefail

# see https://github.com/daid/EmptyEpsilon/wiki/Headless-Dedicated-Server

EE_VERSION="2020.03.22"
if test \$# -ge 1; then
  EE_VERSION="$1"
fi
EE_URL="https://github.com/daid/EmptyEpsilon/releases/download/EE-$EE_VERSION/Linux_EmptyEpsilon_EE-$EE_VERSION.deb"
# EE_URL="https://github.com/daid/EmptyEpsilon/releases/download/EE-$EE_VERSION/Native_EmptyEpsilon_EE-$EE_VERSION.deb"
SFML_VERSION="2.4.0"
SFML_INSTALL_DIR=$(realpath ./ee/)
SFML_URL="https://www.sfml-dev.org/files/SFML-$SFML_VERSION-linux-gcc-64-bit.tar.gz"
BIN_DIR="/usr/bin"
EE_HEADLESS_BIN="EmptyEpsilonHeadless"
EE_NORMAL_BIN="EmptyEpsilonGraphical"
DESKTOP_FILES_DIR="/usr/share/applications"
ICONS_DIR="/usr/share/pixmaps"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DESKTOP_FILE="$SCRIPT_DIR/empty-epsilon.desktop"
ICON_FILE="$SCRIPT_DIR/empty-epsilon.png"
rm -Rf ./ee
mkdir ee
wget -P ee "$SFML_URL"
mkdir -p "$SFML_INSTALL_DIR"
tar -xzf ee/SFML*.tar.gz -C "$SFML_INSTALL_DIR"
wget -P ee "$EE_URL"
sudo apt install ./ee/*EmptyEpsilon*.deb --allow-downgrades -y
sudo apt install xvfb xorg libxcb-image0 -y

SET_LIB_PATH_LINE="export LD_LIBRARY_PATH=\$${LD_LIBRARY_PATH+$LD_LIBRARY_PATH}:$SFML_INSTALL_DIR/SFML-$SFML_VERSION/lib/"

echo "#!/bin/bash
set -euo pipefail

Xvfb :1 -screen 0 800x600x16 &
XVFB_PID=\$!

SCENARIO=scenario_01_waves.lua
SCRIPTS_DIR='/usr/local/share/emptyepsilon/scripts/'

if test \$# -ge 1; then
  if test \$1 == 'list'; then
    ls \$SCRIPTS_DIR
    exit
  else
    SCENARIO=\$1
  fi
fi

if test -f \$SCRIPTS_DIR/\$SCENARIO; then
  $SET_LIB_PATH_LINE
  export DISPLAY=:1.0
  EmptyEpsilon headless_name=wmww headless_internet=1 headless_password=foobar headless=\$SCENARIO
else
  echo \$SCRIPTS_DIR/\$SCENARIO does not exist
fi

kill -KILL \$XVFB_PID
" | sudo tee "$BIN_DIR/$EE_HEADLESS_BIN" > /dev/null

sudo chmod +x "$BIN_DIR/$EE_HEADLESS_BIN"

echo "#!/bin/bash
set -euo pipefail

$SET_LIB_PATH_LINE

EmptyEpsilon "\$@"
" | sudo tee "$BIN_DIR/$EE_NORMAL_BIN" > /dev/null

sudo chmod +x "$BIN_DIR/$EE_NORMAL_BIN"

if test -d "$DESKTOP_FILES_DIR"; then
    sudo cp "$DESKTOP_FILE" "$DESKTOP_FILES_DIR"
    sudo cp "$ICON_FILE" "$ICONS_DIR"
fi

echo
echo "Looks like everything's set up! You can $EE_HEADLESS_BIN or $EE_NORMAL_BIN"
