#!/bin/sh

CLASSIFIED_DATA_DIR=${1:-"../classification/output"}
OUTPUT_NAME=${2:-"parallel_corpus"}

mkdir -p output

perl subselect.perl  \
    $CLASSIFIED_DATA_DIR/filtered_data_scores  \
    $CLASSIFIED_DATA_DIR/filtered_data_raw.de  \
    $CLASSIFIED_DATA_DIR/filtered_data_raw.en  \
    ./output/$OUTPUT_NAME
