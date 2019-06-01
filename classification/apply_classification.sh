#!/bin/sh

TRAINING_METADATA_DIR=${1:-"../data/language_packs/en-de"}
TO_BE_CLASSIFIED_DATA=${2:-"../hardrules/output/data_filtered_hardrules"}
OUTPUT_NAME=${3:-"data_classified"}

mkdir -p output

bicleaner-classify  \
        $TO_BE_CLASSIFIED_DATA  \
        ./output/$OUTPUT_NAME  \
        $TRAINING_METADATA_DIR/en-de.yaml
