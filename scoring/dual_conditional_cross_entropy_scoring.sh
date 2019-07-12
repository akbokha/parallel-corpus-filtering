#!/bin/sh

SRC=en
TRG=de

parallel_data="../filtering/output/corpus_fasttext_prob_and_len_filtered"

experiment="fasttext_prob_and_len_dcce_scoring"

GPUS="1"

./conditional_cross_entropy_scoring.sh $SRC $TRG "$GPUS" $experiment $parallel_data
./conditional_cross_entropy_scoring.sh $TRG $SRC "$GPUS" $experiment $parallel_data

cp $parallel_data.* output/$experiment/

python calculate_dcce_adq_score.py $experiment $parallel_data
