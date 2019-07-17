import os
import sys
import csv
import fasttext
import threading

lock = threading.Lock()

data = '../data/official_shared_task_data/data'
if len(sys.argv) > 1:
    data = sys.argv[1]

output_dir = './output'
corpus_en = os.path.join(output_dir, 'corpus_fasttext_filtered.en')
corpus_de = os.path.join(output_dir, 'corpus_fasttext_filtered.de')
parallel_corpus_out = os.path.join(output_dir, 'corpus_fasttext_filtered')

model = fasttext.load_model('lid.176.bin')

num_lines = sum(1 for line in open(data))

with open(data) as pc, open(corpus_en, 'w') as en, \
    open(corpus_de, 'w') as de, open(parallel_corpus_out, 'w') as pc_out:
    parallel_corpus = csv.reader(pc, delimiter='\t', quoting=csv.QUOTE_NONE)
    writer_en = csv.writer(en)
    writer_de = csv.writer(de)
    writer_pc = csv.writer(pc_out, delimiter='\t')

    for num, line in enumerate(parallel_corpus):
        print('Progress: {0:.3f}'.format((num / num_lines) * 100))
        en_sentence, de_sentence, _ = line
        if en_sentence and de_sentence:
            en_pred, prob = model.predict(en_sentence)
            de_pred, prob = model.predict(de_sentence)
            if en_pred[0] == '__label__en' and de_pred[0] == '__label__de':
                with lock:
                    writer_en.writerow([en_sentence])
                    writer_de.writerow([de_sentence])
                    writer_pc.writerow(['url1', 'url2', en_sentence, de_sentence])
