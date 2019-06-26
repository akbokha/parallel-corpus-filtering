#!/bin/sh

EXPERIMENT=${1:-"bicleaner_v1.1"}
OUTPUT_NAME=${2:-"parallel_corpus"}
OUTPUT_DIR="./output/$EXPERIMENT"
CLASSIFIED_DATA_DIR="../classification/output/$EXPERIMENT"

mkdir -p $OUTPUT_DIR

perl subselect.perl  \
    $CLASSIFIED_DATA_DIR/filtered_data_scores  \
    $CLASSIFIED_DATA_DIR/filtered_data_raw.de  \
    $CLASSIFIED_DATA_DIR/filtered_data_raw.en  \
    $OUTPUT_DIR/$OUTPUT_NAME
