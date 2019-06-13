#!/bin/bash -v
set -e

SRC=de
TRG=en

. ./local-settings.sh

for test_set in $test_sets/*.$SRC; do
    # wrap in xml
    cat $test_set | $mosesdecoder/scripts/ems/support/create-xml.perl source > $test_set.sgm
    # tokenize
    $mosesdecoder/scripts/tokenizer/normalize-punctuation.perl $SRC < $test_set \
	| $mosesdecoder/scripts/tokenizer/tokenizer.perl -a -l $SRC > "${test_set%.*}".tok.$SRC
    # truecase
    $mosesdecoder/scripts/recaser/truecase.perl -model data/truecase-model.$SRC < "${test_set%.*}".tok.$SRC > "${test_set%.*}".tc.$SRC
    # apply BPE
    $subword_nmt/apply_bpe.py -c model/$SRC$TRG.bpe < "${test_set%.*}".tc.$SRC > "${test_set%.*}".bpe.$SRC
done

for test_set in $test_sets/*.$TRG; do
    # wrap in xml
    cat $test_set | $mosesdecoder/scripts/ems/support/create-xml.perl ref > $test_set.sgm
    # tokenize
    $mosesdecoder/scripts/tokenizer/normalize-punctuation.perl $TRG < $test_set \
    	| $mosesdecoder/scripts/tokenizer/tokenizer.perl -a -l $TRG > "${test_set%.*}".tok.$TRG
    # truecase
    $mosesdecoder/scripts/recaser/truecase.perl -model data/truecase-model.$TRG < "${test_set%.*}".tok.$TRG > "${test_set%.*}".tc.$TRG
    # apply BPE
    $subword_nmt/apply_bpe.py -c model/$SRC$TRG.bpe < "${test_set%.*}".tc.$TRG > "${test_set%.*}".bpe.$TRG
done
