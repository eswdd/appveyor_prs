#!/bin/bash

if [[ -z "$APPVEYOR_PULL_REQUEST_HEAD_COMMIT" ]]; then
  echo ">>> No PR detected, running checker on branch ${APPVEYOR_REPO_BRANCH} <<<"
  /home/appveyor/gopath/src/github.com/eswdd/appveyor_pr_checker/appveyor_pr_checker --updated=Whitelist.txt
else
  echo ">>> PR detected, running checker on PR '${APPVEYOR_PULL_REQUEST_TITLE}' <<<"
  cp Whitelist.txt WhitelistUpdated.txt
  git checkout -q  master
  cp Whitelist.txt WhitelistMaster.txt
  echo ">>> Running PR Checker <<<"
  /home/appveyor/gopath/src/github.com/eswdd/appveyor_pr_checker/appveyor_pr_checker --base=WhitelistMaster.txt --updated=WhitelistUpdated.txt --out=report.md
  TO_EXIT=$?
  MESSAGE="$( cat report.md )"
  PAYLOAD="$( jq -nc --arg str "${MESSAGE}" '{"body": $str}' )"
  echo ">>> Posting report to PR <<<"
  CURL_OUTPUT=`curl -H "Authorization: token ${GITHUB_TOKEN}" -X POST -d "${PAYLOAD}" "https://api.github.com/repos/${APPVEYOR_REPO_NAME}/issues/${APPVEYOR_PULL_REQUEST_NUMBER}/comments"`
  CURL_RESULT=$?
  if [[ $CURL_RESULT -ne 0 ]]; then
    echo ">>> Failed to post report, curl output follows <<<"
    echo ${CURL_OUTPUT}
  fi
  exit $TO_EXIT
fi
