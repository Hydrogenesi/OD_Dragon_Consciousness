# ============================================================
# ATUM_ATOM CODEX — build
# ============================================================
# Targets:
#   make pdf       build the paper into build/main.pdf
#   make arxiv     produce the arXiv submission tarball
#   make manifest  regenerate the fixity manifest (PowerShell)
#   make seal      run a binding cycle (PowerShell)
#   make verify    check recorded seal digests against the files
#   make clean     remove LaTeX intermediates, keep the PDF
#   make distclean remove the whole build tree
#
# Uses latexmk when available and falls back to explicit
# pdflatex/bibtex passes when it is not.
# ============================================================

SHELL      := /bin/sh

SRC_DIR    := src
BUILD_DIR  := build
DIST_DIR   := $(BUILD_DIR)/arxiv

DOC        := main
PDF        := $(BUILD_DIR)/$(DOC).pdf

LATEX      ?= pdflatex
BIBTEX     ?= bibtex
LATEXMK    ?= latexmk
POWERSHELL ?= powershell

LATEXFLAGS := -interaction=nonstopmode -halt-on-error -file-line-error

SOURCES    := $(SRC_DIR)/$(DOC).tex $(SRC_DIR)/preamble.tex $(SRC_DIR)/references.bib

HAS_LATEXMK := $(shell command -v $(LATEXMK) 2>/dev/null)

.PHONY: all pdf arxiv manifest seal verify clean distclean help
.DEFAULT_GOAL := help

all: pdf

# ------------------------------------------------------------
# Paper
# ------------------------------------------------------------

pdf: $(PDF)

$(PDF): $(SOURCES) | $(BUILD_DIR)
ifdef HAS_LATEXMK
	cd $(SRC_DIR) && $(LATEXMK) -pdf -pdflatex="$(LATEX) $(LATEXFLAGS) %O %S" \
		-outdir=../$(BUILD_DIR) $(DOC).tex
else
	@echo "latexmk not found; falling back to explicit passes"
	cd $(SRC_DIR) && $(LATEX) $(LATEXFLAGS) -output-directory=../$(BUILD_DIR) $(DOC).tex
	cd $(BUILD_DIR) && BIBINPUTS=../$(SRC_DIR): $(BIBTEX) $(DOC)
	cd $(SRC_DIR) && $(LATEX) $(LATEXFLAGS) -output-directory=../$(BUILD_DIR) $(DOC).tex
	cd $(SRC_DIR) && $(LATEX) $(LATEXFLAGS) -output-directory=../$(BUILD_DIR) $(DOC).tex
endif
	@echo "built $(PDF)"

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# ------------------------------------------------------------
# arXiv submission package
# ------------------------------------------------------------

arxiv: pdf
	./arxiv-prep.sh

# ------------------------------------------------------------
# Triadic Seal operations (PowerShell, Windows-hosted Codex Root)
# ------------------------------------------------------------

manifest:
	$(POWERSHELL) -NoProfile -ExecutionPolicy Bypass -File scripts/generate_manifest.ps1

seal:
	$(POWERSHELL) -NoProfile -ExecutionPolicy Bypass -File scripts/triadic_bind.ps1

# Recompute the digests recorded in the meta-seal and compare them to the
# files on disk. Exits non-zero on the first mismatch so this is usable in CI.
verify:
	@set -e; \
	seal="codex/seals/seal_20260621_103610.txt"; \
	expected="58B16B0280F3DF2B4A463A1647AE606E85B11E460FDD7092717A5D4BDF9145FD"; \
	actual=$$(sha256sum "$$seal" | cut -d' ' -f1 | tr 'a-f' 'A-F'); \
	if [ "$$actual" = "$$expected" ]; then \
		echo "OK   $$seal"; \
	else \
		echo "FAIL $$seal"; \
		echo "  expected $$expected"; \
		echo "  actual   $$actual"; \
		exit 1; \
	fi

# ------------------------------------------------------------
# Housekeeping
# ------------------------------------------------------------

clean:
	rm -f $(BUILD_DIR)/*.aux $(BUILD_DIR)/*.bbl $(BUILD_DIR)/*.blg \
	      $(BUILD_DIR)/*.log $(BUILD_DIR)/*.out $(BUILD_DIR)/*.toc \
	      $(BUILD_DIR)/*.fls $(BUILD_DIR)/*.fdb_latexmk \
	      $(BUILD_DIR)/*.synctex.gz

distclean:
	rm -rf $(BUILD_DIR)

help:
	@echo "ATUM_ATOM Codex"
	@echo ""
	@echo "  make pdf        build build/main.pdf"
	@echo "  make arxiv      build and pack the arXiv submission"
	@echo "  make manifest   regenerate the fixity manifest"
	@echo "  make seal       run a binding cycle"
	@echo "  make verify     check recorded seal digests"
	@echo "  make clean      remove LaTeX intermediates"
	@echo "  make distclean  remove build/ entirely"
