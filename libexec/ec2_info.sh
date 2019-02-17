#!/usr/bin/env bash

function usage() {
  cat <<EOF
Usage:
  ec2 info [options] <InstanceName>

Options:
  --help, -h         Print this help
  --debug, -d        Set to debug mode
EOF
  return 0
}

function display() {
  local _name=$(echo $1 | jq '.InstanceName')
  local _host=$(echo $1 | jq '.Host')
  local _profile=$(echo $1 | jq '.Profile')
  local _port=$(echo $1 | jq '.Port')
  local _user=$(echo $1 | jq '.User')
  local _identity_file=$(echo $1 | jq '.IdentityFile')

  display_info $_name $_host $_profile $_port $_user $_identity_file
  return 0
}

source ${EC2_LIB}/ec2_helper.sh

while [ 0 -ne "$#" ]; do
  case "$1" in
    --help | -h ) usage; exit 0 ;;
    --debug | -d ) set -x ;;
    --[a-zA-Z]* | -[a-zA-Z]* ) abort "$0: 不正なオプションです $1" ;;
    * ) break ;;
  esac
  shift
done

if [ 1 -lt "$#" ]; then
  abort "$0: InstanceNameの指定エラー(given $#, expected 1)"
else
  name="$1"
fi

instances=$(cat "${EC2_HOME}/instances" | jq '.')

if [ -z "$name" ]; then
  count=$(echo $instances | jq length)
  for ((i=0; i<$count; i++)); do
    instance=$(echo "$instances" | jq ".[$i]")
    display "$instance"
  done
else
  instance=$(get_instance_json $name)
  if [ $? -ne 0 ]; then exit 1; fi

  display "$instance"
fi
