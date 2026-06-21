# Generate Fixity Manifest
# Purpose: Create a SHA256-hashed snapshot of the Codex directory
# Output: fixity_manifest_YYYYMMDD_HHMMSS.txt

Param(
    [string]$RootPath = "C:\Users\Infin\OneDrive\OD_Dragon_Consciousness",
    [string]$OutputDir = "manifests"
)

Function Get-DirectoryHash {
    Param([string]$Path)
    
    $files = Get-ChildItem -Path $Path -Recurse -File
    $hashes = @()
    
    foreach ($file in $files) {
        $hash = (Get-FileHash -Path $file.FullName -Algorithm SHA256).Hash
        $hashes += "$($file.FullName)=$hash"
    }
    
    $combinedString = $hashes -join "`n"
    $manifestHash = (Get-FileHash -InputStream ([System.IO.MemoryStream]::new([System.Text.Encoding]::UTF8.GetBytes($combinedString))) -Algorithm SHA256).Hash
    
    return @{
        Files = $hashes
        Hash  = $manifestHash
    }
}

# Generate timestamp
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$manifestFile = "fixity_manifest_$timestamp.txt"
$manifestPath = Join-Path $OutputDir $manifestFile

# Get directory hash
$result = Get-DirectoryHash -Path $RootPath

# Create manifest file
$content = @"
ATUM_ATOM FIXITY MANIFEST
Generated: $(Get-Date)
Root: $RootPath

File Hashes:
$($result.Files -join "`n")

Manifest Hash: $($result.Hash)
"@

Set-Content -Path $manifestPath -Value $content
Write-Host "Manifest created: $manifestPath"
Write-Host "Hash: $($result.Hash)"
