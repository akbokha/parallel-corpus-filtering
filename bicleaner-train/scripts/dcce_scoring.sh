#!/bin/sh

marian=/fs/bil0/abdel/marian
marian_scorer=$marian/build/marian-scorer

model=$1

src_sentences=$2
trg_sentences=$3

src_vocab=$4
trg_vocab=$5

gpus=$6

$marian_scorer \
    -m $model \
    -v $src_vocab $trg_vocab \
    -t $src_sentences $trg_sentences \
    --devices "$gpus" \
    --quiet-translation \
    -n
