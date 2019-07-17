#!/bin/bash -v

set -e

. ./config.sh

# suffix of source language files
SRC=$1

# suffix of target language files
TRG=$2

# path to the model and data directories
data_dir=$3
model_dir=$4

# number of merge operations
bpe_operations=32000

# tokenize
for prefix in test2017
do
    corpus_dir=$([ "$prefix" == corpus ] && echo "data" || echo "$data_dir")
    cat $corpus_dir/$prefix.$SRC \
        | $moses_scripts/scripts/tokenizer/normalize-punctuation.perl -l $SRC \
        | $moses_scripts/scripts/tokenizer/tokenizer.perl -a -l $SRC > $data_dir/$prefix.tok.$SRC

    test -f $corpus_dir/$prefix.$TRG || continue

    cat $corpus_dir/$prefix.$TRG \
        | $moses_scripts/scripts/tokenizer/normalize-punctuation.perl -l $TRG \
        | $moses_scripts/scripts/tokenizer/tokenizer.perl -a -l $TRG > $data_dir/$prefix.tok.$TRG
done

for prefix in test2017
do
    $moses_scripts/scripts/recaser/truecase.perl -model $model_dir/tc.$SRC < $data_dir/$prefix.tok.$SRC > $data_dir/$prefix.tc.$SRC
    test -f $data_dir/$prefix.tok.$TRG || continue
    $moses_scripts/scripts/recaser/truecase.perl -model $model_dir/tc.$TRG < $data_dir/$prefix.tok.$TRG > $data_dir/$prefix.tc.$TRG
done

# apply BPE
for prefix in test2017
do
    $subword_nmt/apply_bpe.py -c $model_dir/$SRC$TRG.bpe < $data_dir/$prefix.tc.$SRC > $data_dir/$prefix.bpe.$SRC
    test -f $data_dir/$prefix.tc.$TRG || continue
    $subword_nmt/apply_bpe.py -c $model_dir/$SRC$TRG.bpe < $data_dir/$prefix.tc.$TRG > $data_dir/$prefix.bpe.$TRG
done
