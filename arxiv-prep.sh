#!/bin/sh
# ============================================================
# ATUM_ATOM CODEX — arXiv submission packager
# ============================================================
# Assembles a flat, arXiv-ready submission from src/ and packs it
# into build/arxiv/atum-atom-triadic-seal-<cycle>.tar.gz
#
# arXiv submissions are flat: there are no subdirectories, and the
# top-level file must find its inputs beside it. That is why this
# script copies rather than tarring src/ in place.
#
# arXiv does NOT run BibTeX. main.bbl must be present and current,
# so this script refuses to build a package without it.
#
# Usage:  ./arxiv-prep.sh [output-basename]
# ============================================================

set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$ROOT"

SRC_DIR="src"
BUILD_DIR="build"
PKG_DIR="$BUILD_DIR/arxiv/pkg"
OUT_DIR="$BUILD_DIR/arxiv"

CYCLE="20260621"
BASENAME="${1:-atum-atom-triadic-seal-$CYCLE}"
TARBALL="$OUT_DIR/$BASENAME.tar.gz"

# Files copied into the flat package. Keep this list in sync with
# the `sources:` block of 00README.yaml.
FILES="$SRC_DIR/main.tex $SRC_DIR/preamble.tex $SRC_DIR/references.bib"

die() {
    echo "arxiv-prep: $*" >&2
    exit 1
}

# ------------------------------------------------------------
# Preconditions
# ------------------------------------------------------------

for f in $FILES 00README.yaml; do
    [ -f "$f" ] || die "missing required file: $f"
done

BBL="$BUILD_DIR/main.bbl"
if [ ! -f "$BBL" ]; then
    die "missing $BBL — run 'make pdf' first.
  arXiv does not run BibTeX, so the compiled bibliography must be
  included in the package. Without it the reference list on arXiv
  would silently come out empty."
fi

# A .bbl older than the .bib means the shipped bibliography does not
# reflect the current references. That produces a package which builds
# cleanly and is quietly wrong, so it is treated as fatal.
if [ "$SRC_DIR/references.bib" -nt "$BBL" ]; then
    die "$BBL is older than $SRC_DIR/references.bib — re-run 'make pdf'."
fi

# ------------------------------------------------------------
# Assemble
# ------------------------------------------------------------

rm -rf "$PKG_DIR"
mkdir -p "$PKG_DIR"

for f in $FILES; do
    cp "$f" "$PKG_DIR/"
done
cp "$BBL" "$PKG_DIR/"
cp 00README.yaml "$PKG_DIR/"

# ------------------------------------------------------------
# Pack
# ------------------------------------------------------------

rm -f "$TARBALL"
# -C so the archive members are flat (main.tex, not pkg/main.tex).
tar -czf "$TARBALL" -C "$PKG_DIR" .

echo "arxiv-prep: package contents"
tar -tzf "$TARBALL" | sed 's|^\./||' | grep -v '^$' | sort | sed 's/^/  /'

SIZE=$(wc -c < "$TARBALL" | tr -d ' ')
echo "arxiv-prep: wrote $TARBALL ($SIZE bytes)"

# arXiv's upload limit is 6 MB for the source package.
LIMIT=6291456
if [ "$SIZE" -gt "$LIMIT" ]; then
    echo "arxiv-prep: WARNING — package exceeds arXiv's 6 MB source limit" >&2
fi
