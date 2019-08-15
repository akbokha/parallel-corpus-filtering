#!/bin/bash -v

file='translation/models//wmt2017-transformer-en-de/model/model/ens-rtl4/model.npz.best-translation.npz'

RESULTS_DIR="/Volumes/SandiskFD/University/parallel-corpus-filtering/models/"
mkdir -p $RESULTS_DIR

rsync -au --progress \
    abdel@magni.inf.ed.ac.uk:/fs/bil0/abdel/parallel-corpus-filtering/models/$file $RESULTS_DIR/$file
