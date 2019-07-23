#!/bin/sh

marian=/fs/bil0/abdel/marian
marian_scorer=$marian/build/marian-scorer

model=$1

src_sentence=$2
trg_sentence=$3

src_vocab=$4
trg_vocab=$5

$marian_scorer \
    -m $model \
    -v $src_vocab $trg_vocab \
    -t $src_sentence $trg_sentence \
    --devices 0 \
    --quiet-translation \
    -n
