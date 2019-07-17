#!/bin/bash

set -e

. ./config.sh

bpe_operations=49500

mkdir -p $data_dir
mkdir -p $model_dir

ln -s $mono_train.$LANG $data_dir/train.txt.$LANG
ln -s $mono_dev.$LANG $data_dir/dev.txt.$LANG

# tokenize
for prefix in train dev
 do
  $moses_scripts/scripts/tokenizer/normalize-punctuation.perl $LANG < $data_dir/$prefix.txt.$LANG \
    | $moses_scripts/scripts/tokenizer/tokenizer.perl -a -l $LANG  > $data_dir/$prefix.tok.$LANG
 done

# train truecaser
$moses_scripts/scripts/recaser/train-truecaser.perl -model $data_dir/truecase-model.$LANG -corpus $data_dir/train.tok.$LANG

# truecase
for prefix in train dev
 do
  $moses_scripts/scripts/recaser/truecase.perl -model $data_dir/truecase-model.$LANG < $data_dir/$prefix.tok.$LANG > $data_dir/$prefix.tc.$LANG
 done

# train BPE
cat $data_dir/train.tc.$LANG | $subword_nmt/learn_bpe.py -s $bpe_operations > $model_dir/$LANG.bpe

# apply BPE
$subword_nmt/apply_bpe.py -c "$model_dir/$LANG.bpe" < $data_dir/dev.tc.$LANG > $data_dir/dev.bpe.$LANG
$subword_nmt/apply_bpe.py -c "$model_dir/$LANG.bpe"  < $data_dir/train.tc.$LANG > $data_dir/train.bpe.$LANG

$marian/build/marian-vocab < $data_dir/train.bpe.$LANG > $model_dir/vocab.$LANG.yml
