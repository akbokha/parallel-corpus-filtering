#!/bin/bash -v

set -e

. ./config.sh

MARIAN=$marian/build

MARIAN_TRAIN=$MARIAN/marian
MARIAN_DECODER=$MARIAN/marian-decoder
MARIAN_VOCAB=$MARIAN/marian-vocab
MARIAN_SCORER=$MARIAN/marian-scorer

SRC=$1
TRG=$2

experiment="transformer-model-$SRC-$TRG"
data_dir=models/$experiment/data
model_dir=models/$experiment/model

mkdir -p $data_dir
mkdir -p $model_dir

# set chosen gpus
GPUS=$3
echo Using GPUs: $GPUS

# preprocess data
LC_ALL=C.UTF-8 $sacre_bleu/sacrebleu.py -t wmt17 -l $SRC-$TRG --echo src >  $data_dir/test2017.$SRC
../scripts/transformer/preprocess-data_t17.sh $SRC $TRG $data_dir $model_dir

