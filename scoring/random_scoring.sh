#!/bin/sh

data=${1:-"../data/official_shared_task_data/corpus"}
experiment=${2:-"random"}

cp $data.en ./output/$experiment/filtered_data_raw.en
cp $data.de ./output/$experiment/filtered_data_raw.de

python random_scoring.py $experiment $data
