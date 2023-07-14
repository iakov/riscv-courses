#!/bin/bash -e

BASEDIR=$(dirname "$(realpath "$0")")
ROOTDIR=$(realpath "$BASEDIR/..")

function usage() {
    cat <<tac
Usage: $0 [OPTION] COURSE_NAME

Build artifacts of the course with COURSE_NAME
  -o, --out FILENAME       output FILENAME without extension
  -c, --conv CONVERTER     which CONVERTER to use (asciidoctor or pandoc)
  -h, --help               print this help message and exit

Examples:
  $0 LFD113x-RU
  $0 -o 'Инструментарий_и_компиляторные_оптимизации_для_RISC-V_(LFD113x)_RU' -c asciidoctor LFD113x-RU
tac
}


# Parse arguments
COURSEDIR=""
CONVERTER=""
FILENAME=""
MAKEOPTS=()

while [ "$1" != "" ]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -o|--out)
            FILENAME=$2
            shift 2
            ;;
        -c|--conv)
            CONVERTER=$2
            shift 2
            ;;
        -*)
            echo "Unknown option $1"
            usage
            exit 1
            ;;
        *)
            if [ -d "$ROOTDIR/$1" ] ; then
                COURSEDIR=$(realpath "$ROOTDIR/$1")
                break
            else
                echo "Unknown course $1"
                usage
                exit 1
            fi
            ;;
    esac
done

if [ "$COURSEDIR" == "" ]; then
    echo "No course selected"
    usage
    exit 1
fi

if [ "$FILENAME" != "" ]; then
    MAKEOPTS+="RESULT_DOCX=${FILENAME}.docx "
    MAKEOPTS+="RESULT_PDF=${FILENAME}.pdf "
    MAKEOPTS+="RESULT_XML=${FILENAME}.xml "
fi

# Build selected course
case $CONVERTER in
    "")
        echo "No converter selected"
        usage
        exit 1
        ;;
    pandoc)
        make -C "$COURSEDIR" ${MAKEOPTS[@]} pandoc
        ;;
    asciidoctor)
        make -C "$COURSEDIR" ${MAKEOPTS[@]} asciidoctor
        ;;
    *)
        echo "Unknown converter ${CONVERTER}"
        usage
        exit 1
        ;;
esac
