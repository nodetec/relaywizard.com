#!/bin/bash

TMP_DIR_PATH="/tmp"
RWZ_RELEASES_URL="https://github.com/nodetec/relaywizard/releases/download"
RWZ_VERSION="v0.3.0-alpha5"
RWZ_TAR_GZ_FILE="rwz-0.3.0-alpha5-x86_64-linux-gnu.tar.gz"
RWZ_DOWNLOAD_URL="$RWZ_RELEASES_URL/$RWZ_VERSION/$RWZ_TAR_GZ_FILE"
TMP_RWZ_TAR_GZ_FILE_PATH="$TMP_DIR_PATH/$RWZ_TAR_GZ_FILE"
PGP_KEYSERVER="keys.openpgp.org"
NODE_TEC_PRIMARY_KEY_FINGERPRINT="04BD8C20598FA5FDDE19BECD8F2469F71314FAD7"
NODE_TEC_SIGNING_SUBKEY_FINGERPRINT="252F57B9DCD920EBF14E6151A8841CC4D10CC288"
RWZ_MANIFEST_SIG_FILE="rwz-0.3.0-alpha5-manifest.sha512sum.asc"
RWZ_MANIFEST_SIG_FILE_URL="$RWZ_RELEASES_URL/$RWZ_VERSION/$RWZ_MANIFEST_SIG_FILE"
TMP_RWZ_MANIFEST_SIG_FILE_PATH="$TMP_DIR_PATH/$RWZ_MANIFEST_SIG_FILE"
RWZ_MANIFEST_FILE="rwz-0.3.0-alpha5-manifest.sha512sum"
RWZ_MANIFEST_FILE_URL="$RWZ_RELEASES_URL/$RWZ_VERSION/$RWZ_MANIFEST_FILE"
TMP_RWZ_MANIFEST_FILE_PATH="$TMP_DIR_PATH/$RWZ_MANIFEST_FILE"
BINARY_DEST_DIR_PATH="/usr/local/bin"
RWZ_BINARY_FILE="rwz"

function file_exists() {
  if [ -f "$1" ]; then
    return 0
  else
    return 1
  fi
}

function remove_file() {
  if file_exists "$1"; then
    rm "$1"
    if [ $? -ne 0 ]; then
      printf "Error: Failed to remove the $1 file\n"
      exit 1
    fi
  fi
}

function download_file() {
  curl -L -o "$1" "$2"
  if [ $? -ne 0 ]; then
    printf "Error: Failed to download the $3 file\n"
    exit 1
  fi
}

function set_file_permissions() {
  chmod "$1" "$2"
  if [ $? -ne 0 ]; then
    printf "Error: Failed to set the $2 file permissions\n"
    exit 1
  fi
}

function update_packages() {
  apt update -qq
  if [ $? -ne 0 ]; then
    printf "Error: Failed to update packages\n"
    exit 1
  fi
}

function install_gnupg() {
  apt install -y -qq gnupg
  if [ $? -ne 0 ]; then
    printf "Error: Failed to install gnupg\n"
    exit 1
  fi
}

function import_pgp_key() {
  gpg --keyserver "$1" --recv-keys "$2"
  if [ $? -ne 0 ]; then
    printf "Error: Failed to import NODE-TEC PGP key\n"
    exit 1
  fi
}

function verify_pgp_sig() {
  local sig_file="$1" out=
  out=$(gpg --status-fd 1 --verify "$sig_file" 2>/dev/null)
  if [ $? -ne 0 ]; then
    printf "$out\n" >&2
    printf "Error: Failed to verify the signature of the $RWZ_MANIFEST_FILE\n"
    exit 1
  else
    echo "$out" | grep -qs "^\[GNUPG:\] VALIDSIG $NODE_TEC_SIGNING_SUBKEY_FINGERPRINT "
    if [ $? -ne 0 ]; then
      printf "$out\n" >&2
      printf "Error: Failed to verify the signature of the $RWZ_MANIFEST_FILE\n"
      exit 1
    else
      return 0
    fi
  fi
}

function verify_file_hashes() {
  local at_least_one_file_exists=false
  # Read the manifest file line by line
  if file_exists "$2" && [ -s "$2" ] && [ -r "$2" ]; then
    while IFS= read -r line; do
      # Extract the hash from the manifest file
      local hash_in_manifest=$(echo "$line" | cut -d' ' -f1)
      # Extract the file name from the manifest file
      local file_in_manifest=$(echo "$line" | cut -d'*' -f2)

      # Check if the corresponding file exists in the provided directory
      if file_exists "$1/$file_in_manifest"; then
        at_least_one_file_exists=true
        # Calculate and extract the hash for the corresponding file located in the provided directory
        local file_hash=$(sha512sum "$1/$file_in_manifest" | cut -d' ' -f1)
        # Check if the hash of the file matches the hash in the manifest file
        if [ "$file_hash" != "$hash_in_manifest" ]; then
          printf "Error: $file_in_manifest hash mismatch with hash in $2\n"
          exit 1
        fi
      fi
      if [[ $at_least_one_file_exists == false ]]; then
        printf "Error: No files specified in $2 found\n"
        exit 1
      fi
    done < "$2"
  else
    printf "Error: Unable to verify file hashes in the $2 file\n"
    exit 1
  fi
}

function extract_file() {
  tar -xf "$1" -C "$2"
  if [ $? -ne 0 ]; then
    printf "Error: Failed to extract $1 file to $2\n"
    exit 1
  fi
}

function rwz_install() {
  "$1" install < /dev/tty
}

# Check if the rwz compressed binary exists and remove it if it does
remove_file "$TMP_RWZ_TAR_GZ_FILE_PATH"

# Download the rwz compressed binary
printf "Downloading Relay Wizard from $RWZ_DOWNLOAD_URL...\n"
download_file "$TMP_RWZ_TAR_GZ_FILE_PATH" "$RWZ_DOWNLOAD_URL" "$RWZ_TAR_GZ_FILE"

# Set rwz compressed binary permissions
set_file_permissions 0644 "$TMP_RWZ_TAR_GZ_FILE_PATH"

# Update packages
update_packages

# Install GnuPG
install_gnupg

# Import NODE-TEC PGP key
printf "Importing NODE-TEC PGP key from $PGP_KEYSERVER...\n"
import_pgp_key "$PGP_KEYSERVER" "$NODE_TEC_PRIMARY_KEY_FINGERPRINT"

# Check if the rwz manifest signature file exists and remove it if it does
remove_file "$TMP_RWZ_MANIFEST_SIG_FILE_PATH"

# Download the rwz manifest signature file
printf "Downloading Relay Wizard manifest signature file from $RWZ_MANIFEST_SIG_FILE_URL...\n"
download_file "$TMP_RWZ_MANIFEST_SIG_FILE_PATH" "$RWZ_MANIFEST_SIG_FILE_URL" "$RWZ_MANIFEST_SIG_FILE"

# Set rwz manifest signature file permissions
set_file_permissions 0644 "$TMP_RWZ_MANIFEST_SIG_FILE_PATH"

# Check if the rwz manifest file exists and remove it if it does
remove_file "$TMP_RWZ_MANIFEST_FILE_PATH"

# Download the rwz manifest file
printf "Downloading Relay Wizard manifest file from $RWZ_MANIFEST_FILE_URL...\n"
download_file "$TMP_RWZ_MANIFEST_FILE_PATH" "$RWZ_MANIFEST_FILE_URL" "$RWZ_MANIFEST_FILE"

# Set rwz manifest file permissions
set_file_permissions 0644 "$TMP_RWZ_MANIFEST_FILE_PATH"

printf "Verifying $RWZ_TAR_GZ_FILE...\n"

if verify_pgp_sig "$TMP_RWZ_MANIFEST_SIG_FILE_PATH"; then
  printf "Verified the signature of the $RWZ_MANIFEST_FILE file\n"

  verify_file_hashes "$TMP_DIR_PATH" "$TMP_RWZ_MANIFEST_FILE_PATH"

  printf "Verified the hash of the $RWZ_TAR_GZ_FILE file\n"

  # Extract rwz binary to the binary destination path
  printf "Extracting Relay Wizard to $BINARY_DEST_DIR_PATH...\n"
  extract_file "$TMP_RWZ_TAR_GZ_FILE_PATH" "$BINARY_DEST_DIR_PATH"
  printf "Extracted Relay Wizard to $BINARY_DEST_DIR_PATH\n"

  # Make the binary executable
  printf "Making $RWZ_BINARY_FILE executable...\n"
  set_file_permissions 0755 "$BINARY_DEST_DIR_PATH/$RWZ_BINARY_FILE"
  printf "Made $RWZ_BINARY_FILE executable\n"

  # Run the rwz install command
  printf "Running $RWZ_BINARY_FILE install...\n"
  rwz_install "$BINARY_DEST_DIR_PATH/$RWZ_BINARY_FILE"
fi
