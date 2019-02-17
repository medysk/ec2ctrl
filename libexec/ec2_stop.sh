#!/usr/bin/env bash

function usage() {
  cat <<EOF
Usage:
  ec2 stop [options] <InstanceName>

Options:
  --help, -h      Print this help
  --debug, -d     Set to debug mode
EOF
  return 0
}

source ${EC2_LIB}/ec2_helper.sh

while [ 0 -ne "$#" ]; do
  arg="$1"
  shift
  case "$arg" in
    --help | -h ) usage; exit 0 ;;
    --debug | -d ) set -x ;;
    --[a-zA-Z]* | -[a-zA-Z]* ) abort "$0: 不正なオプションです ${arg}" ;;
    * ) if [ -z $name ]; then name=${arg}; fi ;;
  esac
done

if [ -z $name ]; then
  abort "$0: InstanceNameの指定エラー(given 0, expected 1)"
fi

instance=$(get_instance_json $name)
if [ $? -ne 0 ]; then exit 1; fi

set_profile "$instance"

# インスタンスID取得
name=$(echo $instance | jq -r '.InstanceName')
command="aws ec2 describe-tags --query \"Tags[?Value == '${name}'].ResourceId | [0]\" --output text"
instance_id=$(eval "$command")

# インスタンス停止
aws ec2 stop-instances "$instance_id"
