#!/bin/bash

if [ ! -n "$WERCKER_GH_NPM_RELEASE_GHTOKEN" ]; then
  fail "missing option \"ghtoken\""
fi

if [ ! -n "$WERCKER_GH_NPM_RELEASE_NPMTOKEN" ]; then
  fail "missing option \"npmtoken\""
fi

if [ 'github.com' = "$WERCKER_GIT_DOMAIN" ]; then
  repo="$WERCKER_GIT_OWNER/$WERCKER_GIT_REPOSITORY"
else
  fail "missing option \"repo\""
fi

info "using \"$repo\""

remote="https://$WERCKER_GH_NPM_RELEASE_GHTOKEN@github.com/$repo.git"

info "using \"$remote\""

if [ -n "$WERCKER_GH_NPM_RELEASE_BRANCH" ]; then
  branch="$WERCKER_GH_NPM_RELEASE_BRANCH"
else
  fail "missing option \"branch\""
fi

info "using branch \"$branch\""

git config user.email "pleaseemailus@wercker.com"
git config user.name "werckerbot"

git config push.default simple

git remote set-url origin "$remote"

git checkout "$branch"

git merge "$WERCKER_GIT_BRANCH"

VERSION=$(node -p "require('./package.json').version" | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}')

yarn version --new-version "$VERSION"

git push && git push --tags

if [ $? -ne 0 ]; then
  fail "failed deploying a new version to github"
fi

touch .npmrc

echo "//registry.npmjs.org/:_authToken=$WERCKER_GH_NPM_RELEASE_NPMTOKEN" >> .npmrc

while read pkg; do
  name=$(node -p "require('./package.json').name")
  current=$(node -e "console.log(require(\"$pkg\").version)")
  published=$(npm view "$name" version 2>/dev/null)
  if [ "$published" != "$current" ]; then
    node -e "p=require(\"$pkg\"); (p.scripts && p.scripts.build) ? process.exit(0) : process.exit(1)"
    if [ $? -eq 0 ]; then
      yarn && yarn build
    fi
    yarn publish --access "$WERCKER_GH_NPM_RELEASE_ACCESS" --new-version "$VERSION"
  fi
done < <(find . -name package.json)

if [ $? -ne 0 ]; then
  fail "failed deploying a new version to npm"
else
  success "ok"
fi
