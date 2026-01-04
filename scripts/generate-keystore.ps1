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

# Get the directory where this script is located
$scriptDir = $PSScriptRoot
if (-not $scriptDir) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}
if (-not $scriptDir) {
    $scriptDir = Get-Location
}

# Change to script directory to ensure files are created here
Push-Location $scriptDir

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  SUSHI ROLL RUSH - Keystore Generator" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Working directory: $scriptDir" -ForegroundColor Gray
Write-Host ""
Write-Host "This script will generate a JKS keystore for Android signing." -ForegroundColor Yellow
Write-Host "All information must be entered manually - no auto-fill." -ForegroundColor Yellow
Write-Host ""
Write-Host "PRIVACY: This script does NOT collect any system/IP/location data." -ForegroundColor Green
Write-Host ""

# ============================================
# CHECK FOR KEYTOOL
# ============================================
$keytoolPath = $null

# Try common Java locations
$possiblePaths = @(
    "$env:JAVA_HOME\bin\keytool.exe",
    "$env:ProgramFiles\Java\*\bin\keytool.exe",
    "$env:ProgramFiles(x86)\Java\*\bin\keytool.exe",
    "$env:LOCALAPPDATA\Programs\Eclipse Adoptium\*\bin\keytool.exe",
    "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
)

foreach ($path in $possiblePaths) {
    $resolved = Get-Item $path -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($resolved) {
        $keytoolPath = $resolved.FullName
        break
    }
}

# Try PATH
if (-not $keytoolPath) {
    $keytoolPath = (Get-Command keytool -ErrorAction SilentlyContinue).Source
}

if (-not $keytoolPath) {
    Write-Host "ERROR: keytool not found. Please install Java JDK and ensure it's in PATH." -ForegroundColor Red
    Write-Host "Download from: https://adoptium.net/" -ForegroundColor Yellow
    Pop-Location
    exit 1
}

Write-Host "Using keytool: $keytoolPath" -ForegroundColor Gray
Write-Host ""

# ============================================
# COLLECT COMPANY INFORMATION (Manual Entry Only)
# ============================================
Write-Host "--- COMPANY INFORMATION (Required) ---" -ForegroundColor Cyan
Write-Host ""

# Company/Organization Name
do {
    $companyName = Read-Host "Enter Company/Organization Name (e.g., SushiRoll Inc)"
} while ([string]::IsNullOrWhiteSpace($companyName))

# Organization Unit
do {
    $orgUnit = Read-Host "Enter Organizational Unit (e.g., Mobile Development)"
} while ([string]::IsNullOrWhiteSpace($orgUnit))

# City/Locality
do {
    $city = Read-Host "Enter City/Locality (e.g., Tokyo)"
} while ([string]::IsNullOrWhiteSpace($city))

# State/Province
do {
    $state = Read-Host "Enter State/Province (e.g., Tokyo)"
} while ([string]::IsNullOrWhiteSpace($state))

# Country Code (2 letters)
do {
    $country = Read-Host "Enter Country Code - 2 letters (e.g., JP, US, NG)"
    $country = $country.ToUpper()
} while ($country.Length -ne 2)

Write-Host ""
Write-Host "--- KEY CREDENTIALS ---" -ForegroundColor Cyan
Write-Host ""

# Key Alias
do {
    $keyAlias = Read-Host "Enter Key Alias (e.g., sushiroll-release)"
} while ([string]::IsNullOrWhiteSpace($keyAlias))

# Key Password (hidden input)
do {
    $keyPasswordSecure = Read-Host "Enter Key Password (min 6 chars)" -AsSecureString
    $keyPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($keyPasswordSecure))
} while ($keyPassword.Length -lt 6)

# Store Password (hidden input)
do {
    $storePasswordSecure = Read-Host "Enter Store Password (min 6 chars)" -AsSecureString
    $storePassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($storePasswordSecure))
} while ($storePassword.Length -lt 6)

# Validity (years)
$validityYears = Read-Host "Enter validity in years (default: 25)"
if ([string]::IsNullOrWhiteSpace($validityYears)) { $validityYears = "25" }
$validityDays = [int]$validityYears * 365

Write-Host ""
Write-Host "--- GENERATING KEYSTORE ---" -ForegroundColor Cyan
Write-Host ""

# ============================================
# GENERATE KEYSTORE (using absolute paths)
# ============================================
$keystoreFileName = "sushiroll-release.jks"
$keystoreFile = Join-Path $scriptDir $keystoreFileName
$dname = "CN=$companyName, OU=$orgUnit, O=$companyName, L=$city, ST=$state, C=$country"

Write-Host "Keystore will be created at: $keystoreFile" -ForegroundColor Gray

# Remove existing keystore if present
if (Test-Path $keystoreFile) {
    Remove-Item $keystoreFile -Force
    Write-Host "Removed existing keystore file" -ForegroundColor Gray
}

# Generate keystore using keytool with absolute path
$keytoolArgs = @(
    "-genkeypair",
    "-v",
    "-keystore", $keystoreFile,
    "-alias", $keyAlias,
    "-keyalg", "RSA",
    "-keysize", "2048",
    "-validity", $validityDays,
    "-storepass", $storePassword,
    "-keypass", $keyPassword,
    "-dname", $dname
)

try {
    $output = & $keytoolPath @keytoolArgs 2>&1
    
    # Check if file was actually created
    if (Test-Path $keystoreFile) {
        $fileSize = (Get-Item $keystoreFile).Length
        Write-Host "✅ Keystore generated successfully!" -ForegroundColor Green
        Write-Host "   File: $keystoreFile" -ForegroundColor White
        Write-Host "   Size: $fileSize bytes" -ForegroundColor Gray
    } else {
        Write-Host "❌ Failed to generate keystore - file not found" -ForegroundColor Red
        Write-Host "Keytool output:" -ForegroundColor Yellow
        Write-Host $output -ForegroundColor Gray
        Pop-Location
        exit 1
    }
} catch {
    Write-Host "❌ Error generating keystore: $_" -ForegroundColor Red
    Pop-Location
    exit 1
}

# ============================================
# ENCODE TO BASE64
# ============================================
Write-Host ""
Write-Host "--- ENCODING TO BASE64 ---" -ForegroundColor Cyan
Write-Host ""

$base64FileName = "sushiroll-keystore-base64.txt"
$base64File = Join-Path $scriptDir $base64FileName

try {
    # Read the keystore file bytes using absolute path
    $keystoreBytes = [System.IO.File]::ReadAllBytes($keystoreFile)
    
    if ($keystoreBytes.Length -eq 0) {
        Write-Host "❌ Keystore file is empty!" -ForegroundColor Red
        Pop-Location
        exit 1
    }
    
    # Convert to base64
    $keystoreBase64 = [System.Convert]::ToBase64String($keystoreBytes)
    
    # Save base64 to file
    [System.IO.File]::WriteAllText($base64File, $keystoreBase64)
    
    $base64Length = $keystoreBase64.Length
    Write-Host "✅ Base64 encoded keystore saved!" -ForegroundColor Green
    Write-Host "   File: $base64File" -ForegroundColor White
    Write-Host "   Length: $base64Length characters" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Error encoding to base64: $_" -ForegroundColor Red
    Pop-Location
    exit 1
}

# ============================================
# OUTPUT INSTRUCTIONS
# ============================================
Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  KEYSTORE GENERATION COMPLETE!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "FILES CREATED IN: $scriptDir" -ForegroundColor Yellow
Write-Host "  1. $keystoreFileName (JKS keystore file)" -ForegroundColor White
Write-Host "  2. $base64FileName (Base64 encoded for GitHub)" -ForegroundColor White
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  GITHUB SECRETS TO CREATE" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Go to your GitHub repository:" -ForegroundColor Yellow
Write-Host "  Settings > Secrets and variables > Actions > New repository secret" -ForegroundColor Yellow
Write-Host ""
Write-Host "Create these 4 secrets:" -ForegroundColor White
Write-Host ""
Write-Host "  Secret Name: SUSHIROLL_KEYSTORE_BASE64" -ForegroundColor Cyan
Write-Host "  Value: (paste contents of $base64FileName)" -ForegroundColor Gray
Write-Host ""
Write-Host "  Secret Name: SUSHIROLL_KEY_ALIAS" -ForegroundColor Cyan
Write-Host "  Value: $keyAlias" -ForegroundColor Gray
Write-Host ""
Write-Host "  Secret Name: SUSHIROLL_KEY_PASSWORD" -ForegroundColor Cyan
Write-Host "  Value: (the key password you entered)" -ForegroundColor Gray
Write-Host ""
Write-Host "  Secret Name: SUSHIROLL_STORE_PASSWORD" -ForegroundColor Cyan
Write-Host "  Value: (the store password you entered)" -ForegroundColor Gray
Write-Host ""
Write-Host "============================================" -ForegroundColor Red
Write-Host "  IMPORTANT SECURITY NOTES" -ForegroundColor Red
Write-Host "============================================" -ForegroundColor Red
Write-Host ""
Write-Host "1. BACKUP the .jks file securely - you need it for updates!" -ForegroundColor Yellow
Write-Host "2. NEVER commit the .jks or base64 file to git" -ForegroundColor Yellow
Write-Host "3. DELETE local files after adding secrets to GitHub" -ForegroundColor Yellow
Write-Host "4. STORE passwords in a secure password manager" -ForegroundColor Yellow
Write-Host ""
Write-Host "After adding secrets to GitHub, delete local sensitive files:" -ForegroundColor Red
Write-Host "  Remove-Item '$keystoreFile'" -ForegroundColor Gray
Write-Host "  Remove-Item '$base64File'" -ForegroundColor Gray
Write-Host ""

# Restore original directory
Pop-Location

# Clear sensitive variables from memory
$keyPassword = $null
$storePassword = $null
[System.GC]::Collect()

Write-Host "Script completed. Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
