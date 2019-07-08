#!/bin/bash

# path to marian
export marian=/fs/bil0/abdel/marian-dev

# path to the moses-scripts directory
export moses_scripts=/fs/bil0/abdel/moses-scripts

# path to the subword-nmt directory
export subword_nmt=/fs/bil0/abdel/subword-nmt

# see https://github.com/marian-nmt/marian-examples/tree/master/transformer for more details
export model_type=lm-transformer

export mono_train=/fs/bil0/abdel/mono/data/train/news_2015_-_2017_shuffled_1M_sen
export mono_dev=/fs/bil0/abdel/mono/data/dev/news_2015_-_2017_shuffled_1M_sen_val

# work-space size (RAM)
export work_space_size=6000
