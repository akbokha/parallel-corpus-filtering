#!/bin/bash

. ./config.sh

TRG=$1
data_dir=models/wmt1M-random-de-en/data
SRC=de
TRG=en

data_dir=$2

cat $1 \
    | sed 's/\@\@ //g' \
    | $moses_scripts/scripts/recaser/detruecase.perl 2>/dev/null \
    | $moses_scripts/scripts/tokenizer/detokenizer.perl -l $TRG 2>/dev/null \
    | $moses_scripts/scripts/generic/multi-bleu-detok.perl $data_dir/valid.$TRG \
    | sed -r 's/BLEU = ([0-9.]+),.*/\1/'
