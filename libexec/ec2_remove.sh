#!/usr/bin/env bash

function usage() {
  cat <<EOF
Usage:
  ec2 info [options] <InstanceName>

Options:
  --all, -a          全ての設定情報を削除
  --help, -h         Print this help
  --debug, -d        Set to debug mode
EOF
  return 0
}

source ${EC2_LIB}/ec2_helper.sh

all_disp=$False

while [ 0 -ne "$#" ]; do
  case "$1" in
    --all | -a )  all_disp=$True ;;
    --help | -h ) usage; exit 0 ;;
    --debug | -d ) set -x ;;
    --[a-zA-Z]* | -[a-zA-Z]* ) abort "$0: 不正なオプションです $1" ;;
    * ) break ;;
  esac
  shift
done

if [ "$all_disp" = $False ]; then
  if [ 1 -ne "$#" ]; then
    abort "$0: InstanceNameの指定エラー(given $#, expected 1)"
  else
    name="$1"
  fi
fi

instances=$(less "${EC2_HOME}/instances" | jq '.')

if [ "$all_disp" = $True ]; then
  init_instances_info
else
  instance=$(get_instance_json $name)
  if [ $? -ne 0 ]; then exit 1; fi

  echo $instances | jq "map(select(.InstanceName != \"${name}\"))" >|${EC2_HOME}/instances

fi
