#!/bin/bash

function has_required_config() {
    start_span "Validating required config"
    test -z "${current_version}" && error "current_version env must be set"
    test -z "${release_version}" && error "release_version env must be set"
    # test -z "${GH_TOKEN}" && error "GH_TOKEN env must be set for GitHub CLI"

    # Default GitHub Actions Env Vars: https://docs.github.com/en/actions/learn-github-actions/variables#default-environment-variables
    debug "Are we running in GitHub Action environment?"
    test -z "${GITHUB_RUN_ID}" && error "GITHUB_RUN_ID env must be set to trace Workflow Run ID back to PR"
    test -z "${GITHUB_SERVER_URL}" && error "GITHUB_SERVER_URL env must be set to trace Workflow Run ID back to PR"
    test -z "${GITHUB_REPOSITORY}" && error "GITHUB_REPOSITORY env must be set to trace Workflow Run ID back to PR"

    debug "Config validated successfully!"
    end_span
}

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
    ARG="-name"
    if [[ "${glob}" == *"/"* ]]; then
      ARG="-wholename"
    fi

    for p in $(eval find . $ARG $glob); do
      replace_version $p
    done
  done
}

function replace_version() {
  notice "Replacing version in: ${1}"

  sed -i "s/${current_version}/${release_version}/g" ${1}
}


function main() {
  has_required_config

  notice "Updating version from ${current_version} to ${release_version} in files: ${files}"

  files_list_parser "${files}"
}

main "$@"