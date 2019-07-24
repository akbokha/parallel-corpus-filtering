#!/bin/sh

EXPERIMENT=${1:-"bicleaner_dcce_biced"}
language_pack=${2:-"../data/language_packs/en-de"}

classifier_dir=classifiers/$EXPERIMENT
mkdir -p $classifier_dir

SRC=en
TRG=de

GPUS=${3:-"0"}

model_dir_src_trg="../models/translation/models/transformer-model-$SRC-$TRG"/model
model_dir_trg_src="../models/translation/models/transformer-model-$TRG-$SRC"/model

src_model_id_dir="../models/language/models/lm-transformer-news-crawl-$SRC"/model
src_model_nd_dir="../models/language/models/lm-transformer-paracrawl-$SRC"/model

trg_model_id_dir="../models/language/models/lm-transformer-news-crawl-$TRG"/model
trg_model_nd_dir="../models/language/models/lm-transformer-paracrawl-$TRG"/model

BEST_SRC_TRG=`cat $model_dir_src_trg/valid.log | grep bleu | sort -rg -k12,12 -t' ' | cut -f8 -d' ' | head -n1`
BEST_TRG_SRC=`cat $model_dir_trg_src/valid.log | grep bleu | sort -rg -k12,12 -t' ' | cut -f8 -d' ' | head -n1`

BEST_SRC_ID=`cat $src_model_id_dir/valid.log | grep perplexity | sort -rg -k12,12 -t' ' | cut -f8 -d' ' | tail -n1`
BEST_SRC_ND=`cat $src_model_nd_dir/valid.log | grep perplexity | sort -rg -k12,12 -t' ' | cut -f8 -d' ' | tail -n1`

BEST_TRG_ID=`cat $trg_model_id_dir/valid.log | grep perplexity | sort -rg -k12,12 -t' ' | cut -f8 -d' ' | tail -n1`
BEST_TRG_ND=`cat $trg_model_nd_dir/valid.log | grep perplexity | sort -rg -k12,12 -t' ' | cut -f8 -d' ' | tail -n1`

bicleaner-train \
          $language_pack/train.en-de \
          --treat_oovs \
          --gpu $GPUS \
          --normalize_by_length \
          -s $SRC \
          -t $TRG \
          -d $language_pack/dict-en.gz \
          -D $language_pack/dict-de.gz \
          -b  1000 \
          -c $classifier_dir/en-de.classifier \
          -g 50000 \
          -w 50000 \
          --good_test_examples 10000 \
          --wrong_test_examples 10000 \
          -m $classifier_dir/training.en-de.yaml \
          --classifier_type random_forest \
          --dcce_model_src_trg $model_dir_src_trg/model.iter$BEST_SRC_TRG.npz \
          --dcce_model_trg_src $model_dir_trg_src/model.iter$BEST_TRG_SRC.npz \
          --dcce_src_vocab_src_trg $model_dir_src_trg/vocab.ende.yml \
          --dcce_trg_vocab_src_trg $model_dir_src_trg/vocab.ende.yml \
          --dcce_src_vocab_trg_src $model_dir_trg_src/vocab.ende.yml \
          --dcce_trg_vocab_trg_src $model_dir_trg_src/vocab.ende.yml \
          --ced_src_model_id $src_model_id_dir/model.iter$BEST_SRC_ID.npz \
          --ced_vocab_src_model_id "$src_model_id_dir/vocab.$SRC.yml" \
          --ced_src_model_nd $src_model_nd_dir/model.iter$BEST_SRC_ND.npz \
          --ced_vocab_src_model_nd "$src_model_nd_dir/vocab.$SRC.yml" \
          --ced_trg_model_id $trg_model_id_dir/model.iter$BEST_TRG_ID.npz \
          --ced_vocab_trg_model_id "$trg_model_id_dir/vocab.$TRG.yml" \
          --ced_trg_model_nd $trg_model_nd_dir/model.iter$BEST_TRG_ND.npz \
          --ced_vocab_trg_model_nd "$trg_model_nd_dir/vocab.$TRG.yml"
