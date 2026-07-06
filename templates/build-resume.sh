#!/bin/bash
# Usage: ./build-resume.sh [--onepager] <markdown-file>
# Produces: <base>.html, <base>.pdf, <base>.docx (next to the input file)
# Requires: pandoc, weasyprint
#
# CSS is passed to weasyprint via -s using ABSOLUTE paths, so the input .md can
# live anywhere (templates/, applied/, the Obsidian vault, etc.) and still get
# styled — it no longer has to sit next to resume.css.
#
# --onepager  layers resume-onepager.css on top of resume.css to tighten spacing
#             for dense single-page resumes.

set -e

for dep in pandoc weasyprint; do
  if ! command -v "$dep" >/dev/null 2>&1; then
    echo "Error: $dep not installed. macOS: brew install pandoc && pip install weasyprint" >&2
    exit 1
  fi
done

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CSS_FILE="$SCRIPT_DIR/resume.css"
ONEPAGER_CSS="$SCRIPT_DIR/resume-onepager.css"

ONEPAGER=0
if [ "$1" = "--onepager" ]; then
  ONEPAGER=1
  shift
fi

if [ -z "$1" ]; then
  echo "Usage: $0 [--onepager] <markdown-file>"
  echo "  Converts a resume .md to .html, .pdf, and .docx"
  exit 1
fi

INPUT="$1"
BASE="${INPUT%.md}"

if [ ! -f "$INPUT" ]; then
  echo "Error: $INPUT not found"
  exit 1
fi

echo "Converting $INPUT..."

# Step 1: pandoc md → html body
BODY=$(pandoc "$INPUT" -t html --no-highlight 2>/dev/null)

# Step 2: wrap as a standalone HTML document (CSS applied via weasyprint -s below)
cat > "${BASE}.html" <<HTMLEOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
</head>
<body>
${BODY}
</body>
</html>
HTMLEOF

# Step 3: weasyprint html → pdf, with absolute stylesheet(s)
WP_STYLES=(-s "$CSS_FILE")
if [ "$ONEPAGER" -eq 1 ]; then
  WP_STYLES+=(-s "$ONEPAGER_CSS")
  echo "  (one-pager mode: layering resume-onepager.css)"
fi
weasyprint "${BASE}.html" "${BASE}.pdf" "${WP_STYLES[@]}" 2>/dev/null
echo "  → ${BASE}.pdf"

# Step 4: pandoc md → docx
pandoc "$INPUT" -o "${BASE}.docx" 2>/dev/null
echo "  → ${BASE}.docx"

echo "Done: ${BASE}.{html,pdf,docx}"
