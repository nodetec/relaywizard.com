#!/bin/bash

# URL to download the relaywiz binary
RELAYWIZ_URL="https://github.com/nodetec/relaywizard/releases/download/v0.2.0/rwz"

# Destination path for the downloaded binary
DEST_PATH="/usr/local/bin/rwz"

# Download the relaywiz binary
echo "Downloading Relay Wizard from $RELAYWIZ_URL..."
curl -L -o "$DEST_PATH" "$RELAYWIZ_URL"

# Make the binary executable
echo "Making rwz executable..."
chmod +x "$DEST_PATH"

# Run the relaywiz install command
echo "Running rwz install..."
"$DEST_PATH" install < /dev/tty

