#!/bin/bash

# URL to download the rwz binary
RWZ_URL="https://github.com/nodetec/relaywizard/releases/download/v0.2.0/rwz"

# Destination path for the downloaded binary
DEST_PATH="/usr/local/bin/rwz"

# Download the rwz binary
echo "Downloading Relay Wizard from $RWZ_URL..."
curl -L -o "$DEST_PATH" "$RWZ_URL"

# Make the binary executable
echo "Making rwz executable..."
chmod +x "$DEST_PATH"

# Run the rwz install command
echo "Running rwz install..."
"$DEST_PATH" install < /dev/tty

