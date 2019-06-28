#!/bin/bash

SRC=${1:-"en"}
TRG=${2:-"de"}

# path to marian
marian=/fs/bil0/abdel/marian-dev

marian_scorer=$marian/build/marian-scorer

GPU="5"

parallel_data=../filtering/output/corpus_lang_filtered

model_dir="../models/translation/models/transformer-model-$SRC-$TRG"/model

output_dir=output
mkdir -p $output_dir

BEST=`cat $model_dir/valid.log | grep bleu | sort -rg -k12,12 -t' ' | cut -f8 -d' ' | head -n1`

$marian_scorer \
    -m $model_dir/model.iter$BEST.npz \
    -v $model_dir/vocab.ende.yml $model_dir/vocab.ende.yml \
    -t $parallel_data.$SRC $parallel_data.$TRG \
    --devices $GPU > $output_dir/"$SRC"_"$TRG"_dce_scores.txt

rm -f $output_dir/"$SRC"_"$TRG"_ce_mean_scores.txt

while read trg_sentence <&3 && read ce_score <&4; do
    trg_len=$(echo -n $trg_sentence| wc -w)
    ce_mean_words=$(echo "$ce_score/$trg_len" | bc -l)
    echo $ce_mean_words >> $output_dir/"$SRC"_"$TRG"_ce_mean_scores.txt
done 3<$parallel_data.$TRG 4<$output_dir/"$SRC"_"$TRG"_dce_scores.txt

# $marian_scorer \
#    -m $model_dir/model.iter$BEST.npz \
#    -v $model_dir/vocab.ende.yml $model_dir/vocab.ende.yml \
#    -t $parallel_data.$SRC $parallel_data.$TRG \
#    --devices $GPU > $output_dir/"$SRC"_"$TRG"_dce_scores.txt

