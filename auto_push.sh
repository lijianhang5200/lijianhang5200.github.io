#!/bin/bash

cd $(dirname $0)

# 检查是否有未追踪的文件
git_check_untracked_files() {
  untracked_files=$(git ls-files --others --exclude-standard)
  if [[ -n $untracked_files ]]; then
    echo "未追踪的文件:"
    echo "$untracked_files"
    return 1
  fi
  return 0
}

# 检查是否有更改过的文件
git_check_modified_files() {
  modified_files=$(git status -s)
  if [[ -n $modified_files ]]; then
    echo "已修改的文件:"
    echo "$modified_files"
    return 1
  fi
  return 0
}

# 提交代码
git_commit_files() {
  git_check_untracked_files
  result1=$? # 获取func1的返回值

  git_check_modified_files
  result2=$? # 获取func2的返回值

  if [ $((result1 + result2)) -gt 0 ]; then
    commit_message=`date "+%Y-%m-%d %H:%M:%S"`
    echo "发现文件更改，准备提交..."
    git add .
    git commit -m "$commit_message"
    echo "提交成功。"
    return 1
  else
    echo "没有检测到文件更改，不执行提交。"
    return 0
  fi
}

# 使用示例
git_commit_files
result=1
git_push_commit() {
  git push https://lijianhang5200@github.com/lijianhang5200/lijianhang5200.github.io.git/
  return $?
}

while [ $result -ne 0 ]; do
  git_push_commit
  result=$?
  if [ $result -ne 0 ]; then
    sleep 10
  fi
done

