#!/bin/bash -v

set -e

. ./config.sh

# suffix of target language files
SRC=$1
TRG=$2

# path to the model and data directories
data_dir=$3
model_dir=$4

# tokenize

prefix=news.2016

cat $data_dir/$prefix.$TRG \
    | $moses_scripts/scripts/tokenizer/normalize-punctuation.perl -l $TRG \
    | $moses_scripts/scripts/tokenizer/tokenizer.perl -a -l $TRG > $data_dir/$prefix.tok.$TRG

$moses_scripts/scripts/recaser/truecase.perl -model $model_dir/tc.$TRG < $data_dir/$prefix.tok.$TRG > $data_dir/$prefix.tc.$TRG

$subword_nmt/apply_bpe.py -c $model_dir/$SRC$TRG.bpe < $data_dir/$prefix.tc.$TRG > $data_dir/$prefix.bpe.$TRG
