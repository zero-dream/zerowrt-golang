#!/bin/bash
# Copyright (C) 2026 ZeroDream
# https://github.com/zero-dream

# --------------------------------------------------

source "$ZD_ScriptPath/createPath.sh"
source "$ZD_ScriptPath/updateRepo.sh"
source "$ZD_ScriptPath/getLib.sh"

# --------------------------------------------------

pkgRepoPath="$(createTempPath 'Temp_PkgRepo:dir')"
git clone --depth=1 --single-branch --branch "$WRT_BRANCH" \
  --filter=blob:none --no-checkout \
  "$WRT_REPO" "$pkgRepoPath/"
cd "$pkgRepoPath/"
git sparse-checkout set "lang/golang/"
git checkout "$WRT_BRANCH"
cd "$GITHUB_WORKSPACE/"

updatePath=$(cloneRepo)
find "$updatePath/golang/" -mindepth 1 -delete
cp -a "$pkgRepoPath/lang/golang/." "$updatePath/golang/"

appPath=$(getLib 'zerowrt-golang-linux-amd64') || exit 1
echo "$(printf -- '-%.0s' {1..50})"
echo '# Update Golang Makefile'
while IFS= read -r -d '' file; do
  echo "$file"
  "$appPath" version update \
    --inputPath "$file" \
    --outputPath "$file"
done < <(
  find "$updatePath/golang/" -type f -path '*/golang*.*/Makefile' -mindepth 2 -maxdepth 2 -print0
)

message=$ZD_DateShangHai
pushRepo "$message"
