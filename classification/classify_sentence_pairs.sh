#!/bin/sh

EXPERIMENT=${1:-"bicleaner_v1.1"}
TRAINING_METADATA_DIR=${2:-"../data/language_packs/en-de"}

OUTPUT_DIR="./output/$EXPERIMENT"

TO_BE_CLASSIFIED_DATA="../hardrules/output/$EXPERIMENT/data_hardrules_filtered"

mkdir -p $OUTPUT_DIR

bicleaner-classify  \
        $TO_BE_CLASSIFIED_DATA  \
        $OUTPUT_DIR/data_classified  \
        $TRAINING_METADATA_DIR/en-de.yaml

python extract_corpora_and_scores.py $OUTPUT_DIR

rm $OUTPUT_DIR/data_classified
