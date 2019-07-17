import os
import sys
import nltk
from math import exp

reload(sys)
sys.setdefaultencoding('utf-8')
import io

nltk.download('punkt')

experiment='ced'
data = '../filtering/output/corpus_fasttext_filtered'
cut_off_value=0.25
lang='en'

if len(sys.argv) > 1: experiment = sys.argv[1]
if len(sys.argv) > 2: data = sys.argv[2]
if len(sys.argv) > 3: cut_off_value = float(sys.argv[3])
if len(sys.argv) > 4: lang = sys.argv[4]

data_en = data + '.{}'.format(lang)

nc_scores_file = 'output/{}/{}_{}_ced_scores.txt'.format(experiment, 'news-crawl', lang)
pc_scores_file = 'output/{}/{}_{}_ced_scores.txt'.format(experiment, 'paracrawl', lang)

ced_dom_scores = 'output/{}/filtered_data_scores'.format(experiment)

with io.open(data_en, 'r', encoding='utf-8') as lang, \
    open(nc_scores_file) as hI_x, open(pc_scores_file) as hN_x, \
    open(ced_dom_scores, 'w') as out:
    sentences = lang.readlines()
    hI_x_scores = hI_x.readlines()
    hN_x_scores = hN_x.readlines()

    assert len(sentences) == len(hI_x_scores) == len(hN_x_scores)

    for hI, hN, sentence in zip(hI_x_scores, hN_x_scores, sentences):
        h_diff = (abs(float(hI)) - abs(float(hN))) / len(nltk.word_tokenize(sentence))
        dom_exp = exp(-1.0 * h_diff)
        dom = min(dom_exp, 1.0)
        if dom < cut_off_value:
             dom = 0.0
        out.write("%f\n" % dom)
