#!/usr/bin/env bash

function usage() {
  cat <<EOF
Usage:
  ec2 [options] <command>

Options:
  --help, -h      Print this help
  --version, -v   Print this version
  --debug, -d     Set to debug mode

Commands:
  info      EC2インスタンス設定情報
  add       EC2インスタンス設定を追加
  remove    EC2インスタンス設定を削除
  start     EC2インスタンスを起動
  status    EC2インスタンスの状態を確認
  stop      EC2インスタンスを停止
EOF
  return 0
}
