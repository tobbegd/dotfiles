#!/bin/bash

ENCRYPTED_FILE="dotfiles.tar.gz.gpg"
DECRYPTED_FILE="dotfiles.tar.gz"

# Step 1: Choose a safe extract directory (not same as script or repo dir)
EXTRACT_DIR="$HOME/decrypted_dotfiles_$(date +%s)"
mkdir -p "$EXTRACT_DIR"

# Step 2: Prompt for password
read -s -p "Enter password to decrypt: " GPG_PASS
echo

# Step 3: Decrypt into the safe extract directory
DECRYPT_PATH="$EXTRACT_DIR/$DECRYPTED_FILE"

if echo "$GPG_PASS" | gpg --batch --yes --passphrase-fd 0 \
    --output "$DECRYPT_PATH" --decrypt "$ENCRYPTED_FILE"; then
    echo "✅ Decryption successful: $DECRYPT_PATH"
else
    echo "❌ Decryption failed. Exiting."
    rm -rf "$EXTRACT_DIR"
    exit 1
fi

# Step 4: Extract the tar.gz in the safe directory
echo "📦 Extracting archive..."
tar -xzf "$DECRYPT_PATH" -C "$EXTRACT_DIR"

# Optional: remove the decrypted archive after extraction
rm -f "$DECRYPT_PATH"

echo "✅ Extracted to: $EXTRACT_DIR"

