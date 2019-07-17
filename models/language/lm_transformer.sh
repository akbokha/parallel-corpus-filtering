#!/bin/bash

set -e

. ./config.sh

GPUS=$1

MARIAN=$marian/build
MARIAN_TRAIN=$MARIAN/marian
MARIAN_DECODER=$MARIAN/marian-decoder
MARIAN_VOCAB=$MARIAN/marian-vocab
MARIAN_SCORER=$MARIAN/marian-scorer

$MARIAN_TRAIN \
    --model $model_dir/model.npz \
    --type lm-transformer --dim-emb 128 --dim-rnn 256 \
    --train-sets $data_dir/train.bpe.$LANG \
    --vocabs "$model_dir/vocab.$LANG.yml" \
    --mini-batch-fit -w $work_space_size \
    --valid-freq 1000 --save-freq 1000 --disp-freq 100 \
    --valid-metrics perplexity cross-entropy ce-mean-words \
    --valid-sets $data_dir/dev.bpe.$LANG \
    --valid-mini-batch 32 \
    --early-stopping 5 --cost-type=ce-mean \
    --log $model_dir/train.log --valid-log $model_dir/valid.log \
    --devices $GPUS --seed 1111
