#!/bin/sh
# shellcheck disable=SC2155
set -eu

GOAL=${1-default}
: "${BUILD_DATE:=$(date +%B\ %d,\ %Y)}"

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
  git push origin master || true
  git push --tags || true
}

##
# Using the functions defined above
case "$GOAL" in
  ci-setup)
    git_setup
    ;;
  ci-gh-page-bump)
    git_tag_bump
    ;;
  ci-gh-page-publish)
    git_publish
    ;;
  default)
    dagger call bump-date \
      --target docs/configuration.yaml \
      export --path docs/configuration.yaml

    dagger call build \
      --src . export --path dist/
    ;;
  *)
    echo ":: Unrecognized goal '${GOAL}'. Nothing to do."
    ;;
esac
