import os
import glob
import random

number_of_sentences=int(1e6)

wmt_data_dir='../../translation/data'
wmt_corpus=os.path.join(wmt_data_dir, 'corpus')

sentence_pairs_de = list()
sentence_pairs_en = list()

with open(wmt_corpus + '.de', 'rb') as f_de:
    sentence_pairs_de.extend(f_de.readlines())

with open(wmt_corpus + '.en', 'rb') as f_en:
    sentence_pairs_en.extend(f_en.readlines())

print(len(sentence_pairs_en))
print(len(sentence_pairs_de))

random_sentence_pair_indices = random.sample(range(1, len(sentence_pairs_en)), number_of_sentences)

de_selection = [sentence_pairs_de[i] for i in random_sentence_pair_indices]
en_selection = [sentence_pairs_en[i] for i in random_sentence_pair_indices]

with open(os.path.join(wmt_data_dir, 'corpus_1M_random.de'), 'wb') as out:
    out.writelines(de_selection)

with open(os.path.join(wmt_data_dir, 'corpus_1M_random.en'), 'wb') as out:
    out.writelines(en_selection)
