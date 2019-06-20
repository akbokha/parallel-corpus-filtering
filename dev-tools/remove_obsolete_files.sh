#!/bin/bash

. ./local-settings.sh

export BEST=`ls $model_dir/model.iter*.bleu | perl -ne 'chop; /iter(\d+).npz/; $iter = $1; qx/cat $_/ =~ /BLEU = ([\d\.]+), /; if ($1>$bleu) { $bleu=$1; $best = $iter; print $best."\n"; }' | tail -n 1`

find ./$model_dir -name "model.iter*" -type f -not -name "model.iter$BEST.*" -delete

find ./$data_dir -name "train.*" -type f -not -name "*.bpe.*.json" -delete

