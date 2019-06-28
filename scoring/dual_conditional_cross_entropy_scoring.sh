#!/bin/sh

SRC=en
TRG=de

parallel_data=../filtering/output/corpus_fasttext_filtered

experiment=fasttext_filtered_dcce_scoring

GPUS="0"

./conditional_cross_entropy_scoring.sh $SRC $TRG $GPUS $experiment $parallel_data
./conditional_cross_entropy_scoring.sh $SRC $TRG $GPUS $experiment $parallel_data

cp $parallel_data.* ./output/$experiment/$parallel_data.*

python calculate_dcce_adq_score.py $experiment $parallel_data
