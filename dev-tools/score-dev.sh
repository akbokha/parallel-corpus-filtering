#!/bin/bash

. ./local-settings.sh

ref=data/dev.tok.en

MODEL=`ls -t model/model.iter*npz | head -1`
cp $1 $MODEL.bpe

cat $1 \
    | sed 's/\@\@ //g' \
    | $mosesdecoder/scripts/generic/multi-bleu.perl $ref > $MODEL.bleu

echo `date`" $MODEL: "`cat $MODEL.bleu` >> model/bleu_scores 

cat $MODEL.bleu | sed -r 's/BLEU = ([0-9.]+),.*/\1/'
