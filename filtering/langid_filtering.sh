#!/bin/sh

parallel_data="../data/official_shared_task_data/data"

mkdir -p output

python3 langid_filtering.py $parallel_data
