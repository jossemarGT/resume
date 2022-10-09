#!/bin/sh
# shellcheck disable=SC2155
set -eu

GOAL=${1-default}
SRC_PATH=${SRC_PATH-$(pwd)}
BUILD_DATE=$(date +%B\ %d,\ %Y)

##
# Generates HTML page inside docs/ directory using RESUME.md file and Pandoc Docker
# container
generate_page () {
  echo  ":: Generating Page"
  docker run -v "${SRC_PATH}":/tmp/source -w /tmp/source --rm portown/alpine-pandoc pandoc \
        --verbose --fail-if-warnings --standalone --wrap=none --section-divs --no-highlight \
        --from markdown_github+yaml_metadata_block+auto_identifiers+smart-hard_line_breaks \
        --to html5 --template docs/resume.template --output docs/index.html \
        ./RESUME.md docs/configuration.yaml
}

##
# Bumps last modified date in pandoc template configuration
bump_date () {
  sed -i "s/date:.*/date:   ${BUILD_DATE}/" docs/configuration.yaml
}

##
# Generates PDF file inside dist/ directory using docs/index.html file and
# wkhtmltopdf Docker container
generate_pdf () {
  [ -d dist ] || mkdir dist
  echo  ":: Generating PDF"
  docker run -v "${SRC_PATH}":/tmp/source -w /tmp/source --rm madnight/docker-alpine-wkhtmltopdf \
        --page-size Letter --no-background --print-media-type \
        --enable-local-file-access -T 20 -R 13 -B 13 -L 13 \
        --user-style-sheet docs/stylesheets/wkhtmltopdf.css \
        docs/index.html dist/jossemargt-resume.pdf
}

######### CI Specific goals #########

##
# Setup git client in CI environment
git_setup () {
  if [ -z "$(git config --local user.name)" ]; then
    echo ':: Setup CI git user and email'
    git config --local user.name 'CI Bot'
    git config --local user.email 'no-reply@jossemargt.com'
  fi
}

##
# Commit changes on `docs` directory and tags branch's head with current date
git_tag_bump () {
  echo ':: Bump git tag'
  if [ -z "$(git --no-pager diff --numstat docs)" ]; then
    echo ":: Git bump -> docs directory didn't change. SKIPPED"
    return 0
  fi

  revision=$(date +'%Y%m%d')
  iteration=$(git --no-pager tag | grep -c "${revision}" || true)

  git commit -am "Update GH Pages on ${BUILD_DATE}. [skip ci]"
  git tag "${revision}-${iteration}"
}

##
# Push latest changes and tags (vendor specific implementation)
git_publish () {
  git push --tags -f
}

##
# Using the functions defined above
case "$GOAL" in
  ci-setup)
    [ -d dist ] || mkdir dist
    git_setup
    ;;
  ci-gh-page-bump)
    git_tag_bump
    ;;
  ci-gh-page-publish)
    git_publish
    ;;
  bump-date)
    bump_date
    ;;
  default)
    bump_date
    generate_page
    generate_pdf
    ;;
  *)
    echo ":: Unrecognized goal '${GOAL}'. Nothing to do."
    ;;
esac
