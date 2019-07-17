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

experiment_dir=$3
data_dir=$experiment_dir/data
model_dir=$experiment_dir/model

mkdir -p $data_dir
mkdir -p $model_dir

# set chosen gpus
GPUS=$4
echo Using GPUs: $GPUS

# find best model on dev set
ITER=`cat $model_dir/valid.log | grep translation | sort -rg -k12,12 -t' ' | cut -f8 -d' ' | head -n1`

if [ ! -e "$model_dir/model.iter$ITER.npz" ] 
then
    model="$model_dir/model.npz.best-translation.npz"
    decoder="$model_dir/model.npz.best-translation.npz.decoder.yml"
else
    model="$model_dir/model.iter$ITER.npz"
    decoder="$model_dir/model.npz.decoder.yml"
fi

# translate test sets
for prefix in test2014 test2015 test2016 test2017
do
    if [ ! -e "$data_dir/$prefix.$TRG.output" ]
    then
        cat $data_dir/$prefix.bpe.$SRC \
            | $MARIAN_DECODER -c $decoder -m $model -d $GPUS -b 12 -n -w 6000 \
            | sed 's/\@\@ //g' \
            | $moses_scripts/scripts/recaser/detruecase.perl \
            | $moses_scripts/scripts/tokenizer/detokenizer.perl -l $TRG \
            > $data_dir/$prefix.$TRG.output
    fi
done

# calculate bleu scores on test sets
LC_ALL=C.UTF-8 $sacre_bleu/sacrebleu.py -t wmt14 -l $SRC-$TRG < $data_dir/test2014.$TRG.output > $data_dir/test2014.$TRG.output.bleu
LC_ALL=C.UTF-8 $sacre_bleu/sacrebleu.py -t wmt15 -l $SRC-$TRG < $data_dir/test2015.$TRG.output > $data_dir/test2015.$TRG.output.bleu
LC_ALL=C.UTF-8 $sacre_bleu/sacrebleu.py -t wmt16 -l $SRC-$TRG < $data_dir/test2016.$TRG.output > $data_dir/test2016.$TRG.output.bleu
LC_ALL=C.UTF-8 $sacre_bleu/sacrebleu.py -t wmt17 -l $SRC-$TRG < $data_dir/test2017.$TRG.output > $data_dir/test2017.$TRG.output.bleu
