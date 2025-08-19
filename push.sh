SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THRESHOLD="+100M"

#First fetch data from the system into dirs created (befor push delete them and only push tar)
echo "Removing dotfiles.tar.gz!"
rm "$SCRIPT_DIR/dotfiles.tar.gz"

ALIAS_DIR="$SCRIPT_DIR/alias"
CONFIG_DIR="$SCRIPT_DIR/config"

echo "Alias dir: $ALIAS_DIR"
echo "Config dir: $CONFIG_DIR"

# Copy alias file into alias dir
mkdir -p "$ALIAS_DIR/"
cp -v ~/.bash_aliases "$ALIAS_DIR/"

# Copy i3 config files
mkdir -p "$CONFIG_DIR/i3/"
cp -v ~/.config/i3/* "$CONFIG_DIR/i3/"

# Copy pet config files
mkdir -p "$CONFIG_DIR/pet/"
cp -v ~/.config/pet/* "$CONFIG_DIR/pet/"

# Copy pet config files
mkdir -p "$CONFIG_DIR/helix/"
cp -v ~/.config/helix/* "$CONFIG_DIR/helix/"

# Find large files
echo "Scanning for files larger than $THRESHOLD in current directory..."
LARGE_FILES=$(find . -type f -size "$THRESHOLD")

# If large files are found, list and prompt
if [[ -n "$LARGE_FILES" ]]; then
    echo "Large files found:"

      # Print size and path for each large file
    while IFS= read -r file; do
        FILE_SIZE=$(du -h "$file" | cut -f1)
        echo "$FILE_SIZE  $file"
    done <<< "$LARGE_FILES"
    
    # Prompt the user
    read -p "Continue anyway? (y/n): " answer
    case "$answer" in
        [Yy]* )
            echo "Continuing..."
            ;;
        [Nn]* )
            echo "Aborting."
            exit 1
            ;;
        * )
            echo "Invalid input. Exiting."
            exit 1
            ;;
    esac
else
    echo "No large files found. Continuing..."
fi

cd "$SCRIPT_DIR" || exit 1
tar czf dotfiles.tar.gz alias/ config/ scripts/

echo "=========== INSPECTING TAR GZ ARCHIVE =========="
tar -tzf dotfiles.tar.gz


#!/bin/bash

ARCHIVE="dotfiles.tar.gz"
ENCRYPTED_ARCHIVE="$ARCHIVE.gpg"

# Ensure the archive exists
if [[ ! -f "$ARCHIVE" ]]; then
    echo "❌ Archive '$ARCHIVE' not found."
    exit 1
fi

# === Step 1: Ask for password (for encryption) ===
read -s -p "Enter password for encryption: " ENCRYPT_PASS
echo

# Encrypt using GPG with the password
echo "$ENCRYPT_PASS" | gpg --batch --yes --symmetric --passphrase-fd 0 \
    --cipher-algo AES256 "$ARCHIVE"

# Optional: remove original unencrypted file
rm -f "$ARCHIVE"

echo "✅ Encrypted to $ENCRYPTED_ARCHIVE"

# === Step 2: Ask again for password (for test decryption) ===
read -s -p "Re-enter password to test decryption: " DECRYPT_PASS
echo

# Test decryption to /dev/null
if echo "$DECRYPT_PASS" | gpg --batch --quiet --passphrase-fd 0 \
    --decrypt "$ENCRYPTED_ARCHIVE" > /dev/null 2>&1; then
    echo "✅ Decryption test passed — password verified."
else
    echo "❌ Decryption failed — password incorrect or file corrupted."
    rm -f "$ENCRYPTED_ARCHIVE"
    echo "❌ Encrypted file removed for safety."
    exit 1
fi

# Clear sensitive vars from memory
unset ENCRYPT_PASS DECRYPT_PASS


git add --all
git commit -m "dotfiles update"
git push


