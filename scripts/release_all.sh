#!/bin/bash -e

BASEDIR=$(dirname "$(realpath "$0")")
ROOTDIR=$(realpath "$BASEDIR/..")

COURSES="$ROOTDIR/Courses.csv"

function usage() {
    cat <<tac
Usage: $0 TAG [OPTION]... [TITLE]

Create release on GitHub with TAG or modify existing release adding all built courses.
If release doesn't exist and TITLE isn't set, TAG will use as TITLE.
  -d, --dir DIRECTORY      name of the DIRECTORY contains release assets
  -s, --suffix SUFFIX      SUFFIX of the filenames
  -h, --help               print this help message and exit


Examples:
  $0 v1.0
  $0 v1.0 "New Release v1.0"
tac
}

function get_info() {
    echo "$1" | cut -d ',' -f "$2"
}

# Parse arguments
TAG="$1"

if [ "$TAG" == "" ]; then
    echo "Git tag is required"
    usage
    exit 1
fi

BUILDDIR=""
SUFFIX=""
TITLE=""

while [ "$1" != "" ]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -s|--suffix)
            SUFFIX="$2"
            if [ "$SUFFIX" == "" ]; then
                echo "No suffix specified"
                usage
                exit 1
            fi
            shift 2
            ;;
        -o|--out-dir)
            BUILDDIR="$2"
            if [ "$BUILDDIR" == "" ]; then
                echo "No output directory specified"
                usage
                exit 1
            fi
            shift 2
            ;;
        -*)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
        *)
            TITLE="$1"
            break
            ;;
    esac
done

if [ "$TITLE" == "" ]; then
    TITLE="$TAG"
fi

if [ "$BUILDDIR" == "" ]; then
    BUILDDIR="build"
fi
BUILDDIR="$ROOTDIR/$BUILDDIR"

if [ "$SUFFIX" != "" ]; then
    SUFFIX="_$SUFFIX"
fi

# Release all files in build directory
while IFS="" read -r line || [ -n "$line" ]
do
  OUT_FILENAME="$(get_info "$line" 2)$SUFFIX.pdf"
  LABEL=$(get_info "$line" 3)

  "$BASEDIR/release_file.sh" "$TAG" -t "$TITLE" "$BUILDDIR/$OUT_FILENAME" "$LABEL"
done < "$COURSES"
