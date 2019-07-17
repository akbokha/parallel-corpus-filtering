import os
import sys
import csv
import threading
from langid import classify

lock = threading.Lock()

data = '../data/official_shared_task_data/data'
output = 'corpus_langid_filtered'
if len(sys.argv) > 1:
    data = sys.argv[1]
if len(sys.argv) > 2:
    output = sys.argv[2]

num_lines = sum(1 for line in open(data))

output_dir = './output'
corpus_en = os.path.join(output_dir, output + '.en')
corpus_de = os.path.join(output_dir, output + '.de')

with open(data) as pc, open(corpus_en, 'wb') as en, open(corpus_de, 'wb') as de:
    parallel_corpus = csv.reader(pc, delimiter='\t', quoting=csv.QUOTE_NONE)
    writer_en = csv.writer(en)
    writer_de = csv.writer(de)

    for num, line in enumerate(parallel_corpus):
        print('Progress: {0:.3f}'.format((num / num_lines) * 100))
        en_sentence, de_sentence, _ = line
        if en_sentence and de_sentence:
            if classify(en_sentence)[0] == 'en' and classify(de_sentence)[0] == 'de':
                with lock:
                    writer_en.writerow([en_sentence])
                    writer_de.writerow([de_sentence])
        else:
            print('invalid line')
