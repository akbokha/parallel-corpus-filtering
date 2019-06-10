#!/bin/sh

# set GPU as specified with 0 or dynamically
export GPU=0

# path to moses decoder: https://github.com/moses-smt/mosesdecoder
export mosesdecoder=/home/pkoehn/moses

# path to subword segmentation scripts: https://github.com/rsennrich/subword-nmt
export subword_nmt=/home/pkoehn/statmt/project/subword-nmt

# path to marian 
export marian=/home/pkoehn/statmt/project/marian-v1.1

# path to clean eval dev sets
export devset=/home/pkoehn/statmt/data/cleaneval/dev-tools/dev-sets

# path to corpus to be tested
export my_corpus_stem=/home/pkoehn/statmt/data/cleaneval/my-corpus

