#!/bin/bash

# path to marian
export marian=/fs/bil0/abdel/marian-dev

# path to the moses-scripts directory
export moses_scripts=/fs/bil0/abdel/moses-scripts

# path to the subword-nmt directory
export subword_nmt=/fs/bil0/abdel/subword-nmt

# path to sacreBLEU
export sacre_bleu=/fs/bil0/abdel/sacreBLEU

# path to wmt_parallel_corpora
export wmt_parallel_copora=/fs/bil0/abdel/data/wmt_parallel_data/wmt18_pp_parallel_data_random_1M_selection

# see https://github.com/marian-nmt/marian-examples/tree/master/transformer for more details
export model_type=wmt2017-transformer

# work-space size (RAM)
export work_space_size=8000
