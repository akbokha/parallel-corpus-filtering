#!/bin/bash
set -e

. ./local-settings.sh

export BEST=`ls model/model.iter*.bleu | perl -ne 'chop; /iter(\d+).npz/; $iter = $1; qx/cat $_/ =~ /BLEU = ([\d\.]+), /; if ($1>$bleu) { $bleu=$1; $best = $iter; print $best."\n"; }' | tail -n 1`

$marian/build/marian-decoder \
    -d $GPU \
    -n  \
    -v data/train.bpe.de.json data/train.bpe.en.json \
    -m model/model.iter$BEST.npz \
    < data/test.bpe.de \
    > data/test.out

sleep 5

cat data/test.out \
    | sed -r 's/\@\@ //g' | sed -r 's/\@\@$//g' \
    | $mosesdecoder/scripts/tokenizer/detokenizer.perl -l en \
    | $mosesdecoder/scripts/recaser/detruecase.perl \
    | $mosesdecoder/scripts/ems/support/wrap-xml.perl en $devset/newstest2017-deen-src.de.sgm \
    > data/test.out.sgm

$mosesdecoder/scripts/generic/mteval-v13a.pl \
    -c \
    -s $devset/newstest2017-deen-src.de.sgm \
    -r $devset/newstest2017-deen-ref.en.sgm \
    -t data/test.out.sgm \
    > data/test.out.bleu

# RESULTS_DIR=../results/$experiment
# mkdir -p $RESULTS_DIR/model
# mkdir -p $RESULTS_DIR/data
#
# cp $model_dir/model.iter$BEST.* $RESULTS_DIR/model
# cp $model_dir/model.npz*.yml $RESULTS_DIR/model
# cp $model_dir/*.log $RESULTS_DIR/model
# cp $model_dir/bleu_scores $RESULTS_DIR
# cp $model_dir/deen.bpe $RESULTS_DIR/model
# cp $model_dir/dev.out $RESULTS_DIR/model
# cp $model_dir/* $RESULTS_DIR/data
