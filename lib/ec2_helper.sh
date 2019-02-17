#!/usr/bin/env bash

True=1
False=0

function abort() {
  echo $1 >&2
  usage
  exit 1
}

function exec_action() {
  local _action_path=$1
  shift
  shift
  exec "$_action_path" "$@"
  return 0
}

function init_instances_info() {
  cat <<EOS >|"${EC2_HOME}/instances"
[

]
EOS
  return 0
}

function display_info() {
  cat <<EOS
------------------------------
InstanceName: $1
  Host: $2
  Profile: $3
  Port: $4
  User: $5
  IdentityFile: $6
------------------------------
EOS
  return 0
}

# Arguments
#   instance_name
function get_instance_json() {
  instance=$(cat "${EC2_HOME}/instances" | jq ".[] | select(.InstanceName == \"$1\")")

  if [ $? -ne 0 ] || [ "$instance" = null ] || [ -z "$instance" ]; then
    echo "InstanceName: ${name} は登録されていないか、jsonファイルが壊れています。" >&2
    exit 1
  fi

  echo $instance
  return 0
}

# Arguments
#   instance_json
function set_profile() {
  profile=$(echo $1 | jq -r '.Profile')
  if [ $profile != 'default' ]; then
    export AWS_DEFAULT_PROFILE=$profile
  fi

  return 0
}

function get_instanceID() {
  return 0
}
