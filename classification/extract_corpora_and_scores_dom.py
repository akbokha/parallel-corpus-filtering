import csv
import sys
import os

output_dir='./output'
if len(sys.argv) > 1:
    output_dir=sys.argv[1]

with open(os.path.join(output_dir, 'data_classified')) as data, \
    open(os.path.join(output_dir, 'filtered_data_raw.en'), 'w') as en, \
    open(os.path.join(output_dir, 'filtered_data_raw.de'), 'w') as de, \
    open(os.path.join(output_dir, 'filtered_data_scores'), 'w') as scores \
    open(os.path.join(output_dir, 'filtered_dom_src_scores'), 'w') as dom_src_scores \
    open(os.path.join(output_dir, 'filtered_dom_trg_scores'), 'w') as dom_trg_scores:
    writer_en = csv.writer(en, delimiter='\t')
    writer_de = csv.writer(de, delimiter='\t')
    writer_sc = csv.writer(scores, delimiter='\t')
    writer_dom_src = csv.writer(dom_src_scores, delimiter='\t')
    writer_dom_trg = csv.writer(dom_trg_scores, delimiter='\t')

    for line in csv.reader(data, delimiter='\t', quoting=csv.QUOTE_NONE):
        writer_en.writerow([line[2]])
        writer_de.writerow([line[3]])
        writer_sc.writerow([line[4]])
        if len(line) == 7:
            writer_dom_src.writerow([line[5]])
            writer_dom_trg.writerow([line[6])
