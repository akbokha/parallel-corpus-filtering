import os
import glob
import random

number_of_sentences=int(1e6)

wmt18_dir = '../data/wmt18_translation_task_preprocessed'
wmt18_corpus = os.path.join(wmt18_dir, 'corpus_no_paracrawl')

sentence_pairs_de = list()
sentence_pairs_en = list()

with open(wmt18_corpus.__add__('.de')) as f:
    sentence_pairs_de = f.readlines()

with open(wmt18_corpus.__add__('.en')) as f:
    sentence_pairs_en = f.readlines()

random_sentence_pair_indices = random.sample(range(1, len(sentence_pairs_de)), number_of_sentences)

de_selection = [sentence_pairs_de[i] for i in random_sentence_pair_indices]
en_selection = [sentence_pairs_en[i] for i in random_sentence_pair_indices]

with open(os.path.join(wmt18_dir, 'wmt18_pp_parallel_data_random_1M_selection.de'), 'w') as out:
    out.writelines(de_selection)

with open(os.path.join(wmt18_dir, 'wmt18_pp_parallel_data_random_1M_selection.en'), 'w') as out:
    out.writelines(en_selection)
