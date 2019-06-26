#!/bin/sh

PARALLEL_DATA="../data/official_shared_task_data/data"

EXPERIMENT=${1:-"bicleaner_v1.1"}
OUTPUT_DIR="./output/$EXPERIMENT"

mkdir -p $OUTPUT_DIR

bicleaner-hardrules --annotated_output $OUTPUT_DIR/data_hardrules_annotated  -s en -t de $PARALLEL_DATA $OUTPUT_DIR/data_hardrules

python filter_hardrules.py $OUTPUT_DIR

rm $OUTPUT_DIR/data_hardrules
rm $OUTPUT_DIR/data_hardrules_annotated
