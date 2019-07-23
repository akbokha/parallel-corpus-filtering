#!/bin/sh

EXPERIMENT=${1:-"bicleaner_st_no_lm"}
language_pack=${2:-"../data/language_packs/en-de"}

classifier_dir=./classifiers/$EXPERIMENT
mkdir -p $classifier_dir

SRC=en
TRG=de

bicleaner-train \
          $language_pack/train.en-de \
          --treat_oovs \
          --normalize_by_length \
          -s $SRC \
          -t $TRG \
          -d $language_pack/dict-en.gz \
          -D $language_pack/dict-de.gz \
          -b  1000 \
          -c $classifier_dir/en-de.classifier \
          -g 50000 \
          -w 50000 \
          --good_test_examples 10000 \
          --wrong_test_examples 10000 \
          -m $classifier_dir/training.en-de.yaml \
          --classifier_type random_forest
