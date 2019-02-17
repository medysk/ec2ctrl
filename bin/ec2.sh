#!/usr/bin/env bash

export CURRENT_DIR="$(pwd)"
export EC2_HOME=$(cd $(dirname $0); cd ..; pwd)
export EC2_LIB="${EC2_HOME}/lib"
export EC2_LIBEXEC="${EC2_HOME}/libexec"

source ${EC2_LIB}/ec2_helper.sh
source ${EC2_LIB}/ec2_usage.sh

cd "$EC2_HOME"

if [ ! -f "${EC2_HOME}/instances" ]; then
  init_instances_info
fi

if [[ 0 == "$#" ]]; then
  abort "コマンドを指定してください"
fi

while [ 0 -ne "$#" ]; do
  case "$1" in
    --version ) git describe --tags ;;
    --help ) usage; exit 0 ;;
    --debug ) set -x ;;
    -[a-zA-Z]* )
      while getopts vdh OPT; do
        case $OPT in
          v ) git describe --tags ;;
          h ) usage; exit 0 ;;
          d ) set -x ;;
          \? ) abort "$0: 不正なオプションです ${arg}" ;;
        esac
      done
      ;;
    info )   exec_action "${EC2_LIBEXEC}/ec2_info.sh" "$@" ;;
    add )    exec_action "${EC2_LIBEXEC}/ec2_add.sh" "$@" ;;
    remove ) exec_action "${EC2_LIBEXEC}/ec2_remove.sh" "$@" ;;
    start )  exec_action "${EC2_LIBEXEC}/ec2_start.sh" "$@" ;;
    stop )   exec_action "${EC2_LIBEXEC}/ec2_stop.sh" "$@" ;;
    ssh )    exec_action "${EC2_LIBEXEC}/ec2_ssh.sh" "$@" ;;
    * )      abort "$0: 不正なオプションです ${arg}" ;;
  esac

  shift

done
