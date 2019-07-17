#!/bin/bash
set -e

SRC=de
TRG=en

. ./local-settings.sh

if [ $# -ne 0 ]
then
    experiment=$1
    data_dir=../experiments/$experiment/data
    model_dir=../experiments/$experiment/model
    GPU=$2
fi

export BEST=`ls $model_dir/model.iter*.bleu | perl -ne 'chop; /iter(\d+).npz/; $iter = $1; qx/cat $_/ =~ /BLEU = ([\d\.]+), /; if ($1>$bleu) { $bleu=$1; $best = $iter; print $best."\n"; }' | tail -n 1`

for test_set in $test_sets/*.$SRC; do
    test_file="$(basename "$test_set")"
    $marian/build/marian-decoder \
        -d $GPU \
        -n  \
        -v $data_dir/train.bpe.$SRC.json $data_dir/train.bpe.$TRG.json \
        -m $model_dir/model.iter$BEST.npz \
        < $data_dir/"${test_file%.*}".bpe.$SRC \
        > $data_dir/"${test_file%.*}".out

    sleep 5

    cat $data_dir/"${test_file%.*}".out \
        | sed -r 's/\@\@ //g' | sed -r 's/\@\@$//g' \
        | $mosesdecoder/scripts/tokenizer/detokenizer.perl -l $TRG \
        | $mosesdecoder/scripts/recaser/detruecase.perl \
        | $mosesdecoder/scripts/ems/support/wrap-xml.perl any $data_dir/"${test_file%.*}".$SRC.sgm \
        > $data_dir/"${test_file%.*}".out.sgm

    $mosesdecoder/scripts/generic/mteval-v13a.pl \
        -c \
        -s $data_dir/"${test_file%.*}".$SRC.sgm \
        -r $data_dir/"${test_file%.*}".$TRG.sgm \
        -t $data_dir/"${test_file%.*}".out.sgm \
        > $data_dir/"${test_file%.*}".out.bleu
done

sed -n -e 's/^.*BLEU score = *//p' $data_dir/*.out.bleu \
    | awk '{sum += $1 } END { if (NR > 0) print sum / NR }' \
    | (echo -n "Average BLEU score over the six test-sets: " && cat) >> $data_dir/pcf_avg.out.bleu

sed -n -e 's/^.*NIST score = *//p' $data_dir/*.out.bleu \
    | awk '{sum += $1 } END { if (NR > 0) print sum / NR }' \
    | (echo -n "Average NIST score over the six test-sets: " && cat) >> $data_dir/pcf_avg.out.nist
