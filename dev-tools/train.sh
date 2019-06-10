#!/bin/bash -v

. ./local-settings.sh

# kick off training
$marian/build/marian \
        --sync-sgd \
        --model model/model.npz \
        -T . \
        --devices $GPU \
        --train-sets data/train.bpe.de data/train.bpe.en \
        --vocabs data/train.bpe.de.json data/train.bpe.en.json \
        --mini-batch-fit -w 3000 \
        --dim-vocabs 50000 50000 \
        --layer-normalization --dropout-rnn 0.2 --dropout-src 0.1 --dropout-trg 0.1 \
        --learn-rate 0.0001 \
        --after-epochs 0 \
        --early-stopping 5 \
        --valid-freq 20000 --save-freq 20000 --disp-freq 2000 \
        --valid-mini-batch 8 \
        --valid-sets data/dev.bpe.de data/dev.bpe.en \
        --valid-metrics cross-entropy perplexity translation \
        --valid-translation-output model/dev.out \
        --valid-script-path ./score-dev.sh \
        --seed 1111 --exponential-smoothing \
        --normalize=1 --beam-size=12 --quiet-translation \
        --log model/train.log --valid-log model/valid.log
