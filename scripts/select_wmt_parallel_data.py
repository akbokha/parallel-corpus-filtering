import os
import glob
import random

number_of_sentences=int(1e6)

wmt_data_dir='../data/wmt_parallel_data'

wmt_parallel_copora=['commoncrawl', 'europarl', 'news_commentary_v13', 'rapid2016']
wmt_parallel_corpora_dirs = list()

for wmt_parallel_corpus in wmt_parallel_copora:
    wmt_parallel_corpora_dirs.append(os.path.join(wmt_data_dir, wmt_parallel_corpus))

parallel_corpora=list()

for dir in wmt_parallel_corpora_dirs:
    de_corpus = glob.glob(os.path.join(dir, '*.de'))[0]
    en_corpus = glob.glob(os.path.join(dir, '*.en'))[0]
    parallel_corpora.append((de_corpus, en_corpus))

sentence_pairs_de = list()
sentence_pairs_en = list()

for parallel_corpus in parallel_corpora:
    with open(parallel_corpus[0]) as f:
        sentence_pairs_de.extend(f.readlines())
    with open(parallel_corpus[1]) as f:
        sentence_pairs_en.extend(f.readlines())

random_sentence_pair_indices = random.sample(range(1, len(sentence_pairs_de)), number_of_sentences)

de_selection = [sentence_pairs_de[i] for i in random_sentence_pair_indices]
en_selection = [sentence_pairs_en[i] for i in random_sentence_pair_indices]

with open(os.path.join(wmt_data_dir, 'wmt_parallel_data_selection.de'), 'w') as out:
    out.writelines(de_selection)

with open(os.path.join(wmt_data_dir, 'wmt_parallel_data_selection.en'), 'w') as out:
    out.writelines(en_selection)
