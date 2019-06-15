#!/bin/bash
set -e

SRC=de
TRG=en

. ./local-settings.sh

export BEST=`ls model/model.iter*.bleu | perl -ne 'chop; /iter(\d+).npz/; $iter = $1; qx/cat $_/ =~ /BLEU = ([\d\.]+), /; if ($1>$bleu) { $bleu=$1; $best = $iter; print $best."\n"; }' | tail -n 1`

for test_set in $test_sets/*.$SRC; do
    test_file="$(basename "$test_set")"
    $marian/build/marian-decoder \
        -d $GPU \
        -n  \
        -v data/train.bpe.$SRC.json data/train.bpe.$TRG.json \
        -m model/model.iter$BEST.npz \
        < data/"${test_file%.*}".bpe.$SRC \
        > data/"${test_file%.*}".out

    sleep 5

    cat data/"${test_file%.*}".out \
        | sed -r 's/\@\@ //g' | sed -r 's/\@\@$//g' \
        | $mosesdecoder/scripts/tokenizer/detokenizer.perl -l $TRG \
        | $mosesdecoder/scripts/recaser/detruecase.perl \
        | $mosesdecoder/scripts/ems/support/wrap-xml.perl $TRG data/"${test_file%.*}".$SRC.sgm \
        > data/"${test_file%.*}".out.sgm

    $mosesdecoder/scripts/generic/mteval-v13a.pl \
        -c \
        -s data/"${test_file%.*}".$SRC.sgm \
        -r data/"${test_file%.*}".$TRG.sgm \
        -t data/"${test_file%.*}".out.sgm \
        > data/"${test_file%.*}".out.bleu
done

sed -n -e 's/^.*BLEU score = *//p' data/*.out.bleu \
    | awk '{sum += $1 } END { if (NR > 0) print sum / NR }' \
    | (echo -n "Average BLEU score over the six test-sets: " && cat) >> data/pcf_avg.out.bleu

sed -n -e 's/^.*NIST score = *//p' data/*.out.bleu \
    | awk '{sum += $1 } END { if (NR > 0) print sum / NR }' \
    | (echo -n "Average NIST score over the six test-sets: " && cat) >> data/pcf_avg.out.nist
