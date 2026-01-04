# 🍣 Sushi Roll Rush - Android Release Guide

This guide explains how to set up automated Android builds using GitHub Actions with secure keystore signing.

---

## 📋 Overview

The release system consists of:

1. **GitHub Actions Workflow** - Automatically builds signed APK & AAB on every push
2. **Keystore Generation Script** - Creates a JKS keystore for app signing
3. **Secure Secrets Management** - Keystore stored as base64 in GitHub Secrets

---

## 🔐 Privacy & Security Notice

### The keystore generation script:
- ✅ Does **NOT** collect any system information
- ✅ Does **NOT** auto-fill any data
- ✅ Does **NOT** access IP address, location, or user data
- ✅ **ALL** values are manually entered by the user
- ✅ Generates keystore using **ONLY** the provided inputs

### The GitHub Actions workflow:
- ✅ Keystore is decoded from base64 at runtime
- ✅ Keystore is **deleted** after build completes
- ✅ Secrets are **never** printed to logs
- ✅ Uses GitHub's encrypted secrets storage

---

## 🚀 Setup Instructions

### Step 1: Generate Keystore (One-time setup)

#### On Windows (PowerShell):
```powershell
cd scripts
.\generate-keystore.ps1
```

#### On macOS/Linux (Bash):
```bash
cd scripts
chmod +x generate-keystore.sh
./generate-keystore.sh
```

The script will prompt you for:
| Field | Example |
|-------|---------|
| Company/Organization Name | SushiRoll Inc |
| Organizational Unit | Mobile Development |
| City/Locality | Tokyo |
| State/Province | Tokyo |
| Country Code (2 letters) | JP |
| Key Alias | sushiroll-release |
| Key Password | (your secure password) |
| Store Password | (your secure password) |
| Validity (years) | 25 |

### Step 2: Add Secrets to GitHub

1. Go to your GitHub repository
2. Navigate to: **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add these 4 secrets:

| Secret Name | Value |
|-------------|-------|
| `SUSHIROLL_KEYSTORE_BASE64` | Contents of `sushiroll-keystore-base64.txt` |
| `SUSHIROLL_KEY_ALIAS` | The key alias you entered (e.g., `sushiroll-release`) |
| `SUSHIROLL_KEY_PASSWORD` | The key password you entered |
| `SUSHIROLL_STORE_PASSWORD` | The store password you entered |

### Step 3: Secure Your Keystore

After adding secrets to GitHub:

1. **BACKUP** the `.jks` file to a secure location (USB drive, password manager)
2. **DELETE** local sensitive files:
   ```bash
   rm sushiroll-release.jks
   rm sushiroll-keystore-base64.txt
   ```
3. **STORE** passwords in a password manager

> ⚠️ **WARNING**: If you lose your keystore, you cannot update your app on Google Play!

---

## 🔧 Triggering Builds

### Automatic Triggers

The workflow runs automatically on:
- Push to `main` or `master` branch
- Push to any `release/*` branch
- Pull requests to `main` or `master`

### Manual Trigger

1. Go to **Actions** tab in your GitHub repository
2. Select **Android Release Build** workflow
3. Click **Run workflow**
4. Choose branch and build type
5. Click **Run workflow**

---

## 📦 Downloading Build Artifacts

After a successful build:

1. Go to **Actions** tab
2. Click on the completed workflow run
3. Scroll to **Artifacts** section
4. Download:
   - `sushiroll-release-apk` - For direct installation/testing
   - `sushiroll-release-aab` - For Google Play Store upload

Artifacts are retained for **30 days**.

---

## 🏗️ Build Configuration

### Workflow File
`.github/workflows/android-release.yml`

### ProGuard Rules
`android/app/proguard-rules.pro`

Contains rules for:
- Flutter framework
- Play Core library (prevents R8 errors)
- Flame game engine
- AudioPlayers
- General Android optimizations

### Build Settings
`android/app/build.gradle.kts`

- **minifyEnabled**: `true` (code shrinking)
- **shrinkResources**: `true` (resource shrinking)
- **Java Version**: 17

---

## 🐛 Troubleshooting

### "Missing Play Core classes" error
The ProGuard rules in `proguard-rules.pro` include `-dontwarn` rules for Play Core classes. If you see this error, ensure the proguard file is properly referenced in `build.gradle.kts`.

### "Keystore not found" error
1. Verify the secret `SUSHIROLL_KEYSTORE_BASE64` is correctly set
2. Check the base64 encoding is valid (no line breaks)
3. Ensure all 4 secrets are configured

### "Signing config not found" error
The workflow creates `key.properties` at runtime. If this fails, check:
1. All 4 secrets exist in GitHub
2. Secret names match exactly (case-sensitive)

### Build fails locally but works in CI
The `build.gradle.kts` falls back to debug signing if `key.properties` doesn't exist locally. This is intentional for local development.

---

## 📁 File Structure

```
.github/
└── workflows/
    └── android-release.yml    # GitHub Actions workflow

scripts/
├── generate-keystore.ps1      # Windows keystore generator
└── generate-keystore.sh       # macOS/Linux keystore generator

android/
└── app/
    ├── build.gradle.kts       # Build config with signing
    └── proguard-rules.pro     # R8/ProGuard rules
```

---

## 🔒 GitHub Secrets Reference

| Secret | Description | Example |
|--------|-------------|---------|
| `SUSHIROLL_KEYSTORE_BASE64` | Base64 encoded JKS keystore | (long base64 string) |
| `SUSHIROLL_KEY_ALIAS` | Key alias in keystore | `sushiroll-release` |
| `SUSHIROLL_KEY_PASSWORD` | Password for the key | `MySecurePass123!` |
| `SUSHIROLL_STORE_PASSWORD` | Password for the keystore | `MySecurePass456!` |

---

## 📝 Notes

- The workflow uses Flutter `3.24.0` and Java `17`
- Builds are cached for faster subsequent runs
- AAB is required for new Google Play submissions
- APK is useful for direct testing/distribution

---

## 🆘 Support

If you encounter issues:
1. Check the workflow logs in GitHub Actions
2. Verify all secrets are correctly configured
3. Ensure the keystore was generated correctly
4. Check ProGuard rules if R8 fails

---

*Last updated: January 2026*
