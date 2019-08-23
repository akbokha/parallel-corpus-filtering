#!/bin/bash -v

. ./local-settings.sh

if [ $# -ne 0 ]
then
    experiment=$1
    data_dir=../experiments/$experiment/data
    model_dir=../experiments/$experiment/model
    GPU=$2
fi

cp -p ./score-dev.sh ../experiments/$experiment/score-dev.sh
rel_dirs=$"data_dir=$data_dir\nmodel_dir=$model_dir"

sed -i "4i$rel_dirs" ../experiments/$experiment/score-dev.sh

# kick off training
$marian/build/marian \
        --sync-sgd \
        --model $model_dir/model.npz \
        -T . \
        --devices $GPU \
        --train-sets $data_dir/train.bpe.de $data_dir/train.bpe.en \
        --vocabs $data_dir/train.bpe.de.json $data_dir/train.bpe.en.json \
        --mini-batch-fit -w 5000 \
        --dim-vocabs 50000 50000 \
        --layer-normalization --dropout-rnn 0.1 \
        --learn-rate 0.0003 \
        --lr-decay-inv-sqrt 16000 \
        --after-epochs 0 \
        --early-stopping 5 \
        --valid-freq 5000 --save-freq 5000 --disp-freq 1000 \
        --valid-mini-batch 8 \
        --valid-sets $data_dir/dev.bpe.de $data_dir/dev.bpe.en \
        --valid-metrics cross-entropy perplexity translation \
        --valid-translation-output $model_dir/dev.out \
        --valid-script-path ../experiments/$experiment/score-dev.sh \
        --seed 1111 --exponential-smoothing \
        --normalize=1 --beam-size=12 --quiet-translation \
        --log $model_dir/train.log --valid-log $model_dir/valid.log
