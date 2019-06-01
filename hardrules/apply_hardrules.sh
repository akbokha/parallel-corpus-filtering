#!/bin/sh

PARALLEL_DATA="../data/official_shared_task_data/data"

mkdir -p output

bicleaner-hardrules -s en -t de $PARALLEL_DATA ./output/data_hardrules

python filter_hardrules.py
