# ================================================
# Console outputs
# http://stackoverflow.com/questions/2990414/echo-that-outputs-to-stderr
# ================================================

writeStdErr() {
  cat <<< "$*" 1>&2
  return
}

writeStdErrAnnotated() {
  local script="$1"
  local lineNo=$2
  local color=$3
  local type=$4
  shift; shift; shift; shift

  witeStdErr "${color}[${type}] ${Blu}[${script}:${lineNo}]${RCol} $* "
}
