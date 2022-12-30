#!/usr/bin/env bash

set -eu

repo_uri="https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
remote_name="origin"
main_branch="master"
target_branch="gh-pages"
build_dir="charts"

cd "$GITHUB_WORKSPACE"

git config user.name "$GITHUB_ACTOR"
git config user.email "${GITHUB_ACTOR}@bots.github.com"

git checkout "$target_branch" || git checkout -b "$target_branch"
git rebase "${remote_name}/${main_branch}"

git add "$build_dir"

for chart in $(ls -1 | grep -v -e terraform -e charts -e package_all.sh -e docker -e index.yaml -e README.md -e release.sh -e index.html); do
  helm package -d "$build_dir" $chart
done

helm repo index . --url https://$(echo $GITHUB_REPOSITORY | cut -d/ -f1).github.io/$(echo $GITHUB_REPOSITORY | cut -d/ -f2)
cat << EOF > index.html
<h1>Folio Helm Repository</h1>

<h2>Usage</h2>

<p>Example: install okapi</p>

<ol>
  <li>pirepare values file</li>
  <li>prepare secrets</li>
  <li>install via helm into folio namespace</li>
</ol>

<pre>
helm repo add folio https://$(echo $GITHUB_REPOSITORY | cut -d/ -f1).github.io/$(echo $GITHUB_REPOSITORY | cut -d/ -f2)
helm upgrade --install --wait --atomic --timeout 10m \
  --create-namespace \
  --values helm/okapi-values.yaml \
  --namespace=folio okapi folio/okapi
</pre>
EOF

git add "$build_dir"
git add index.yaml
git add index.html

git commit -m "updated GitHub Pages"
if [ $? -ne 0 ]; then
    echo "nothing to commit"
    exit 0
fi

git remote set-url "$remote_name" "$repo_uri" # includes access token
git push --force-with-lease "$remote_name" "$target_branch"
