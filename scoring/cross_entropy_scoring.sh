#!/bin/sh

LANG=${1:-"en"}
CORPUS=${2:-"news-crawl"}

GPU=${3:-"0"}
parallel_data=${4:-"../filtering/corpus_fasttext_filtered"}

experiment=${5:-"ced"}

# path to marian
marian=/fs/bil0/abdel/marian

marian_scorer=$marian/build/marian-scorer

model_dir="../models/language/models/lm-transformer-$CORPUS-$LANG"/model

output_dir=output/$experiment
mkdir -p $output_dir

BEST=`cat $model_dir/valid.log | grep perplexity | sort -rg -k12,12 -t' ' | cut -f8 -d' ' | tail -n1`

$marian_scorer \
    -m $model_dir/model.iter$BEST.npz \
    -v "$model_dir/vocab.$LANG.yml" \
    -t $parallel_data.$LANG \
    --devices $GPU \
    -n  > $output_dir/"$CORPUS"_"$LANG"_ced_scores.txt
