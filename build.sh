#!/bin/bash
set -o pipefail

BUILD_DATE=$(date +%B\ %d,\ %Y)
TITLE=$(sed -n -e "s/^title:[[:space:]]*'\([^']\+\).*'/\1/p" docs/configuration.yaml)

# Generates HTML page on docs directory using RESUME.md file and pandoc docker
# container
generate_page () {
  echo  ":: Generating ${TITLE} Page"
  docker run -v "$(pwd)":/tmp/source -w /tmp/source --rm portown/alpine-pandoc pandoc \
        --verbose --fail-if-warnings --standalone --wrap=none --section-divs --no-highlight \
        --from      markdown_github+yaml_metadata_block+auto_identifiers+smart-hard_line_breaks \
        --to        html5 \
        --template  docs/resume.template \
        --output    docs/index.html \
        ./RESUME.md docs/configuration.yaml
}

# Bumps last modified date in pandoc template configuration
bump_date () {
  sed -i "s/date:.*/date:   ${BUILD_DATE}/" docs/configuration.yaml
}

# Using the functions defined above
bump_date
generate_page
