#!/bin/bash
set -e

. ./local-settings.sh

if [ $# -ne 0 ]
then
    experiment=$1
    data_dir=../experiments/$experiment/data
    model_dir=../experiments/$experiment/model
    GPU=$2
fi

ref=$data_dir/test.tok.en

MODEL=`ls -t $model_dir/model.iter*npz | head -1`
cp $1 $MODEL.bpe

cat $1 \
    | sed 's/\@\@ //g' \
    | $mosesdecoder/scripts/generic/multi-bleu-detok.perl $ref > $MODEL.test.bleu

echo `date`" $MODEL: "`cat $MODEL.test.bleu` >> $model_dir/test_bleu_score
