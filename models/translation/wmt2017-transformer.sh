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

experiment="$model_type-$SRC-$TRG"
data_dir=models/$experiment/data
model_dir=models/$experiment/model

mkdir -p $data_dir
mkdir -p $model_dir

cp -p ../scripts/$model_type/validate.src.sh ./models/$experiment/validate.$SRC.sh
cp -p ../scripts/$model_type/validate.sh ./models/$experiment/validate.sh

insert_vars=$"data_dir=$data_dir\nSRC=$SRC\nTRG=$TRG"

sed -i "4i$insert_vars" ./models/$experiment/validate.$SRC.sh
sed -i "5i$insert_vars" ./models/$experiment/validate.sh

# set chosen gpus
GPUS=$3
echo Using GPUs: $GPUS

N=4
EPOCHS=8
B=12

if [ ! -e "data/corpus.$SRC" ]
then
    ../scripts/$model_type/download-files.sh
fi

mkdir -p $model_dir/model

# preprocess data
if [ ! -e "$data_dir/corpus.bpe.$SRC" ]
then
    LC_ALL=C.UTF-8 $sacre_bleu/sacrebleu.py -t wmt16 -l $SRC-$TRG --echo src > $data_dir/valid.$SRC
    LC_ALL=C.UTF-8 $sacre_bleu/sacrebleu.py -t wmt16 -l $SRC-$TRG --echo ref > $data_dir/valid.$TRG

    LC_ALL=C.UTF-8 $sacre_bleu/sacrebleu.py -t wmt14 -l $SRC-$TRG --echo src > $data_dir/test2014.$SRC
    LC_ALL=C.UTF-8 $sacre_bleu/sacrebleu.py -t wmt15 -l $SRC-$TRG --echo src > $data_dir/test2015.$SRC
    LC_ALL=C.UTF-8 $sacre_bleu/sacrebleu.py -t wmt16 -l $SRC-$TRG --echo src > $data_dir/test2016.$SRC
    LC_ALL=C.UTF-8 $sacre_bleu/sacrebleu.py -t wmt17 -l $SRC-$TRG --echo src > $data_dir/test2017.$SRC

    ../scripts/$model_type/preprocess-data.sh $SRC $TRG $data_dir $model_dir
fi

if [ ! -e "$data_dir/news.2016.$TRG" ]
then
    ../scripts/$model_type/download-files-mono.sh
fi

if [ ! -e "$data_dir/news.2016.bpe.$TRG" ]
then
    ../scripts/$model_type/preprocess-data-mono.sh $SRC $TRG $data_dir $model_dir
fi

# create common vocabulary
if [ ! -e "$model_dir/vocab.ende.yml" ]
then
    cat $data_dir/corpus.bpe.$SRC $data_dir/corpus.bpe.$TRG | $MARIAN_VOCAB --max-size 36000 > $model_dir/vocab.ende.yml
fi

# train model
mkdir -p $model_dir/model.back
if [ ! -e "$model_dir/model.back/model.npz.best-translation.npz" ]
then
    $MARIAN_TRAIN \
        --model $model_dir/model.back/model.npz --type s2s \
        --train-sets $data_dir/corpus.bpe.$TRG $data_dir/corpus.bpe.$SRC \
        --max-length 100 \
        --vocabs $model_dir/vocab.ende.yml $model_dir/vocab.ende.yml \
        --mini-batch-fit -w $work_space_size --maxi-batch 1000 \
        --valid-freq 10000 --save-freq 10000 --disp-freq 1000 \
        --valid-metrics ce-mean-words perplexity translation \
        --valid-script-path "bash ./models/$experiment/validate.$SRC.sh" \
        --valid-translation-output $data_dir/valid.bpe.$TRG.output --quiet-translation \
        --valid-sets $data_dir/valid.bpe.$TRG $data_dir/valid.bpe.$SRC \
        --valid-mini-batch 64 --beam-size 12 --normalize=1 \
        --overwrite --keep-best \
        --early-stopping 5 --after-epochs 10 --cost-type=ce-mean-words \
        --log $model_dir/model.back/train.log --valid-log $model_dir/model.back/valid.log \
        --tied-embeddings-all --layer-normalization \
        --devices $GPUS --seed 1111 \
        --exponential-smoothing
fi

if [ ! -e "$data_dir/news.2016.bpe.$SRC" ]
then
    $MARIAN_DECODER \
      -c $model_dir/model.back/model.npz.best-translation.npz.decoder.yml \
      -i $data_dir/news.2016.bpe.$TRG \
      -b 6 --normalize=1 -w 2500 -d $GPUS \
      --mini-batch 64 --maxi-batch 100 --maxi-batch-sort src \
      --max-length 200 --max-length-crop \
      > $data_dir/news.2016.bpe.$SRC
fi

if [ ! -e "$data_dir/all.bpe.$SRC" ]
then
    cat $data_dir/corpus.bpe.$SRC $data_dir/corpus.bpe.$SRC $data_dir/news.2016.bpe.$SRC > $data_dir/all.bpe.$SRC
    cat $data_dir/corpus.bpe.$TRG $data_dir/corpus.bpe.$TRG $data_dir/news.2016.bpe.$TRG > $data_dir/all.bpe.$TRG
fi

for i in $(seq 1 $N)
do
  mkdir -p $model_dir/model/ens$i
  # train model
    $MARIAN_TRAIN \
        --model $model_dir/model/ens$i/model.npz --type transformer \
        --train-sets $data_dir/all.bpe.$SRC $data_dir/all.bpe.$TRG \
        --max-length 100 \
        --vocabs $model_dir/vocab.ende.yml $model_dir/vocab.ende.yml \
        --mini-batch-fit -w $work_space_size --mini-batch 1000 --maxi-batch 1000 \
        --valid-freq 5000 --save-freq 5000 --disp-freq 500 \
        --valid-metrics ce-mean-words perplexity translation \
        --valid-sets $data_dir/valid.bpe.$SRC $data_dir/valid.bpe.$TRG \
        --valid-script-path "bash ./models/$experiment/validate.sh" \
        --valid-translation-output $data_dir/valid.bpe.$SRC.output --quiet-translation \
        --beam-size 12 --normalize=1 \
        --valid-mini-batch 64 \
        --overwrite --keep-best \
        --early-stopping 5 --after-epochs $EPOCHS --cost-type=ce-mean-words \
        --log $model_dir/model/ens$i/train.log --valid-log $model_dir/model/ens$i/valid.log \
        --enc-depth 6 --dec-depth 6 \
        --tied-embeddings-all \
        --transformer-dropout 0.1 --label-smoothing 0.1 \
        --learn-rate 0.0003 --lr-warmup 16000 --lr-decay-inv-sqrt 16000 --lr-report \
        --optimizer-params 0.9 0.98 1e-09 --clip-norm 5 \
        --devices $GPUS --sync-sgd --seed $i$i$i$i  \
        --exponential-smoothing
done

for i in $(seq 1 $N)
do
  mkdir -p $model_dir/model/ens-rtl$i
  # train model
    $MARIAN_TRAIN \
        --model $model_dir/model/ens-rtl$i/model.npz --type transformer \
        --train-sets $data_dir/all.bpe.$SRC $data_dir/all.bpe.$TRG \
        --max-length 100 \
        --vocabs $model_dir/vocab.ende.yml $model_dir/vocab.ende.yml \
        --mini-batch-fit -w $work_space_spize --mini-batch 1000 --maxi-batch 1000 \
        --valid-freq 5000 --save-freq 5000 --disp-freq 500 \
        --valid-metrics ce-mean-words perplexity translation \
        --valid-sets $data_dir/valid.bpe.$SRC $data_dir/valid.bpe.$TRG \
        --valid-script-path  "bash ./models/$experiment/validate.sh" \
        --valid-translation-output $data_dir/valid.bpe.$SRC.output --quiet-translation \
        --beam-size 12 --normalize=1 \
        --valid-mini-batch 64 \
        --overwrite --keep-best \
        --early-stopping 5 --after-epochs $EPOCHS --cost-type=ce-mean-words \
        --log $model_dir/model/ens-rtl$i/train.log --valid-log $model_dir/model/ens-rtl$i/valid.log \
        --enc-depth 6 --dec-depth 6 \
        --tied-embeddings-all \
        --transformer-dropout 0.1 --label-smoothing 0.1 \
        --learn-rate 0.0003 --lr-warmup 16000 --lr-decay-inv-sqrt 16000 --lr-report \
        --optimizer-params 0.9 0.98 1e-09 --clip-norm 5 \
        --devices $GPUS --sync-sgd --seed $i$i$i$i$i \
        --exponential-smoothing --right-left
done

# translate test sets
for prefix in valid test2014 test2015 test2017
do
    cat $data_dir/$prefix.bpe.$SRC \
        | $MARIAN_DECODER -c $model_dir/model/ens1/model.npz.best-translation.npz.decoder.yml \
          -m $model_dir/model/ens?/model.npz.best-translation.npz -d $GPUS \
          --mini-batch 16 --maxi-batch 100 --maxi-batch-sort src -w 5000 --n-best --beam-size $B \
        > $data_dir/$prefix.bpe.$SRC.output.nbest.0

    for i in $(seq 1 $N)
    do
      $MARIAN_SCORER -m $model_dir/model/ens-rtl$i/model.npz.best-perplexity.npz \
        -v $model_dir/vocab.ende.yml $model_dir/vocab.ende.yml -d $GPUS \
        --mini-batch 16 --maxi-batch 100 --maxi-batch-sort trg --n-best --n-best-feature R2L$(expr $i - 1) \
        -t $data_dir/$prefix.bpe.$SRC $data_dir/$prefix.bpe.$SRC.output.nbest.$(expr $i - 1) > $data_dir/$prefix.bpe.$SRC.output.nbest.$i
    done

    cat $data_dir/$prefix.bpe.$SRC.output.nbest.$N \
      | python ../scripts/$model_type/rescore.py \
      | perl -pe 's/@@ //g' \
      | $moses_scripts/scripts/recaser/detruecase.perl \
      | $moses_scripts/scripts/tokenizer/detokenizer.perl > $data_dir/$prefix.$SRC.output
done

# calculate bleu scores on test sets
LC_ALL=C.UTF-8 $sacre_bleu/sacrebleu.py -t wmt16 -l $SRC-$TRG < $data_dir/valid.$SRC.output
LC_ALL=C.UTF-8 $sacre_bleu/sacrebleu.py -t wmt14 -l $SRC-$TRG < $data_dir/test2014.$SRC.output
LC_ALL=C.UTF-8 $sacre_bleu/sacrebleu.py -t wmt15 -l $SRC-$TRG < $data_dir/test2015.$SRC.output
LC_ALL=C.UTF-8 $sacre_bleu/sacrebleu.py -t wmt17 -l $SRC-$TRG < $data_dir/test2017.$SRC.output
