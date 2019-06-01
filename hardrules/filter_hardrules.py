import csv

with open('./output/data_hardrules') as fd, open('./output/data_filtered_hardrules', 'w') as nd:
    writer = csv.writer(nd, delimiter='\t')
    for line in csv.reader(fd, delimiter='\t', quoting=csv.QUOTE_NONE):
        if not 'discard' in line:
            writer.writerow(['url1', 'url2', line[0], line[1]])
