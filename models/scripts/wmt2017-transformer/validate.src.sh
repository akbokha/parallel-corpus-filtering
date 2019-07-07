#!/bin/bash

. ./config.sh

SRC=$1
data_dir=$2

cat $1 \
    | sed 's/\@\@ //g' \
    | $moses_scripts/scripts/recaser/detruecase.perl 2>/dev/null \
    | $moses_scripts/scripts/tokenizer/detokenizer.perl -l $SRC 2>/dev/null \
    | $moses_scripts/scripts/generic/multi-bleu-detok.perl $data_dir/valid.$SRC \
    | sed -r 's/BLEU = ([0-9.]+),.*/\1/'
