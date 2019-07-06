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

experiment="$model_type-$SRC-$TRG"
data_dir=models/$experiment/data
model_dir=models/$experiment/model

mkdir -p $data_dir
mkdir -p $model_dir

# set chosen gpus
GPUS=$3
echo Using GPUs: $GPUS

# find best model on dev set
ITER=`cat $model_dir/valid.log | grep translation | sort -rg -k12,12 -t' ' | cut -f8 -d' ' | head -n1`

# translate test sets
for prefix in test2017
do
    cat $data_dir/$prefix.bpe.$SRC \
        | $MARIAN_DECODER -c $model_dir/model.npz.decoder.yml -m $model_dir/model.iter$ITER.npz -d $GPUS -b 12 -n -w 6000 \
        | sed 's/\@\@ //g' \
        | $moses_scripts/scripts/recaser/detruecase.perl \
        | $moses_scripts/scripts/tokenizer/detokenizer.perl -l $TRG \
        > $data_dir/$prefix.$TRG.output
done

# calculate bleu scores on test sets
LC_ALL=C.UTF-8 $sacre_bleu/sacrebleu.py -t wmt14 -l $SRC-$TRG < $data_dir/test2014.$TRG.output
LC_ALL=C.UTF-8 $sacre_bleu/sacrebleu.py -t wmt15 -l $SRC-$TRG < $data_dir/test2015.$TRG.output
LC_ALL=C.UTF-8 $sacre_bleu/sacrebleu.py -t wmt16 -l $SRC-$TRG < $data_dir/test2016.$TRG.output
LC_ALL=C.UTF-8 $sacre_bleu/sacrebleu.py -t wmt17 -l $SRC-$TRG < $data_dir/test2017.$TRG.output
