import os
import sys
import csv
from langid import classify

data = '../data/official_shared_task_data/data'
if len(sys.argv) > 1:
    data = sys.argv[1]

output_dir = './output'
corpus_en = os.path.join(output_dir, 'corpus_lang_filtered.en')
corpus_de = os.path.join(output_dir, 'corpus_lang_filtered.de')

with open(data) as pc, open(corpus_en, 'w') as en, open(corpus_de, 'w') as de:
    parallel_corpus = csv.reader(pc, delimiter='\t', quoting=csv.QUOTE_NONE)
    writer_en = csv.writer(en)
    writer_de = csv.writer(de)

    for line in parallel_corpus:
        en_sentence, de_sentence, _ = line
        if classify(en_sentence)[0] == 'en' and classify(de_sentence)[0] == 'de':
            writer_en.writerow([en_sentence])
            writer_de.writerow([de_sentence])
