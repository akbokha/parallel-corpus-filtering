#!/bin/sh

marian=/fs/bil0/abdel/marian-dev
marian_scorer=$marian/build/marian-scorer

model=$1

sentences=$2

vocab=$3

gpus=$4

$marian_scorer \
    -m $model \
    -v $vocab \
    -t $sentences \
    --devices "$gpus" \
    --workspace 4096 \
    --quiet
