#!/bin/bash
#
# Tests sbt 0.13.2.M1 incremental compilation with play2.2-subproject project.
#
set -o nounset -o errexit

test_change1() {
  git apply - <<EOF
diff --git a/modules/manager/app/controllers/html/StaticPages.java b/modules/manager/app/controllers/html/StaticPages.java
index 7bcce9e..8f198e4 100644
--- a/modules/manager/app/controllers/html/StaticPages.java
+++ b/modules/manager/app/controllers/html/StaticPages.java
@@ -7,6 +7,7 @@ import utils.ExampleLogger;
 public class StaticPages extends Controller {
 
     public static Result index() {
+        ExampleLogger.log("changed");
     	ExampleLogger.log("Log from the manager using the Common logger");
         return ok("Hi from the manager.");
     }

EOF
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

  git apply - <<EOF
diff --git a/project/plugins.sbt b/project/plugins.sbt
index ce40944..a815558 100644
--- a/project/plugins.sbt
+++ b/project/plugins.sbt
@@ -5,4 +5,4 @@ logLevel := Level.Warn
 resolvers += "Typesafe repository" at "http://repo.typesafe.com/typesafe/releases/"
 
 // Use the Play sbt plugin for Play projects
-addSbtPlugin("com.typesafe.play" % "sbt-plugin" % "2.2.0")
\ No newline at end of file
+addSbtPlugin("com.typesafe.play" % "sbt-plugin" % System.getProperty("play.version"))
\ No newline at end of file
EOF

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
