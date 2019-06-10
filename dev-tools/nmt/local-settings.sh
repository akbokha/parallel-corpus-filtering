#!/bin/sh

# set GPU as specified with 0 or dynamically
export GPU=1

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

# path to corpus to be tested
export my_corpus_stem=/fs/bil0/abdel/data/train/parallel_corpus.10000000
