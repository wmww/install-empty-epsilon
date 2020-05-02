#!/bin/bash
set -euo pipefail

EE_USER=ee
if ! getent passwd "$EE_USER" > /dev/null; then
  # If the user doesn't exist
  adduser --disabled-password --gecos "" "$EE_USER"
  echo "$EE_USER:EmptyEpsilon!" | chpasswd
fi

