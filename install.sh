#!/bin/bash

# Compressed rwz binary file name
RWZ_TAR_GZ="rwz-0.2.0-x86_64-linux-gnu.tar.gz"

# URL to download the rwz compressed binary
RWZ_URL="https://github.com/nodetec/relaywizard/releases/download/v0.2.0/$RWZ_TAR_GZ"

# Destination path for the rwz compressed binary
TEMP_DIR="/tmp"

# Download the rwz compressed binary
echo "Downloading Relay Wizard from $RWZ_URL..."
curl -L -o "$TEMP_DIR" "$RWZ_URL"

# Destination path for the downloaded binary
DEST_PATH="/usr/local/bin"

# Extract rwz binary to the binary destination path
echo "Extracting Relay Wizard to $DEST_PATH..."
tar -xf "$TEMP_DIR/$RWZ_TAR_GZ" -C "$DEST_PATH"

# Make the binary executable
echo "Making rwz executable..."
chmod +x "$DEST_PATH"

# Run the rwz install command
echo "Running rwz install..."
"$DEST_PATH" install < /dev/tty

