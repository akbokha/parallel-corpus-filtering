import csv
import sys
import os

output_dir='./output'
experiment='bicleaner_v1.1'
if len(sys.argv) > 1:
    experiment=sys.argv[1]

data_file = os.path.join(output_dir, experiment, 'data_hardrules_filtered')

output_en = os.path.join(output_dir, experiment, 'data_hardrules_filtered.en')
output_de = os.path.join(output_dir, experiment, 'data_hardrules_filtered.de')

with open(data_file) as df, open(output_en, 'w') as en, open(output_de, 'w') as de:
    writer_en = csv.writer(en, delimiter='\t')
    writer_de = csv.writer(de, delimiter='\t')

    for line in csv.reader(df, delimiter='\t', quoting=csv.QUOTE_NONE):
        writer_en.writerow([line[2]])
        writer_de.writerow([line[3]])
