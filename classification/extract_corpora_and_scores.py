import csv

with open('./output/data_classified') as data, \
    open('./output/filtered_data_raw.en', 'w') as en, \
    open('./output/filtered_data_raw.de', 'w') as de, \
    open('./output/filtered_data_scores', 'w') as scores:
    writer_en = csv.writer(en, delimiter='\t')
    writer_de = csv.writer(de, delimiter='\t')
    writer_sc = csv.writer(scores, delimiter='\t')

    for line in csv.reader(data, delimiter='\t', quoting=csv.QUOTE_NONE):
            writer_en.writerow([line[2]])
            writer_de.writerow([line[3]])
            writer_sc.writerow([line[4]])
