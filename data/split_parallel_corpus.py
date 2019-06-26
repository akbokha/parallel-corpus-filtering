import os
import sys
import csv

data_dir = './official_shared_task_data'
parallel_corpus_data = os.path.join(data_dir, 'data')

if len(sys.argv) > 1:
    parallel_corpus_data = sys.argv[1]

output_dir = data_dir
if len(sys.argv) > 2:
    output_dir = sys.argv[2]

corpus_en = os.path.join(output_dir, 'corpus.en')
corpus_de = os.path.join(output_dir, 'corpus.de')

with open(parallel_corpus_data) as pc, open(corpus_en, 'w') as en, open(corpus_de, 'w') as de:
    parallel_corpus = csv.reader(pc, delimiter='\t', quoting=csv.QUOTE_NONE)
    writer_en = csv.writer(en)
    writer_de = csv.writer(de)

    for line in parallel_corpus:
        writer_en.writerow([line[0]])
        writer_de.writerow([line[1]])
