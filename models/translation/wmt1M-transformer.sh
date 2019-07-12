#!/bin/bash -v

set -e

. ./config.sh

MARIAN=$marian/build

MARIAN_TRAIN=$MARIAN/marian
MARIAN_DECODER=$MARIAN/marian-decoder
MARIAN_VOCAB=$MARIAN/marian-vocab
MARIAN_SCORER=$MARIAN/marian-scorer

SRC=$1
TRG=$2

model_type=wmt1M-random

experiment="$model_type-$SRC-$TRG"
data_dir=models/$experiment/data
model_dir=models/$experiment/model

mkdir -p $data_dir
mkdir -p $model_dir

cp -p ../scripts/$model_type/validate.sh ./models/$experiment/validate.sh

insert_vars=$"data_dir=$data_dir\nSRC=$SRC\nTRG=$TRG\n"
sed -i "6i$insert_vars" ./models/$experiment/validate.sh

# set chosen gpus
GPUS=$3
echo Using GPUs: $GPUS

corpus=${4:-"corpus_1M_random"}

# preprocess data
if [ ! -e "$data_dir/corpus.bpe.$SRC" ]
then
    LC_ALL=C.UTF-8 $sacre_bleu/sacrebleu.py -t wmt16 -l $SRC-$TRG --echo src > $data_dir/valid.$SRC
    LC_ALL=C.UTF-8 $sacre_bleu/sacrebleu.py -t wmt16 -l $SRC-$TRG --echo ref > $data_dir/valid.$TRG

    LC_ALL=C.UTF-8 $sacre_bleu/sacrebleu.py -t wmt14 -l $SRC-$TRG --echo src > $data_dir/test2014.$SRC
    LC_ALL=C.UTF-8 $sacre_bleu/sacrebleu.py -t wmt15 -l $SRC-$TRG --echo src > $data_dir/test2015.$SRC
    LC_ALL=C.UTF-8 $sacre_bleu/sacrebleu.py -t wmt16 -l $SRC-$TRG --echo src > $data_dir/test2016.$SRC
    LC_ALL=C.UTF-8 $sacre_bleu/sacrebleu.py -t wmt17 -l $SRC-$TRG --echo src > $data_dir/test2017.$SRC
    ../scripts/wmt1M-transformer/preprocess-data.sh $SRC $TRG $data_dir $model_dir $corpus
fi

# create common vocabulary
if [ ! -e "$model_dir/vocab.ende.yml" ]
then
    cat $data_dir/corpus.bpe.$SRC $data_dir/corpus.bpe.$TRG | $MARIAN_VOCAB --max-size 36000 > $model_dir/vocab.ende.yml
fi

# train model
if [ ! -e "$model_dir/model.npz" ]
then
    $MARIAN_TRAIN \
        --model $model_dir/model.npz --type transformer \
        --train-sets $data_dir/corpus.bpe.$SRC $data_dir/corpus.bpe.$TRG \
        --max-length 100 \
        --vocabs $model_dir/vocab.ende.yml $model_dir/vocab.ende.yml \
        --mini-batch-fit -w $work_space_size --maxi-batch 1000 \
        --early-stopping 10 --cost-type=ce-mean-words \
        --valid-freq 5000 --save-freq 5000 --disp-freq 500 \
        --valid-metrics cross-entropy ce-mean-words perplexity translation bleu \
        --valid-sets $data_dir/valid.bpe.$SRC $data_dir/valid.bpe.$TRG \
        --valid-script-path "bash ../scripts/validate.sh $TRG $data_dir" \
        --valid-translation-output "$data_dir/valid.bpe.$SRC.output" --quiet-translation \
        --valid-mini-batch 64 \
        --beam-size 6 --normalize 0.6 \
        --log $model_dir/train.log --valid-log $model_dir/valid.log \
        --enc-depth 6 --dec-depth 6 \
        --transformer-heads 8 \
        --transformer-postprocess-emb d \
        --transformer-postprocess dan \
        --transformer-dropout 0.1 --label-smoothing 0.1 \
        --learn-rate 0.0003 --lr-warmup 16000 --lr-decay-inv-sqrt 16000 --lr-report \
        --optimizer-params 0.9 0.98 1e-09 --clip-norm 5 \
        --tied-embeddings-all \
        --devices $GPUS --sync-sgd --seed 1111 \
        --exponential-smoothing
fi

# find best model on dev set
ITER=`cat $model_dir/valid.log | grep translation | sort -rg -k12,12 -t' ' | cut -f8 -d' ' | head -n1`

# translate test sets
for prefix in test2014 test2015 test2016 test2017
do
    cat $data_dir/$prefix.bpe.$SRC \
        | $MARIAN_DECODER -c $model_dir/model.npz.decoder.yml -m $model_dir/model.iter$ITER.npz -d $GPUS -b 12 -n -w 6000 \
        | sed 's/\@\@ //g' \
        | $moses_scripts/scripts/recaser/detruecase.perl \
        | $moses_scripts/scripts/tokenizer/detokenizer.perl -l $TRG \
        > $data_dir/$prefix.$TRG.output
done

# calculate bleu scores on test sets
LC_ALL=C.UTF-8 $sacre_bleu/sacrebleu.py -t wmt14 -l $SRC-$TRG < $data_dir/test2014.$TRG.output
LC_ALL=C.UTF-8 $sacre_bleu/sacrebleu.py -t wmt15 -l $SRC-$TRG < $data_dir/test2015.$TRG.output
LC_ALL=C.UTF-8 $sacre_bleu/sacrebleu.py -t wmt16 -l $SRC-$TRG < $data_dir/test2016.$TRG.output
