import os
import re

number_of_sentences=int(1e6)

wmt18_dir = '../data/wmt18_translation_task_preprocessed'
wmt18_corpus = os.path.join(wmt18_dir, 'corpus')

de_sentences = list()
en_sentences = list()

with open(wmt18_corpus) as f:
    lang_ids = ['en', 'de']
    for line in f:
        line = line.rstrip()
        de_sentence, en_sentence, source = re.split(r'\t+', line)
        if not (source == 'PARACRAWL' or all(s in lang_ids for s in [de_sentence, en_sentence])):
            de_sentences.append(de_sentence)
            en_sentences.append(en_sentence)

with open(os.path.join(wmt18_dir, 'corpus_no_paracrawl.de'), 'w') as out:
    for sentence in de_sentences:
        out.write("%s\n" % sentence)

with open(os.path.join(wmt18_dir, 'corpus_no_paracrawl.en'), 'w') as out:
    for sentence in en_sentences:
        out.write("%s\n" % sentence)
