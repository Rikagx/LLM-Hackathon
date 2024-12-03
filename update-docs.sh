#!/bin/bash

set -e

OUTPUT_FILE="prompt.generated.md"

mkdir -p data
cp prompt-intro.md "$OUTPUT_FILE"

# Function to fetch and append content
fetch_and_append() {
    local repo=$1
    local file_path=$2
    local file_name=$(basename "$file_path")

    echo "" >> "$OUTPUT_FILE"
    echo "Here is the file $file_name for $repo:" >> "$OUTPUT_FILE"
    echo "<$file_name>" >> "$OUTPUT_FILE"
    curl -L "https://raw.githubusercontent.com/$repo/main/$file_path" >> "$OUTPUT_FILE"
    echo "</$file_name>" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
}

# Fetch files for posit-dev/chatlas
repo="posit-dev/chatlas"
fetch_and_append "$repo" "docs/index.qmd"
fetch_and_append "$repo" "docs/get-started.qmd"
fetch_and_append "$repo" "docs/prompt-design.qmd"
fetch_and_append "$repo" "docs/structured-data.qmd"
fetch_and_append "$repo" "docs/tool-calling.qmd"
fetch_and_append "$repo" "docs/web-apps.qmd"

# Fetch chat components docs for py-shiny
repo="posit-dev/py-shiny-site"
fetch_and_append "$repo" "components/display-messages/chat/index.qmd"
fetch_and_append "$repo" "components/display-messages/chat/app-express.py"