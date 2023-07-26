#!/bin/bash

# Sets GitHub Action with error message to ease troubleshooting
function error() {
    echo "::error file=${FILENAME}::$1"
    exit 1
}

function debug() {
    TIMESTAMP=$(date -u "+%FT%TZ") # 2023-05-10T07:53:59Z
    echo ""${TIMESTAMP}" - $1"
}

function notice() {
    echo "::notice file=${FILENAME}::$1"
}

function start_span() {
    echo "::group::$1"
}

function end_span() {
    echo "::endgroup::"
}

function files_list_parser() {
  for glob in $(echo $1 | sed "s/,/ /g"); do
    for p in $glob; do
      replace_version $p
    done
  done
}

function replace_version() {
  notice "Replacing version in: ${1}"

  sed -i "s/${current_version}/${release_version}/g" ${1}
  cat $1
}


function main() {
  files_list_parser "${files}"
}

main "$@"