#!/bin/bash

. ./local-settings.sh
data_dir=../experiments/100M_fasttext_x_bic1.1_+_bic1.1_dom_0.50_dcce_biced_hdiff_no_lm/data
model_dir=../experiments/100M_fasttext_x_bic1.1_+_bic1.1_dom_0.50_dcce_biced_hdiff_no_lm/model

ref=$data_dir/dev.tok.en

MODEL=`ls -t $model_dir/model.iter*npz | head -1`
cp $1 $MODEL.bpe

cat $1 \
    | sed 's/\@\@ //g' \
    | $mosesdecoder/scripts/generic/multi-bleu.perl $ref > $MODEL.bleu

echo `date`" $MODEL: "`cat $MODEL.bleu` >> $model_dir/bleu_scores

cat $MODEL.bleu | sed -r 's/BLEU = ([0-9.]+),.*/\1/'
