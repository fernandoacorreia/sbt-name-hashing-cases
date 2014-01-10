#!/bin/bash
#
# Tests sbt 0.13.2.M1 incremental compilation with play2.2-subproject project.
#
set -o nounset -o errexit

test_change1() {
  sed -i '' '/public static Result index() {/ a\
      ExampleLogger.log("changed");
' modules/manager/app/controllers/html/StaticPages.java
  echo ""
  echo "After change to controller"
  git diff
  echo ""
  play -Dsbt.log.noformat=true compile
}

test_change2() {
  echo "GET /changed controllers.html.StaticPages.index()" >> modules/manager/conf/manager.routes
  echo ""
  echo "After change to routes"
  git diff
  echo ""
  play -Dsbt.log.noformat=true compile
}

test() {
  local version=$1
  echo "sbt.version=$version" > project/build.properties

  sed -i '' 's/2.2.0/2.2.1/' project/plugins.sbt

  echo ""
  echo "********** Testing with `cat project/build.properties` **********"
  echo ""
  echo "clean compile:"
  play -Dsbt.log.noformat=true clean compile

  test_change1
  test_change2
}

setincOptions() {
  local file=$1
  echo -e "\n\nincOptions := incOptions.value.withNameHashing(true)\n" >> "$file"
}

run() {
  local current_time=`date +%Y%m%d-%H%M%S`
  local tmp_dir="/tmp/$current_time"
  mkdir -p "$tmp_dir"
  cd "$tmp_dir"

  git clone --quiet "$repository" repo
  cd repo
  git checkout --quiet "$commit" > /dev/null

  test "0.13.0"

  git reset --hard --quiet
  setincOptions build.sbt
  setincOptions modules/api/build.sbt
  setincOptions modules/common/build.sbt
  setincOptions modules/manager/build.sbt
  test "0.13.2-M1"
}

repository="https://github.com/cnicodeme/play2.2-subproject.git"
commit="dbeac165ef39ceed4f2243156fd8b88eed37c235"

run
