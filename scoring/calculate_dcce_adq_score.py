import os
import sys
from math import exp

experiment='dcce'
data = '../filtering/output/corpus_fasttext_filtered'

if len(sys.argv) > 1: experiment = sys.argv[1]
if len(sys.argv) > 2: data = sys.argv[2]

data_en = data + '.en'
data_de = data + '.de'

src = 'de'
trg = 'en'

hA_scores_file = 'output/{}/{}_{}_cce_scores.txt'.format(experiment, src, trg)
hB_scores_file = 'output/{}/{}_{}_cce_scores.txt'.format(experiment, trg, src)

dcce_adq_scores = 'output/{}/filtered_data_scores'.format(experiment)

with open(data_en) as en, open(data_de) as de, \
    open(hA_scores_file) as hAs, open(hB_scores_file) as hBs, \
    open(dcce_adq_scores, 'w') as out:
    en_sentences = en.readlines()
    de_sentences = de.readlines()
    hA_scores = hAs.readlines()
    hB_scores = hBs.readlines()

    assert len(en_sentences) == len(de_sentences) == len(hA_scores) == len(hB_scores)

    for en_s, de_s, hA, hB in zip(en_sentences, de_sentences, hA_scores, hB_scores):
        hA, hB = abs(hA), abs(hB)
        dcce_adq_score = exp((-1.0 * abs(hA - hB)) + (0.5 * (hA + hB)))
        out.write("%f\n" % dcce_adq_score)
