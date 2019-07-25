#!/bin/sh

EXPERIMENT=${1:-"bicleaner_dcce"}
TRAINING_METADATA_DIR=${2:-"../data/language_packs/en-de"}

SRC=en
TRG=de

OUTPUT_DIR="./output/$EXPERIMENT"

TO_BE_CLASSIFIED_DATA=${3:-"../hardrules/output/$EXPERIMENT/data_hardrules_filtered"}

GPUS=${4:-"0"}

model_dir_src_trg="../models/translation/models/transformer-model-$SRC-$TRG"/model
model_dir_trg_src="../models/translation/models/transformer-model-$TRG-$SRC"/model

BEST_SRC_TRG=`cat $model_dir_src_trg/valid.log | grep bleu | sort -rg -k12,12 -t' ' | cut -f8 -d' ' | head -n1`
BEST_TRG_SRC=`cat $model_dir_trg_src/valid.log | grep bleu | sort -rg -k12,12 -t' ' | cut -f8 -d' ' | head -n1`

mkdir -p $OUTPUT_DIR

bicleaner-classify  \
        $TO_BE_CLASSIFIED_DATA  \
        $OUTPUT_DIR/data_classified  \
        $TRAINING_METADATA_DIR/en-de.yaml \
        --threshold 0.5 \
        --gpu $GPUS \
        --dcce_model_src_trg $model_dir_src_trg/model.iter$BEST_SRC_TRG.npz \
        --dcce_model_trg_src $model_dir_trg_src/model.iter$BEST_TRG_SRC.npz \
        --dcce_src_vocab_src_trg $model_dir_src_trg/vocab.ende.yml \
        --dcce_trg_vocab_src_trg $model_dir_src_trg/vocab.ende.yml \
        --dcce_src_vocab_trg_src $model_dir_trg_src/vocab.ende.yml \
        --dcce_trg_vocab_trg_src $model_dir_trg_src/vocab.ende.yml

python extract_corpora_and_scores.py $OUTPUT_DIR

rm $OUTPUT_DIR/data_classified
