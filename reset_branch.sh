#!/bin/bash

cd $(dirname $0)
commit_message=`date "+%Y-%m-%d %H:%M:%S"`
git checkout --orphan latest_branch
git add -A
git commit -am "$commit_message"
git branch -D main
git branch -m main

result=1
git_push_commit() {
  git push -f origin main
  return $?
}

while [ $result -ne 0 ]; do
  git_push_commit
  result=$?
  if [ $result -ne 0 ]; then
    sleep 10
  fi
done
