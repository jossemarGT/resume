#!/bin/bash
set -eo pipefail

BUILD_DATE=$(date +%B\ %d,\ %Y)
TITLE=$(sed -n -e "s/^title:[[:space:]]*'\([^']\+\).*'/\1/p" docs/configuration.yaml)

# Generates HTML page inside docs/ directory using RESUME.md file and Pandoc Docker
# container
generate_page () {
  echo  ":: Generating ${TITLE} Page"
  docker run -v "$(pwd)":/tmp/source -w /tmp/source --rm portown/alpine-pandoc pandoc \
        --verbose --fail-if-warnings --standalone --wrap=none --section-divs --no-highlight \
        --from markdown_github+yaml_metadata_block+auto_identifiers+smart-hard_line_breaks \
        --to html5 --template docs/resume.template --output docs/index.html \
        ./RESUME.md docs/configuration.yaml
}

# Bumps last modified date in pandoc template configuration
bump_date () {
  sed -i "s/date:.*/date:   ${BUILD_DATE}/" docs/configuration.yaml
}

# Generates PDF file inside dist/ directory using docs/index.html file and
# wkhtmltopdf Docker container
generate_pdf () {
  [ -d dist ] || mkdir dist
  echo  ":: Generating ${TITLE} PDF"
  docker run -v "$(pwd)":/tmp/source -w /tmp/source --rm madnight/docker-alpine-wkhtmltopdf \
        --title "${TITLE}" --page-size Letter --no-background \
        --print-media-type --viewport-size 520px \
        docs/index.html dist/jossemargt-resume.pdf
}

# Using the functions defined above
bump_date
generate_page
generate_pdf
