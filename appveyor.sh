#!/bin/bash

if [[ -z "$APPVEYOR_PULL_REQUEST_HEAD_COMMIT" ]]; then
  appveyor_pr_checker --updated=Whitelist.txt
else
  git checkout master
  cp Whitelist.txt WhitelistMaster.txt
  git checkout ${APPVEYOR_PULL_REQUEST_HEAD_REPO_BRANCH}
  appveyor_pr_checker --base=WhitelistMaster.txt --updated=Whitelist.txt --out=report.md
  curl -H "Authorization: token ${GITHUB_TOKEN}" -X POST -d "{\"body\": \"Hello world\"}" "https://api.github.com/repos/${APPVEYOR_REPO_NAME}/issues/${APPVEYOR_PULL_REQUEST_NUMBER}/comments"
fi
