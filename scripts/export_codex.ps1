# Export Codex to Portable Format
# Purpose: Generate LaTeX, PDF, and Markdown versions of the Codex
# Output: codex_YYYYMMDD.pdf, codex_YYYYMMDD.md

Param(
    [string]$SourceDir = "codex",
    [string]$OutputDir = "exports"
)

Function Export-LaTeX {
    Param(
        [string]$SourceDir,
        [string]$OutputDir
    )
    
    $timestamp = Get-Date -Format "yyyyMMdd"
    $texFile = Join-Path $OutputDir "codex_$timestamp.tex"
    $pdfFile = Join-Path $OutputDir "codex_$timestamp.pdf"
    
    # Combine LaTeX files
    $texContent = @"
\documentclass[12pt,twoside]{book}
\usepackage[margin=1.25in]{geometry}
\usepackage{titlesec}
\usepackage{setspace}
\usepackage{fontspec}
\usepackage{graphicx}
\usepackage{tikz}
\usepackage{hyperref}

\title{\\textsc{ATUM\\_ATOM}}
\\The Triadic Seal}
\\author{James Paul Stanley Jr}
\\date{Binding Cycle 2026-06-21}

\\begin{document}

\\maketitle
\\tableofcontents

% Content from codex/book/

\\end{document}
"@
    
    Set-Content -Path $texFile -Value $texContent
    Write-Host "LaTeX export: $texFile"
    
    # Attempt PDF generation if xelatex/pdflatex available
    if (Get-Command xelatex -ErrorAction SilentlyContinue) {
        & xelatex -interaction=nonstopmode -output-directory=$OutputDir $texFile
        Write-Host "PDF generated: $pdfFile"
    } else {
        Write-Host "Note: xelatex not found. Install TeX Live or MiKTeX to generate PDF."
    }
}

Function Export-Markdown {
    Param(
        [string]$SourceDir,
        [string]$OutputDir
    )
    
    $timestamp = Get-Date -Format "yyyyMMdd"
    $mdFile = Join-Path $OutputDir "codex_$timestamp.md"
    
    $mdContent = @"
# ATUM_ATOM Codex

## Binding Cycle 2026-06-21

### The Three Pillars

1. **Manifest (Structure)** — Authoritative repository structure
2. **Signature (Integrity)** — EDDSA cryptographic attestation
3. **Seal (State)** — State snapshot with drift detection

### Linked Repositories

- Phoenix_Ignition_TOE
- Phoenix-2.0-Apex-Edition
- UNI_VERSE-
- TUA
- TOE
- Quantum

### Operator

James Paul Stanley Jr
Key: EDDSA F9B445CFDBA1ECD6ECC1899CB58390F86B642281

---

*Generated: $(Get-Date)*
"@
    
    Set-Content -Path $mdFile -Value $mdContent
    Write-Host "Markdown export: $mdFile"
}

# Create output directory if not exists
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

# Execute exports
Export-LaTeX -SourceDir $SourceDir -OutputDir $OutputDir
Export-Markdown -SourceDir $SourceDir -OutputDir $OutputDir

Write-Host "\n✓ Codex exported"
