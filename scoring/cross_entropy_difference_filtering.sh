#!/bin/sh

parallel_data=../filtering/output/corpus_fasttext_prob_and_len_filtered
experiment=fasttext_prob_and_len_filtered_ced_scoring
lang=en
cut_off_value=0.25
GPUS="0 1"

./cross_entropy_scoring.sh $lang news-crawl $GPUS $parallel_data $experiment
./cross_entropy_scoring.sh $lang paracrawl $GPUS $parallel_data $experiment

cp $parallel_data.* ./output/$experiment/$parallel_data.*

python calculate_ced_dom_score.py $experiment $parallel_data $cut_off_value
