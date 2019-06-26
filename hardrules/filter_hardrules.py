import csv
import sys
import os

output_dir='./output'
if len(sys.argv) > 1:
    output_dir=sys.argv[1]

data_file = 'data_hardrules'

input=os.path.join(output_dir, data_file)
output=os.path.join(output_dir, data_file + '_filtered')
annotation=os.path.join(output_dir, data_file + '_annotated')
annotation_output=os.path.join(output_dir, data_file + '_discarded_annotation')

with open(input) as fd, open(output, 'w') as nd:
    writer = csv.writer(nd, delimiter='\t')
    for line in csv.reader(fd, delimiter='\t', quoting=csv.QUOTE_NONE):
        if not 'discard' in line:
            writer.writerow(['url1', 'url2', line[0], line[1]])

with open(annotation) as fd, open(annotation_output, 'w') as nd:
    writer = csv.writer(nd, delimiter='\t')
    for line in csv.reader(fd, delimiter='\t', quoting=csv.QUOTE_NONE):
        writer.writerow([line[2]])
