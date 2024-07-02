#!/bin/bash

cd $(dirname $0)
commit_message=`date "+%Y-%m-%d %H:%M:%S"`
git checkout --orphan latest_branch
git add -A
git commit -am "$commit_message"
git branch -D main
git branch -m main
git push -f origin main
