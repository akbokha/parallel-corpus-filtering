#!/bin/sh

EXPERIMENT=${1:-"bicleaner_dcce_biced"}
TRAINING_METADATA_DIR=${2:-"../bicleaner-train/classifiers/bicleaner_dcce_biced"}

SRC=en
TRG=de

OUTPUT_DIR="./output/$EXPERIMENT"

TO_BE_CLASSIFIED_DATA=${3:-"../hardrules/output/$EXPERIMENT/data_hardrules_filtered"}

GPUS=${4:-"0"}

DOM_THRESHOLD=${5:-"0.50"}

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

mkdir -p $OUTPUT_DIR

bicleaner-classify  \
        $TO_BE_CLASSIFIED_DATA  \
        $OUTPUT_DIR/data_classified  \
        $TRAINING_METADATA_DIR/en-de.yaml \
        --threshold 0.5 \
        --dom_threshold $DOM_THRESHOLD \
        --gpu $GPUS \
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

python extract_corpora_and_scores_dom.py $OUTPUT_DIR

rm $OUTPUT_DIR/data_classified
