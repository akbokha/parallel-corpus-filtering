#!/bin/bash
set -e

. ./local-settings.sh

if [ $# -ne 0 ]
then
    experiment=$1
    data_dir=../experiments/$experiment/data
    model_dir=../experiments/$experiment/model
fi

ref=$data_dir/test.tok.en

MODEL=`ls -t $model_dir/model.iter*npz | head -1`

cat $data_dir/test.out \
    | sed 's/\@\@ //g' \
    | $mosesdecoder/scripts/generic/multi-bleu-detok.perl $ref > $data_dir/test.detok.bleu
