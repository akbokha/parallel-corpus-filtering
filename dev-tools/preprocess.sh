#!/bin/bash -v

. ./local-settings.sh

# suffix of source language files
SRC=de

# suffix of target language files
TRG=en

# number of merge operations. Network vocabulary should be slightly larger (to include characters),
# or smaller if the operations are learned on the joint vocabulary
bpe_operations=49500

data_dir=experiments/$experiment/data
model_dir=experiments/$experiment/model

mkdir -p $data_dir
mkdir -p $model_dir

# extract dev/test from xml
$mosesdecoder/scripts/ems/support/input-from-sgm.perl < $devset/newstest2016-deen-ref.en.sgm > $data_dir/dev.txt.en
$mosesdecoder/scripts/ems/support/input-from-sgm.perl < $devset/newstest2016-deen-src.de.sgm > $data_dir/dev.txt.de
$mosesdecoder/scripts/ems/support/input-from-sgm.perl < $devset/newstest2017-deen-ref.en.sgm > $data_dir/test.txt.en
$mosesdecoder/scripts/ems/support/input-from-sgm.perl < $devset/newstest2017-deen-src.de.sgm > $data_dir/test.txt.de
ln -s $my_corpus_stem.de $data_dir/train.txt.de
ln -s $my_corpus_stem.en $data_dir/train.txt.en

# tokenize
for prefix in train dev test
 do
  $mosesdecoder/scripts/tokenizer/normalize-punctuation.perl $SRC < $data_dir/$prefix.txt.$SRC \
    | $mosesdecoder/scripts/tokenizer/tokenizer.perl -a -l $SRC  > $data_dir/$prefix.tok.$SRC
  $mosesdecoder/scripts/tokenizer/normalize-punctuation.perl $TRG < $data_dir/$prefix.txt.$TRG \
    | $mosesdecoder/scripts/tokenizer/tokenizer.perl -a -l $TRG  > $data_dir/$prefix.tok.$TRG
 done

# clean empty and long sentences, and sentences with high source-target ratio (training corpus only)
$mosesdecoder/scripts/training/clean-corpus-n.perl $data_dir/train.tok $SRC $TRG $data_dir/train.clean.tok 1 80

# train truecaser
$mosesdecoder/scripts/recaser/train-truecaser.perl -model $data_dir/truecase-model.$SRC -corpus $data_dir/train.clean.tok.$SRC
$mosesdecoder/scripts/recaser/train-truecaser.perl -model $data_dir/truecase-model.$TRG -corpus $data_dir/train.clean.tok.$TRG

# truecase
for prefix in train.clean dev test
 do
  $mosesdecoder/scripts/recaser/truecase.perl -model $data_dir/truecase-model.$SRC < $data_dir/$prefix.tok.$SRC > $data_dir/$prefix.tc.$SRC
  $mosesdecoder/scripts/recaser/truecase.perl -model $data_dir/truecase-model.$TRG < $data_dir/$prefix.tok.$TRG > $data_dir/$prefix.tc.$TRG
 done

# train BPE
cat $data_dir/train.clean.tc.$SRC $data_dir/train.clean.tc.$TRG | $subword_nmt/learn_bpe.py -s $bpe_operations > $model_dir/$SRC$TRG.bpe

# apply BPE
$subword_nmt/apply_bpe.py -c $model_dir/$SRC$TRG.bpe < $data_dir/dev.tc.$SRC > $data_dir/dev.bpe.$SRC
$subword_nmt/apply_bpe.py -c $model_dir/$SRC$TRG.bpe < $data_dir/dev.tc.$TRG > $data_dir/dev.bpe.$TRG
$subword_nmt/apply_bpe.py -c $model_dir/$SRC$TRG.bpe < $data_dir/test.tc.$SRC > $data_dir/test.bpe.$SRC
$subword_nmt/apply_bpe.py -c $model_dir/$SRC$TRG.bpe < $data_dir/test.tc.$TRG > $data_dir/test.bpe.$TRG
$subword_nmt/apply_bpe.py -c $model_dir/$SRC$TRG.bpe < $data_dir/train.clean.tc.$SRC > $data_dir/train.bpe.$SRC
$subword_nmt/apply_bpe.py -c $model_dir/$SRC$TRG.bpe < $data_dir/train.clean.tc.$TRG > $data_dir/train.bpe.$TRG

# build network dictionary
./build_dictionary.py $data_dir/train.bpe.$SRC $data_dir/train.bpe.$TRG
