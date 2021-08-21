#!/bin/bash
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
#
# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# For more information, please refer to <https://unlicense.org>


# Build options
OPT_INCLUDE_DEPENDENCIES=1
OPT_OUT="build/output.jar"
OPT_MAIN="null"

# Dependency options
OPT_DEPENDENCY_FILE="dependencies.txt"
OPT_DEPENDENCY_DIR="lib"
OPT_DOWNLOAD_DEPENDENCIES=0
OPT_DOWNLOAD=1

# Log options
OPT_QUIET=0
OPT_DEBUG=0

# Misc options
OPT_HELP=0
OPT_VERSION=0

# Parse options
while (( "$#" )); do
  case "$1" in
    --include-dependencies) # OPT_INCLUDE_DEPENDENCIES
      OPT_INCLUDE_DEPENDENCIES=1
      shift
      ;;

    --exclude-dependencies) # OPT_INCLUDE_DEPENDENCIES
      OPT_INCLUDE_DEPENDENCIES=0
      shift
      ;;

    -o|--out|--outfile|--jar) # OPT_OUT
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        OPT_OUT=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    
    -m|--main|--main-class) # OPT_MAIN
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        OPT_MAIN=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    
    --dependencies|--dependency-file|--dependencies-file) # OPT_DEPENDENCY_FILE
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        OPT_DEPENDENCY_FILE=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;

    -l|--libs|--libraries|--dependency-dir) # OPT_DEPENDENCY_DIR
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        OPT_DEPENDENCY_DIR=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
      
    
    --download-dependencies) # OPT_DOWNLOAD_DEPENDENCIES
      OPT_DOWNLOAD_DEPENDENCIES=1
      shift
      ;;
    
    --download) # OPT_DOWNLOAD
      OPT_DOWNLOAD=1
      shift
      ;;

    --no-download) # OPT_DOWNLOAD
      OPT_DOWNLOAD=0
      shift
      ;;

    -q|--quiet) # OPT_QUIET
      OPT_QUIET=0
      shift
      ;;
    
    -d|--debug|--verbose) # OPT_DEBUG
      OPT_DEBUG=0
      shift
      ;;

    -h|-help|--help) # OPT_HELP
      OPT_HELP=1
      shift
      ;;
    -v|-version|--version) # OPT_VERSION
      OPT_VERSION=1
      shift
      ;;

    *) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
  esac
done

function outputVersion {
  echo "Build script version: 1.0.0"
  javac -version
  jar --version
}

function outputHelp {
  echo "usage: $0 [OPTIONS]                                                                     "
  echo "                                                                                        "
  echo "Options:                                                                                "
  echo "                                                                                        "
  echo "  -h, --help                            Display this screen and exit                    "
  echo "  -v, --version                         Display version information and exit            "
  echo "                                                                                        "
  echo "Logging options:                                                                        "
  echo "                                                                                        "
  echo "  -q, --quiet                           Shut up. (Do not log anything)                  "
  echo "  -d, --debug, --verbose                Log more then usual.                            "
  echo "                                                                                        "
  echo "Build options:                                                                          "
  echo "                                                                                        "
  echo "  -m, --main, --main-class              Specify main class                              "
  echo "  -o, --out, --outfile, --jar [FILE]    JAR file (default: ./build/output.jar)          "
  echo "                                                                                        "
  echo "Dependency options:                                                                     "
  echo "  --download-dependencies               Don't build, only download dependencies and exit"
  echo "                                                                                        "
  echo "  --dependencies, --dependencies-file   Dependency listing (default: ./dependencies.txt)"
  echo "    [FILE]                                                                              "
  echo "                                                                                        "
  echo "  --include-dependencies                Include dependency classes in JAR (default)     "
  echo "  --exclude-dependencies                Do not include dependency classes in JAR        "
  echo "                                                                                        "
  echo "Download options:                                                                       "
  echo "  --download                            Download dependencies (default)                 "
  echo "  --no-download                         Avoid downloading anything                      "
  echo "                                                                                        "
  exit 1
}

function initBuildDirectory {
  if find build/classes/src &> /dev/null; then
    rm -r build/classes/src
  fi
  if find build/classes/lib &> /dev/null; then
    rm -r build/classes/lib
  fi
  mkdir -p build/classes/src build/classes/lib
}

function initLibDirectory {
  if ! find lib &> /dev/null; then
    mkdir lib
  fi
}

function downloadDependencies {
  if ! find "$OPT_DEPENDENCY_FILE" &> /dev/null; then
    log "Couldn't find $OPT_DEPENDENCY_FILE"
  else
    deps=""
    for dependency in $(cat "$OPT_DEPENDENCY_FILE"); do
      filename=$(echo $dependency | grep -m 1 -Po "[^\/]+\.jar$")
      if ! find "$OPT_DEPENDENCY_DIR/$filename" &> /dev/null; then
        deps="$deps"$'\n'"$dependency"
      fi
    done

    pushdir "$OPT_DEPENDENCY_DIR"
    if [[ $deps != "" ]]; then
      for dependency in $deps; do
        filename=$(echo $dependency | grep -m 1 -Po "[^\/]+\.jar$")
        log "Downloading $filename"
      done
      if [ "$OPT_DEBUG" -eq "0" ]; then
        echo "$deps" | xargs -L 1 -P 16 wget --quiet
      else
        echo "$deps" | xargs -L 1 -P 16 wget -nv
      fi
    fi
    popdir
  fi
}

function extractDependencies {
  log "Extracting dependencies"
  pushdir build/classes/lib
  find "../../../$OPT_DEPENDENCY_DIR" | grep ".jar$" | xargs -L 1 jar xf
  find . -type f '!' -name "*.class" | xargs rm
  find -type d -empty -delete
  popdir
}

function compileClasses {
  log "Compiling classes"
  if [ "$OPT_INCLUDE_DEPENDENCIES" -eq "1" ]; then
    find . | grep .java | xargs javac -s 8 -cp "build/classes/lib" -sourcepath src -d build/classes/src
  else
    find . | grep .java | xargs javac -s 8 -sourcepath src -d build/classes/src
  fi
  if [ "$?" != "0" ]; then
    exit 1
  fi
}

function createJar {
  log "Creating JAR"
  classes="build/classes/src"
  if [ "$OPT_INCLUDE_DEPENDENCIES" -eq "1" ]; then
    classes="$classes build/classes/lib"
  fi
  if [[ "$OPT_MAIN" == "null" ]]; then
    find $classes -type f | grep ".class$" | xargs jar cf "$OPT_OUT"
  else
    find $classes -type f | grep ".class$" | xargs jar cfe "$OPT_OUT" "$OPT_MAIN"
  fi
}

function log {
  if [ "$OPT_QUIET" -eq "0" ]; then
    echo $@;
  fi
}

function pushdir {
  if [ "$OPT_DEBUG" -eq "1" ]; then
    pushd $@;
  else
    pushd $@ &> /dev/null;
  fi
}

function popdir {
  if [ "$OPT_DEBUG" -eq "1" ]; then
    popd;
  else
    popd &> /dev/null;
  fi
}

if [ "$OPT_HELP" -eq "1" ]; then
  outputHelp
  exit 0
fi

if [ "$OPT_VERSION" -eq "1" ]; then
  outputVersion
  exit 0
fi

if [ "$OPT_DOWNLOAD_DEPENDENCIES" -eq "1" ]; then
  downloadDependencies
  exit 1
fi

initBuildDirectory
initLibDirectory

if [ "$OPT_INCLUDE_DEPENDENCIES" -eq "1" ]; then
  if [ "$OPT_DOWNLOAD" -eq "1" ]; then
    downloadDependencies
  fi
  extractDependencies
fi

compileClasses
createJar

exit 0
