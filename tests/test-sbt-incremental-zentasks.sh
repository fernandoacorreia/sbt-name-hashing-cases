#!/bin/bash
#
# Tests sbt 0.13.2.M1 incremental compilation with zentasks project.
#
set -o nounset -o errexit

source tests/common.sh
set_sedi

test_change1() {
  $sedi '/def index = IsAuthenticated { username => _ =>/ a\
  val changed = true
' app/controllers/Projects.scala
  echo ""
  echo "After change to controller"
  git diff
  echo ""
  play -Dsbt.log.noformat=true compile
}

test_change2() {
  echo "GET /changed controllers.Projects.index" >> conf/routes
  echo ""
  echo "After change to routes"
  git diff
  echo ""
  play -Dsbt.log.noformat=true compile
}

test() {
  local version=$1
  echo "sbt.version=$version" > project/build.properties

  echo ""
  echo "********** Testing with `cat project/build.properties` **********"
  echo ""
  echo "clean compile:"
  play -Dsbt.log.noformat=true clean compile

  test_change1
  test_change2
}

run() {
  local current_time=`date +%Y%m%d-%H%M%S`
  local tmp_dir="/tmp/$current_time"
  mkdir -p "$tmp_dir"
  cd "$tmp_dir"

  git clone --quiet "$repository" repo
  cd repo
  git checkout --quiet "$commit" > /dev/null
  cd "$project_subdir"

  test "0.13.1"

  git reset --hard --quiet
  echo "" >> build.sbt
  echo "incOptions := incOptions.value.withNameHashing(true)" >> build.sbt
  test "0.13.2-M1"
}

repository="https://github.com/playframework/playframework.git"
commit="4db4de7e9d35d1b9aea5c1f27cefbde025a7db8f"
project_subdir="samples/scala/zentasks"

run
