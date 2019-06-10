#!/bin/bash -v

. ./local-settings.sh

# suffix of source language files
SRC=de

# suffix of target language files
TRG=en

# number of merge operations. Network vocabulary should be slightly larger (to include characters),
# or smaller if the operations are learned on the joint vocabulary
bpe_operations=49500

mkdir -p data
mkdir -p model

# extract dev/test from xml
$mosesdecoder/scripts/ems/support/input-from-sgm.perl < $devset/newstest2016-deen-ref.en.sgm > data/dev.txt.en
$mosesdecoder/scripts/ems/support/input-from-sgm.perl < $devset/newstest2016-deen-src.de.sgm > data/dev.txt.de
$mosesdecoder/scripts/ems/support/input-from-sgm.perl < $devset/newstest2017-deen-ref.en.sgm > data/test.txt.en
$mosesdecoder/scripts/ems/support/input-from-sgm.perl < $devset/newstest2017-deen-src.de.sgm > data/test.txt.de
ln -s $my_corpus_stem.de data/train.txt.de 
ln -s $my_corpus_stem.en data/train.txt.en

# tokenize
for prefix in train dev test
 do
  $mosesdecoder/scripts/tokenizer/normalize-punctuation.perl $SRC < data/$prefix.txt.$SRC \
    | $mosesdecoder/scripts/tokenizer/tokenizer.perl -a -l $SRC  > data/$prefix.tok.$SRC
  $mosesdecoder/scripts/tokenizer/normalize-punctuation.perl $TRG < data/$prefix.txt.$TRG \
    | $mosesdecoder/scripts/tokenizer/tokenizer.perl -a -l $TRG  > data/$prefix.tok.$TRG
 done

# clean empty and long sentences, and sentences with high source-target ratio (training corpus only)
$mosesdecoder/scripts/training/clean-corpus-n.perl data/train.tok $SRC $TRG data/train.clean.tok 1 80

# train truecaser
$mosesdecoder/scripts/recaser/train-truecaser.perl -model data/truecase-model.$SRC -corpus data/train.clean.tok.$SRC 
$mosesdecoder/scripts/recaser/train-truecaser.perl -model data/truecase-model.$TRG -corpus data/train.clean.tok.$TRG

# truecase
for prefix in train.clean dev test
 do
  $mosesdecoder/scripts/recaser/truecase.perl -model data/truecase-model.$SRC < data/$prefix.tok.$SRC > data/$prefix.tc.$SRC
  $mosesdecoder/scripts/recaser/truecase.perl -model data/truecase-model.$TRG < data/$prefix.tok.$TRG > data/$prefix.tc.$TRG
 done

# train BPE
cat data/train.clean.tc.$SRC data/train.clean.tc.$TRG | $subword_nmt/learn_bpe.py -s $bpe_operations > model/$SRC$TRG.bpe

# apply BPE
$subword_nmt/apply_bpe.py -c model/$SRC$TRG.bpe < data/dev.tc.$SRC > data/dev.bpe.$SRC
$subword_nmt/apply_bpe.py -c model/$SRC$TRG.bpe < data/dev.tc.$TRG > data/dev.bpe.$TRG
$subword_nmt/apply_bpe.py -c model/$SRC$TRG.bpe < data/test.tc.$SRC > data/test.bpe.$SRC
$subword_nmt/apply_bpe.py -c model/$SRC$TRG.bpe < data/test.tc.$TRG > data/test.bpe.$TRG
$subword_nmt/apply_bpe.py -c model/$SRC$TRG.bpe < data/train.clean.tc.$SRC > data/train.bpe.$SRC
$subword_nmt/apply_bpe.py -c model/$SRC$TRG.bpe < data/train.clean.tc.$TRG > data/train.bpe.$TRG

# build network dictionary
./build_dictionary.py data/train.bpe.$SRC data/train.bpe.$TRG

