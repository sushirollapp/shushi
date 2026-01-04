#!/bin/bash
# ============================================
# SUSHI ROLL RUSH - Keystore Generation Script
# ============================================
# This script generates a JKS keystore for Android app signing.
# 
# PRIVACY NOTICE:
# - This script does NOT collect any system information
# - This script does NOT auto-fill any data
# - This script does NOT access IP, location, or user data
# - All values are manually entered by the user
# ============================================

set -e

echo ""
echo "============================================"
echo "  SUSHI ROLL RUSH - Keystore Generator"
echo "============================================"
echo ""
echo "This script will generate a JKS keystore for Android signing."
echo "All information must be entered manually - no auto-fill."
echo ""
echo "PRIVACY: This script does NOT collect any system/IP/location data."
echo ""

# ============================================
# CHECK FOR KEYTOOL
# ============================================
if ! command -v keytool &> /dev/null; then
    echo "ERROR: keytool not found. Please install Java JDK."
    echo "Install with:"
    echo "  macOS: brew install openjdk"
    echo "  Ubuntu: sudo apt install default-jdk"
    exit 1
fi

echo "Using keytool: $(which keytool)"
echo ""

# ============================================
# COLLECT COMPANY INFORMATION (Manual Entry Only)
# ============================================
echo "--- COMPANY INFORMATION (Required) ---"
echo ""

# Company/Organization Name
while [ -z "$COMPANY_NAME" ]; do
    read -p "Enter Company/Organization Name (e.g., SushiRoll Inc): " COMPANY_NAME
done

# Organization Unit
while [ -z "$ORG_UNIT" ]; do
    read -p "Enter Organizational Unit (e.g., Mobile Development): " ORG_UNIT
done

# City/Locality
while [ -z "$CITY" ]; do
    read -p "Enter City/Locality (e.g., Tokyo): " CITY
done

# State/Province
while [ -z "$STATE" ]; do
    read -p "Enter State/Province (e.g., Tokyo): " STATE
done

# Country Code (2 letters)
while [ ${#COUNTRY} -ne 2 ]; do
    read -p "Enter Country Code - 2 letters (e.g., JP, US, NG): " COUNTRY
    COUNTRY=$(echo "$COUNTRY" | tr '[:lower:]' '[:upper:]')
done

echo ""
echo "--- KEY CREDENTIALS ---"
echo ""

# Key Alias
while [ -z "$KEY_ALIAS" ]; do
    read -p "Enter Key Alias (e.g., sushiroll-release): " KEY_ALIAS
done

# Key Password (hidden input)
while [ ${#KEY_PASSWORD} -lt 6 ]; do
    read -s -p "Enter Key Password (min 6 chars): " KEY_PASSWORD
    echo ""
done

# Store Password (hidden input)
while [ ${#STORE_PASSWORD} -lt 6 ]; do
    read -s -p "Enter Store Password (min 6 chars): " STORE_PASSWORD
    echo ""
done

# Validity (years)
read -p "Enter validity in years (default: 25): " VALIDITY_YEARS
VALIDITY_YEARS=${VALIDITY_YEARS:-25}
VALIDITY_DAYS=$((VALIDITY_YEARS * 365))

echo ""
echo "--- GENERATING KEYSTORE ---"
echo ""

# ============================================
# GENERATE KEYSTORE
# ============================================
KEYSTORE_FILE="sushiroll-release.jks"
DNAME="CN=$COMPANY_NAME, OU=$ORG_UNIT, O=$COMPANY_NAME, L=$CITY, ST=$STATE, C=$COUNTRY"

# Remove existing keystore if present
rm -f "$KEYSTORE_FILE"

# Generate keystore using keytool
keytool -genkeypair -v \
    -keystore "$KEYSTORE_FILE" \
    -alias "$KEY_ALIAS" \
    -keyalg RSA \
    -keysize 2048 \
    -validity "$VALIDITY_DAYS" \
    -storepass "$STORE_PASSWORD" \
    -keypass "$KEY_PASSWORD" \
    -dname "$DNAME"

if [ -f "$KEYSTORE_FILE" ]; then
    echo "✅ Keystore generated successfully: $KEYSTORE_FILE"
else
    echo "❌ Failed to generate keystore"
    exit 1
fi

# ============================================
# ENCODE TO BASE64
# ============================================
echo ""
echo "--- ENCODING TO BASE64 ---"
echo ""

BASE64_FILE="sushiroll-keystore-base64.txt"

# Use appropriate base64 command based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    base64 -i "$KEYSTORE_FILE" -o "$BASE64_FILE"
else
    base64 -w 0 "$KEYSTORE_FILE" > "$BASE64_FILE"
fi

echo "✅ Base64 encoded keystore saved to: $BASE64_FILE"

# ============================================
# OUTPUT INSTRUCTIONS
# ============================================
echo ""
echo "============================================"
echo "  KEYSTORE GENERATION COMPLETE!"
echo "============================================"
echo ""
echo "FILES CREATED:"
echo "  1. $KEYSTORE_FILE (JKS keystore file)"
echo "  2. $BASE64_FILE (Base64 encoded for GitHub)"
echo ""
echo "============================================"
echo "  GITHUB SECRETS TO CREATE"
echo "============================================"
echo ""
echo "Go to your GitHub repository:"
echo "  Settings > Secrets and variables > Actions > New repository secret"
echo ""
echo "Create these 4 secrets:"
echo ""
echo "  Secret Name: SUSHIROLL_KEYSTORE_BASE64"
echo "  Value: (paste contents of $BASE64_FILE)"
echo ""
echo "  Secret Name: SUSHIROLL_KEY_ALIAS"
echo "  Value: $KEY_ALIAS"
echo ""
echo "  Secret Name: SUSHIROLL_KEY_PASSWORD"
echo "  Value: (the key password you entered)"
echo ""
echo "  Secret Name: SUSHIROLL_STORE_PASSWORD"
echo "  Value: (the store password you entered)"
echo ""
echo "============================================"
echo "  IMPORTANT SECURITY NOTES"
echo "============================================"
echo ""
echo "1. BACKUP the .jks file securely - you need it for updates!"
echo "2. NEVER commit the .jks or base64 file to git"
echo "3. DELETE local files after adding secrets to GitHub"
echo "4. STORE passwords in a secure password manager"
echo ""
echo "After adding secrets to GitHub, delete local sensitive files:"
echo "  rm $KEYSTORE_FILE"
echo "  rm $BASE64_FILE"
echo ""

# Clear sensitive variables
unset KEY_PASSWORD
unset STORE_PASSWORD

echo "Script completed."
