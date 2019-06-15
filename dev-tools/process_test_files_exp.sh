#!/bin/bash -v
set -e

SRC=de
TRG=en

. ./local-settings.sh

for test_set in $test_sets/*.$SRC; do
    test_file="$(basename "$test_set")"
    # wrap in xml
    cat $test_set | $mosesdecoder/scripts/ems/support/create-xml.perl source > $data_dir/$test_file.sgm
    # tokenize
    $mosesdecoder/scripts/tokenizer/normalize-punctuation.perl $SRC < $test_set \
   	| $mosesdecoder/scripts/tokenizer/tokenizer.perl -a -l $SRC > $data_dir/"${test_file%.*}".tok.$SRC
    # truecase
    $mosesdecoder/scripts/recaser/truecase.perl -model $data_dir/truecase-model.$SRC < $data_dir/"${test_file%.*}".tok.$SRC > $data_dir/"${test_file%.*}".tc.$SRC
    # apply BPE
    $subword_nmt/apply_bpe.py -c $model_dir/$SRC$TRG.bpe < $data_dir/"${test_file%.*}".tc.$SRC > $data_dir/"${test_file%.*}".bpe.$SRC
done

for test_set in $test_sets/*.$TRG; do
    test_file="$(basename "$test_set")"
    # wrap in xml
    cat $test_set | $mosesdecoder/scripts/ems/support/create-xml.perl ref > $data_dir/$test_file.sgm
    # tokenize
    $mosesdecoder/scripts/tokenizer/normalize-punctuation.perl $TRG < $test_set \
   	| $mosesdecoder/scripts/tokenizer/tokenizer.perl -a -l $TRG > $data_dir/"${test_file%.*}".tok.$TRG
    # truecase
    $mosesdecoder/scripts/recaser/truecase.perl -model $data_dir/truecase-model.$TRG < $data_dir/"${test_file%.*}".tok.$TRG > $data_dir/"${test_file%.*}".tc.$TRG
    # apply BPE
    $subword_nmt/apply_bpe.py -c $model_dir/$SRC$TRG.bpe < $data_dir/"${test_file%.*}".tc.$TRG > $data_dir/"${test_file%.*}".bpe.$TRG
done
