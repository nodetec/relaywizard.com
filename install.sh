#!/bin/bash

# Compressed rwz binary file name
RWZ_TAR_GZ="rwz-0.3.0-alpha1-x86_64-linux-gnu.tar.gz"

# URL to download the rwz compressed binary
RWZ_URL="https://github.com/nodetec/relaywizard/releases/download/v0.3.0-alpha1/$RWZ_TAR_GZ"

# Destination path for the rwz compressed binary
TMP_RWZ_TAR_GZ="/tmp/$RWZ_TAR_GZ"

# Download the rwz compressed binary
echo "Downloading Relay Wizard from $RWZ_URL..."
curl -L -o "$TMP_RWZ_TAR_GZ" "$RWZ_URL"

# Destination path for the downloaded binary
DEST_PATH="/usr/local/bin"

# Extract rwz binary to the binary destination path
echo "Extracting Relay Wizard to $DEST_PATH..."
tar -xf "$TMP_RWZ_TAR_GZ" -C "$DEST_PATH"

# rwz binary name
RWZ="rwz"

# Make the binary executable
echo "Making rwz executable..."
chmod +x "$DEST_PATH/$RWZ"

# Run the rwz install command
echo "Running rwz install..."
"$DEST_PATH/$RWZ" install < /dev/tty
