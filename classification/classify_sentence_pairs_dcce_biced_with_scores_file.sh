#!/bin/sh

EXPERIMENT=${1:-"fasttext_prob_x_len_+_bicleaner_dcce_biced_hdiff_wcs"}
TRAINING_METADATA_DIR=${2:-"../bicleaner-train/classifiers/bicleaner_dcce_biced_hdiff"}

SRC=en
TRG=de

OUTPUT_DIR="./output/$EXPERIMENT"

TO_BE_CLASSIFIED_DATA=${3:-"../filtering/output/corpus_fasttext_prob_and_len_filtered"}

DCCE_SCORES_DIR=${4:-"../scoring/output/fasttext_prob_and_len_dcce_scoring"}
CED_SRC_SCORES_DIR=${5:-"../scoring/output/fasttext_prob_x_len_+_ced_0.0"}
CED_TRG_SCORES_DIR=${6:-"../scoring/output/fasttext_prob_x_len_+_ced_de_0.0"}

DOM_THRESHOLD=${7:-"1.0"}

mkdir -p $OUTPUT_DIR

bicleaner-classify  \
        $TO_BE_CLASSIFIED_DATA  \
        $OUTPUT_DIR/data_classified  \
        $TRAINING_METADATA_DIR/en-de.yaml \
        --threshold 0.55 \
        --dom_threshold $DOM_THRESHOLD \
        --p 4 \
        --use_biced_features \
        --use_dcce_features \
        --dcce_scores $DCCE_SCORES_DIR/filtered_data_scores \
        --ced_src_scores $CED_SRC_SCORES_DIR/filtered_data_scores \
        --ced_trg_scores $CED_TRG_SCORES_DIR/filtered_data_scores

python extract_corpora_and_scores.py $OUTPUT_DIR

rm $OUTPUT_DIR/data_classified
