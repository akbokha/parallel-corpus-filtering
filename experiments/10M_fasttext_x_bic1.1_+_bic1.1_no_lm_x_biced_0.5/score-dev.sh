#!/bin/bash

. ./local-settings.sh
data_dir=../experiments/10M_fasttext_x_bic1.1_+_bic1.1_no_lm_x_biced_0.5/data
model_dir=../experiments/10M_fasttext_x_bic1.1_+_bic1.1_no_lm_x_biced_0.5/model

ref=$data_dir/dev.tok.en

MODEL=`ls -t $model_dir/model.iter*npz | head -1`
cp $1 $MODEL.bpe

cat $1 \
    | sed 's/\@\@ //g' \
    | $mosesdecoder/scripts/generic/multi-bleu.perl $ref > $MODEL.bleu

echo `date`" $MODEL: "`cat $MODEL.bleu` >> $model_dir/bleu_scores

cat $MODEL.bleu | sed -r 's/BLEU = ([0-9.]+),.*/\1/'
