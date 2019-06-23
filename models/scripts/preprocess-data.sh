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
for prefix in corpus valid test2014 test2015 test2016
do
    cat data/$prefix.$SRC \
        | $moses_scripts/scripts/tokenizer/normalize-punctuation.perl -l $SRC \
        | $moses_scripts/scripts/tokenizer/tokenizer.perl -a -l $SRC > $data_dir/$prefix.tok.$SRC

    test -f data/$prefix.$TRG || continue

    cat data/$prefix.$TRG \
        | $moses_scripts/scripts/tokenizer/normalize-punctuation.perl -l $TRG \
        | $moses_scripts/scripts/tokenizer/tokenizer.perl -a -l $TRG > $data_dir/$prefix.tok.$TRG
done

# clean empty and long sentences, and sentences with high source-target ratio (training corpus only)
mv $data_dir/corpus.tok.$SRC $data_dir/corpus.tok.uncleaned.$SRC
mv $data_dir/corpus.tok.$TRG $data_dir/corpus.tok.uncleaned.$TRG
$moses_scripts/scripts/training/clean-corpus-n.perl $data_dir/corpus.tok.uncleaned $SRC $TRG $data_dir/corpus.tok 1 100

# train truecaser
$moses_scripts/scripts/recaser/train-truecaser.perl -corpus $data_dir/corpus.tok.$SRC -model $model_dir/tc.$SRC
$moses_scripts/scripts/recaser/train-truecaser.perl -corpus $data_dir/corpus.tok.$TRG -model $model_dir/tc.$TRG

# apply truecaser (cleaned training corpus)
for prefix in corpus valid test2014 test2015 test2016
do
    $moses_scripts/scripts/recaser/truecase.perl -model $model_dir/tc.$SRC < $data_dir/$prefix.tok.$SRC > $data_dir/$prefix.tc.$SRC
    test -f $data_dir/$prefix.tok.$TRG || continue
    $moses_scripts/scripts/recaser/truecase.perl -model $model_dir/tc.$TRG < $data_dir/$prefix.tok.$TRG > $data_dir/$prefix.tc.$TRG
done

# train BPE
cat $data_dir/corpus.tc.$SRC $data_dir/corpus.tc.$TRG | $subword_nmt/learn_bpe.py -s $bpe_operations > $model_dir/$SRC$TRG.bpe

# apply BPE
for prefix in corpus valid test2014 test2015 test2016
do
    $subword_nmt/apply_bpe.py -c $model_dir/$SRC$TRG.bpe < $data_dir/$prefix.tc.$SRC > $data_dir/$prefix.bpe.$SRC
    test -f $data_dir/$prefix.tc.$TRG || continue
    $subword_nmt/apply_bpe.py -c $model_dir/$SRC$TRG.bpe < $data_dir/$prefix.tc.$TRG > $data_dir/$prefix.bpe.$TRG
done
