import os
import sys
import random

experiment='random'
data = '../data/official_shared_task_data/corpus'

if len(sys.argv) > 1: experiment = sys.argv[1]
if len(sys.argv) > 2: data = sys.argv[2]

data_en = data + '.en'
data_de = data + '.de'

random_scores = 'output/{}/filtered_data_scores'.format(experiment)

with open(data_en) as en, open(data_de) as de, \
    open(random_scores, 'w') as out:
    en_sentences = en.readlines()
    de_sentences = de.readlines()

    assert len(en_sentences) == len(de_sentences)

    for _ in range(len(en_sentences))
        out.write("%f\n" % random.uniform(0, 1))
