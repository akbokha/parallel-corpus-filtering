#!/bin/bash

# path to marian
export marian=/fs/bil0/abdel/marian-dev

export LC_ALL=C.UTF-8

# path to the moses-scripts directory
export moses_scripts=/fs/bil0/abdel/moses-scripts

# path to the subword-nmt directory
export subword_nmt=/fs/bil0/abdel/subword-nmt

# see https://github.com/marian-nmt/marian-examples/tree/master/transformer for more details
export model_type=lm-transformer
export trained_on=paracrawl

export mono_train=/fs/bil0/abdel/data/mono/train/news_2015_-_2017_shuffled_1M_sen
export mono_dev=/fs/bil0/abdel/data/mono/dev/news_2015_-_2017_shuffled_1M_sen_val

# work-space size (RAM)
export work_space_size=6000

export LANG=de
export experiment="$model_type-$trained_on-$LANG"
export data_dir=models/$experiment/data
export model_dir=models/$experiment/model
