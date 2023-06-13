#!/bin/bash -e

function usage() {
    cat <<tac
Usage: $0 TAG [OPTION] FILE [LABEL]

Create release on GitHub with TAG or modify existing release adding FILE asset with a display LABEL
  -t, --title TITLE       TITLE of the GitHub Release
  -h, --help               print this help message and exit

Examples:
  $0 v1.0 ./LFD113x-RU/RISC-V_Toolchain_and_Compiler_Optimization_Techniques.pdf "Инструментарий и компиляторные оптимизации для RISC-V"
tac
}

# Parse arguments
TAG="$1"

if [ "$TAG" == "" ]; then
    echo "Git tag is required"
    usage
    exit 1
fi
shift

FILE=""

while [ "$1" != "" ]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -t|--title)
            TITLE="$2"
            if [ "$TITLE" == "" ]; then
                echo "No title specified"
                usage
                exit 1
            fi
            shift 2
            ;;
        -*)
            echo "Unknown option $1"
            usage
            exit 1
            ;;
        *)
            if [ -f "$1" ] ; then
                FILE=$(realpath "$1")
            else
                echo "Cannot upload $1"
                usage
                exit 1
            fi
            if [ "$2" != "" ]; then
                FILE="$FILE#$2"
            fi
            break
            ;;
    esac
done

gh release create "$TAG" -t "$TITLE" "$FILE" \
    || gh release upload --clobber "$TAG" "$FILE"
