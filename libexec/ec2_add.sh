#!/usr/bin/env bash

function usage() {
  cat <<EOF
Usage:
  ec2 add [options]

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
  esac
done

buffer=$(head -n -1 ${EC2_HOME}/instances)

key_count=$(less "${EC2_HOME}/instances" | jq length)
if [ "${key_count}" -ne 0 ]; then
  buffer+=$(echo -e ",\n")
fi

echo -n 'InstanceName: '
read NAME

echo -n '接続先ホスト: '
read HOST

echo -n 'プロファイル[default]: '
read PROFILE
PROFILE=${PROFILE:-default}

echo -n '接続先ユーザ[ec2-user]: '
read USER
USER=${USER:-ec2-user}

echo -n '接続先ポート[22]: '
read PORT
PORT=${PORT:-22}

echo -n '秘密鍵のパス: '
read IDENTITY_FILE

buffer+=$(cat <<EOS
  {
    "InstanceName": "${NAME}",
    "Host": "${HOST}",
    "Profile": "${PROFILE}",
    "Port": "${PORT}",
    "User": "${USER}",
    "IdentityFile": "${IDENTITY_FILE}"
  }
]
EOS
)

display_info $NAME $HOST $PROFILE $PORT $USER $IDENTITY_FILE

while : ; do
  echo -n '上記の情報を登録しますか?(yes/no): '
  read DO

  if [[ $DO =~ ^(y|yes)$ ]]; then
    json=$(echo "$buffer" | jq .)
    if [ "$json" = '' ]; then
      echo '設定をJSONに変換できませんでした'
      exit 1
    fi

    echo "$json" >|"${EC2_HOME}/instances"
    echo '登録しました'
    exit 0
  elif [[ $DO =~ ^(n|no)$ ]]; then
    echo '登録をキャンセルしました'
    exit 0
  fi

done
