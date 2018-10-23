#!/bin/bash

if [[ -z "$APPVEYOR_PULL_REQUEST_HEAD_COMMIT" ]]; then
  /home/appveyor/gopath/src/github.com/eswdd/appveyor_pr_checker/appveyor_pr_checker --updated=Whitelist.txt
else
  git checkout master
  cp Whitelist.txt WhitelistMaster.txt
  git checkout ${APPVEYOR_PULL_REQUEST_HEAD_REPO_BRANCH}
  /home/appveyor/gopath/src/github.com/eswdd/appveyor_pr_checker/appveyor_pr_checker --base=WhitelistMaster.txt --updated=Whitelist.txt --out=report.md
  MESSAGE="$( cat report.md )"
  PAYLOAD="$( jq -nc --arg str "${MESSAGE}" '{"body": $str}' )"
  curl -H "Authorization: token ${GITHUB_TOKEN}" -X POST -d "${PAYLOAD}" "https://api.github.com/repos/${APPVEYOR_REPO_NAME}/issues/${APPVEYOR_PULL_REQUEST_NUMBER}/comments"
fi
