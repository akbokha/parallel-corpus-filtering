#!/bin/bash -v
set -e

SRC=de
TRG=en

. ./local-settings.sh

for test_set in $test_sets/*.$SRC; do
    test_file="$(basename "$test_set")"
    # wrap in xml
    cat $test_set | $mosesdecoder/scripts/ems/support/create-xml.perl source > data/$test_file.sgm
    # tokenize
    $mosesdecoder/scripts/tokenizer/normalize-punctuation.perl $SRC < $test_set \
   	| $mosesdecoder/scripts/tokenizer/tokenizer.perl -a -l $SRC > data/"${test_file%.*}".tok.$SRC
    # truecase
    $mosesdecoder/scripts/recaser/truecase.perl -model data/truecase-model.$SRC < data/"${test_file%.*}".tok.$SRC > data/"${test_file%.*}".tc.$SRC
    # apply BPE
    $subword_nmt/apply_bpe.py -c model/$SRC$TRG.bpe < data/"${test_file%.*}".tc.$SRC > data/"${test_file%.*}".bpe.$SRC
done

for test_set in $test_sets/*.$TRG; do
    test_file="$(basename "$test_set")"
    # wrap in xml
    cat $test_set | $mosesdecoder/scripts/ems/support/create-xml.perl ref > data/$test_file.sgm
    # tokenize
    $mosesdecoder/scripts/tokenizer/normalize-punctuation.perl $TRG < $test_set \
   	| $mosesdecoder/scripts/tokenizer/tokenizer.perl -a -l $TRG > data/"${test_file%.*}".tok.$TRG
    # truecase
    $mosesdecoder/scripts/recaser/truecase.perl -model data/truecase-model.$TRG < data/"${test_file%.*}".tok.$TRG > data/"${test_file%.*}".tc.$TRG
    # apply BPE
    $subword_nmt/apply_bpe.py -c model/$SRC$TRG.bpe < data/"${test_file%.*}".tc.$TRG > data/"${test_file%.*}".bpe.$TRG
done

