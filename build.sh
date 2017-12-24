#!/bin/bash
set -o pipefail

BUILD_DATE=$(date +%B\ %d,\ %Y)
TITLE=$(sed -n -e "s/^title:[[:space:]]*'\([^']\+\).*'/\1/p" docs/configuration.yaml)

# Generates HTML page on docs directory using RESUME.md file and pandoc docker
# container
generate_page () {
  echo  ":: Generating ${TITLE} Page"
  docker run -v "$(pwd)":/source --rm jagregory/pandoc \
        --smart --wrap=none --normalize --section-divs --no-highlight \
        --from       markdown_github-hard_line_breaks+yaml_metadata_block \
        --to         html5 \
        --template   docs/resume.template \
        --output     docs/index.html \
        ./RESUME.md  docs/configuration.yaml
}

# Bumps last modified date in pandoc template configuration
bump_date () {
  sed -i "s/date:.*/date:   ${BUILD_DATE}/" docs/configuration.yaml
}

# Using above defined functions
bump_date
generate_page
