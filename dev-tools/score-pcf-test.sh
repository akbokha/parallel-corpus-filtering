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
fi

export BEST=`ls $model_dir/model.iter*.bleu | perl -ne 'chop; /iter(\d+).npz/; $iter = $1; qx/cat $_/ =~ /BLEU = ([\d\.]+), /; if ($1>$bleu) { $bleu=$1; $best = $iter; print $best."\n"; }' | tail -n 1`

for test_set in $test_sets/*.$SRC; do
    test_file="$(basename "$test_set")"

    ref=$test_sets/"${test_file%.*}".en

    MODEL=`ls -t $model_dir/model.iter*npz | head -1`

    cat $data_dir/"${test_file%.*}".out \
        | sed -r 's/\@\@ //g' | sed -r 's/\@\@$//g' \
        | $mosesdecoder/scripts/tokenizer/detokenizer.perl -l $TRG \
        | $mosesdecoder/scripts/recaser/detruecase.perl > $data_dir/"${test_file%.*}".detok.out

    cat $data_dir/"${test_file%.*}".detok.out \
        | sed 's/\@\@ //g' \
        | $mosesdecoder/scripts/generic/multi-bleu-detok.perl $ref > $data_dir/"${test_file%.*}".pcf.test.detok.bleu
done

sed -n -e 's/^.*BLEU = *//p' $data_dir/*.pcf.test.detok.bleu \
    | awk '{sum += $1 } END { if (NR > 0) print sum / NR }' \
    | (echo -n "Average BLEU score over the six test-sets: " && cat) > $data_dir/pcf_avg.detok.bleu
