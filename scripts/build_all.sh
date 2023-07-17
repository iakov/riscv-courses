#!/bin/bash -e

BASEDIR=$(dirname "$(realpath "$0")")
ROOTDIR=$(realpath "$BASEDIR/..")

COURSES="$ROOTDIR/Courses.csv"

function usage() {
    cat <<tac
Usage: $0 [OPTION]...

Build artifacts of the all courses
  -h, --help               print this help message and exit
  -o, --out-dir DIRECTORY  name of the DIRECTORY for all built artifacts
  -s, --suffix SUFFIX      SUFFIX for output filename

Examples:
  $0
  $0 -o 'build' -s 'v1.0'
tac
}

function get_info() {
    echo "$1" | cut -d ',' -f "$2"
}

# Parse arguments
BUILDDIR=""
SUFFIX=""

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
            echo "Unexpected argument: $1"
            usage
            exit 1
            ;;
    esac
done

if [ "$BUILDDIR" == "" ]; then
    BUILDDIR="build"
fi
BUILDDIR="$ROOTDIR/$BUILDDIR"
mkdir -p "$BUILDDIR"

if [ "$SUFFIX" != "" ]; then
    SUFFIX="_$SUFFIX"
fi

# Build all courses
while IFS="" read -r line || [ -n "$line" ]
do
  COURSE_NAME=$(get_info "$line" 1)
  OUT_FILENAME="$(get_info "$line" 2)$SUFFIX"

  "$BASEDIR/build_course.sh" -o "$BUILDDIR/$OUT_FILENAME" "$COURSE_NAME"
    
done < "$COURSES"
