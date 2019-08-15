#!/bin/sh

PARALLEL_DATA="news-commentary-v14.de-en.tsv"
OUTPUT_DIR=hardrules_output_nc
mkdir -p $OUTPUT_DIR

bicleaner-hardrules \
    --annotated_output $OUTPUT_DIR/data_hardrules_annotated \
    -s en -t de $PARALLEL_DATA

cut -f 1 $OUTPUT_DIR/data_hardrules_annotated > $OUTPUT_DIR/noisy_sentences.de
cut -f 2 $OUTPUT_DIR/data_hardrules_annotated > $OUTPUT_DIR/noisy_sentences.en
