#!/bin/bash
set -euo pipefail

GOAL=${1-default}
BUILD_DATE=$(date +%B\ %d,\ %Y)
TITLE=$(sed -n -e "s/^title:[[:space:]]*'\([^']\+\).*'/\1/p" docs/configuration.yaml)

##
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

##
# Bumps last modified date in pandoc template configuration
bump_date () {
  # TODO: Bump only if RESUME.md has changed
  sed -i "s/date:.*/date:   ${BUILD_DATE}/" docs/configuration.yaml
}

##
# Generates PDF file inside dist/ directory using docs/index.html file and
# wkhtmltopdf Docker container
generate_pdf () {
  [ -d dist ] || mkdir dist
  echo  ":: Generating ${TITLE} PDF"
  docker run -v "$(pwd)":/tmp/source -w /tmp/source --rm madnight/docker-alpine-wkhtmltopdf \
        --quiet --title "${TITLE}" --page-size Letter --no-background \
        --print-media-type --viewport-size 520px \
        docs/index.html dist/jossemargt-resume.pdf
}

######### CI Specific goals #########

##
# Setup git client in CI environment
git_setup () {
  if [[ -z $(git config --local user.name) ]]; then
    echo ':: Setup CI git user and email'
    git config --local user.name 'Deployment Bot'
    git config --local user.email 'deploy-bot@jossemargt.com'
  fi
}

##
# Commit changes on `docs` directory and tags branch's head with current date
git_tag_bump () {
  if [[ -z $(git --no-pager diff --numstat docs) ]]; then
    echo ":: Git bump -> docs directory didn't change. SKIPPED"
    return 0
  fi

  git add docs
  git commit -m "Update GH Pages on ${BUILD_DATE}"
  git tag "$(date +'%Y%m%d')"
}

##
# Push latest changes and tags (vendor specific implementation)
git_publish () {
  if [[ $TRAVIS_EVENT_TYPE != 'pull_request' ]]; then
    set +x # Just in case
    git push "https://${GH_TOKEN}:x-oauth-basic@github.com/${TRAVIS_REPO_SLUG}" master --tags > /dev/null 2>&1
    return 0
  fi
  echo ':: Git publish -> Nothing to do'
}

##
# Using the functions defined above
case "$GOAL" in
  ci-git-setup)
    git_setup
    git_tag_bump
    ;;
  ci-git-push)
    git_publish # A fenced git push
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
