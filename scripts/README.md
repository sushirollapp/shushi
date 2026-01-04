# 🔐 Keystore Generation Scripts

This folder contains scripts to generate a JKS keystore for Android app signing.

## Privacy Guarantee

These scripts:
- ❌ Do **NOT** read any system information
- ❌ Do **NOT** access your IP address
- ❌ Do **NOT** access your location
- ❌ Do **NOT** auto-fill any values
- ❌ Do **NOT** send any data anywhere
- ✅ **ONLY** use values you manually type

## Usage

### Windows (PowerShell)
```powershell
.\generate-keystore.ps1
```

### macOS / Linux (Bash)
```bash
chmod +x generate-keystore.sh
./generate-keystore.sh
```

## What You'll Be Asked

1. **Company/Organization Name** - Your company name
2. **Organizational Unit** - e.g., "Mobile Development"
3. **City** - Your city
4. **State/Province** - Your state
5. **Country Code** - 2-letter code (e.g., US, JP, NG)
6. **Key Alias** - Name for the key (e.g., "sushiroll-release")
7. **Key Password** - Secure password (min 6 characters)
8. **Store Password** - Secure password (min 6 characters)
9. **Validity** - How many years (default: 25)

## Output Files

After running, you'll have:

| File | Purpose |
|------|---------|
| `sushiroll-release.jks` | The keystore file (BACKUP THIS!) |
| `sushiroll-keystore-base64.txt` | Base64 encoded for GitHub Secrets |

## Next Steps

1. **Add secrets to GitHub** (see instructions after script runs)
2. **Backup** the `.jks` file securely
3. **Delete** local files after adding to GitHub

## ⚠️ Security Warning

- **NEVER** commit `.jks` or `*-base64.txt` files to git
- **NEVER** share your keystore passwords
- **ALWAYS** backup your keystore - you need it for app updates!
