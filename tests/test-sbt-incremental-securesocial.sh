#!/bin/bash
#
# Tests sbt 0.13.2.M1 incremental compilation with SecureSocial project.
#
set -o nounset -o errexit

test_change() {
  sed -i '' '/object Registration extends Controller {/ a\
  val changed = true
' app/securesocial/controllers/Registration.scala
  echo ""
  echo "After change to controller"
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

  test_change
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

  test "0.13.0"

  git reset --hard --quiet
  echo "incOptions := incOptions.value.withNameHashing(true)" >> build.sbt
  test "0.13.2-M1"
}

repository="https://github.com/jaliss/securesocial.git"
commit="9979432063f30cc7c27c3ec792abbf3aad224ab2"
project_subdir="module-code"

run
