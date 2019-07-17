#!/bin/sh

# experiment-name and respective data and model directories
export experiment=10M_langid_+_dcce_ens1
export data_dir=../experiments/$experiment/data
export model_dir=../experiments/$experiment/model

# set GPU as specified with 0 or dynamically
export GPU="4"

# path to moses decoder: https://github.com/moses-smt/mosesdecoder
export mosesdecoder=/fs/bil0/abdel/mosesdecoder

# path to subword segmentation scripts: https://github.com/rsennrich/subword-nmt
export subword_nmt=/fs/bil0/abdel/subword-nmt

# path to marian
export marian=/fs/bil0/abdel/marian-dev

# path to amun
export amun=/fs/bil0/abdel/amun

# path to clean eval dev sets
export devset=/fs/bil0/abdel/data/dev

# path to raw test sets
export test_sets=/fs/bil0/abdel/data/test

# path to corpus to be tested
export my_corpus_stem=/fs/bil0/abdel/data/train/langid_+_dcce_ens1/parallel_corpus.10000000
