#!/bin/sh

SRC=${1:-"en"}
TRG=${2:-"de"}

# path to marian
marian=/fs/bil0/abdel/marian

marian_scorer=$marian/build/marian-scorer

GPU="5"

parallel_data=../filtering/output/corpus_fasttext_filtered

model_dir="../models/translation/models/transformer-model-$SRC-$TRG"/model

output_dir=output
mkdir -p $output_dir

BEST=`cat $model_dir/valid.log | grep bleu | sort -rg -k12,12 -t' ' | cut -f8 -d' ' | head -n1`

$marian_scorer \
    -m $model_dir/model.iter$BEST.npz \
    -v $model_dir/vocab.ende.yml $model_dir/vocab.ende.yml \
    -t $parallel_data.$SRC $parallel_data.$TRG \
    --devices $GPU \
    -n  > $output_dir/"$SRC"_"$TRG"_ce_normalized_scores.txt

