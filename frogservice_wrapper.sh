#!/bin/sh

set -e

skip=
outputdir=$(realpath .)
outputformat=xml

FROG_OPTS=""

while getopts "TLACMNPx:o" opt; do
    case $opt in
        T) skip="${skip}t";;
        L) skip="${skip}l";;
        A) skip="${skip}a";;
        C) skip="${skip}c";;
        M) skip="${skip}m";;
        N) skip="${skip}n";;
        P) skip="${skip}p";;
        o) outputformat=$OPTARG;;
        :) printf 'Option -%s requires an argument\n' "$OPTARG" >&2;
           exit 2 ;;
        *) printf 'Invalid option %s' "$OPT" >&2; exit 2 ;;
    esac
done
shift "$((OPTIND - 1))"

if [ -n "$skip" ]; then
    FROG_OPTS="$FROG_OPTS --skip=$skip"
fi

if [ -z "$outputdir" ]  || [ ! -d "$outputdir" ]; then
    echo "ERROR: Outputdir not provided or does not exist">&2
    exit 2
fi

if [ -d inputtxt ]; then
    echo "Processing plain text input files...">&2
    # shellcheck disable=SC2086
    if [ "$outputformat" = "xml" ]; then
        frog $FROG_OPTS --nostdout --testdir inputtxt --xmldir=. $FROG_OPTS
    else
        frog $FROG_OPTS --testdir inputtxt --outputdir=. $FROG_OPTS
    fi
fi

if [ -d inputxml ]; then
    echo "Processing FoLiA XML input files...">&2
    # shellcheck disable=SC2086
    if [ "$outputformat" = "xml" ]; then
        frog $FROG_OPTS --nostdout -x inputxml --xmldir=. $FROG_OPTS
    else
        frog $FROG_OPTS -x inputxml --outputdir=. $FROG_OPTS
    fi
fi

set +e

#rename output *.out files to tsv
for f in *.out; do
    [ "$f" != "*.out" ] && mv "$f" "${f%%.*}.tsv"
done

#rename output *.xml files
for f in *.xml; do
    [ "$f" != "*.xml" ] && mv "$f" "${f%%.*}.folia.xml"
done

echo "Done...">&2

