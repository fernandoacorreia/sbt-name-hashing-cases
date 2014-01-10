# Common shell functions.

# Sets variable sedi with the proper sed in-place command for Linux or OS X.
# http://stackoverflow.com/a/20951570/376366
set_sedi () {
  darwin=false;
  case "`uname`" in
    Darwin*) darwin=true ;;
  esac

  if $darwin; then
    sedi="sed -i ''"
  else
    sedi="sed -i"
  fi
  export sedi
}
