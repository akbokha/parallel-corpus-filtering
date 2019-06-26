#!/bin/sh

SRC=en
TRG=de

# path to marian
marian=/fs/bil0/abdel/marian-dev

marian_scorer=$marian/build/marian-scorer

GPU=0

parallel_data=../filtering/output/corpus_lang_filtered

ende_model_dir=../models/translation/models/transformer-model-en-de/model
deen_model_dir=../models/translation/models/transformer-model-de-en/model

output_dir=output

export BEST_ende=`ls $ende_model_dir/model.iter*.bleu
    | perl -ne 'chop; /iter(\d+).npz/; $iter = $1; qx/cat $_/ =~ /BLEU = ([\d\.]+), /; if ($1>$bleu) { $bleu=$1; $best = $iter; print $best."\n"; }'
    | tail -n 1`

export BEST_deen=`ls $deen_model_dir/model.iter*.bleu
    | perl -ne 'chop; /iter(\d+).npz/; $iter = $1; qx/cat $_/ =~ /BLEU = ([\d\.]+), /; if ($1>$bleu) { $bleu=$1; $best = $iter; print $best."\n"; }'
    | tail -n 1`

$marian_scorer \
    -m $BEST_ende
    -v $ende_model_dir/vocab.ende.yml $ende_model_dir/vocab.ende.yml
    -t $parallel_data.{"$SRC", "$TRG"}
    --summary ce-mean-words
    --devices $GPU > $output_dir/en_de_dce_scores.txt

$marian_scorer \
    -m $BEST_deen
    -v $deen_model_dir/vocab.ende.yml $ende_model_dir/vocab.ende.yml
    -t $parallel_data.{"$TRG", "$SRC"}
    --summary ce-mean-words
    --devices $GPU > $output_dir/de_en_dce_scores.txt
