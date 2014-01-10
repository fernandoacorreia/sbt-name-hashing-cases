#!/bin/bash
#
# Runs tests.
#
set -o nounset -o errexit

test() {
	local test_name=$1
  local result_file="results/$test_name.txt"
  echo "tail -f $result_file for progress"
  "tests/test-sbt-incremental-$test_name.sh" > $result_file
}

test securesocial
test zentasks
test play2.2-subproject
