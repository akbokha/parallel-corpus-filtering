import os
import sys
import csv
import fasttext
import threading
import nltk
import Levenshtein
import regex

regex_alpha = regex.compile("[[:alpha:]]")
regex_url = regex.compile(
    '((?:https?://|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]|\((:?[^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:\'".,<>?\xab\xbb\u201c\u201d\u2018\u2019]))')
regex_email_address = regex.compile('[^@]+@[^@]+\.[^@]+')

lock = threading.Lock()

prob_cutoff_value = 0.5
data = '../data/official_shared_task_data/data'

if len(sys.argv) > 1:
    prob_cutoff_value = sys.argv[1]
if len(sys.argv) > 2:
    data = sys.argv[2]

output_dir = './output'
corpus_en = os.path.join(output_dir, 'corpus_fasttext_prob_and_new_hardrules.en')
corpus_de = os.path.join(output_dir, 'corpus_fasttext_prob_and_new_hardrules.de')
parallel_corpus_out = os.path.join(output_dir, 'corpus_fasttext_prob_and_new_hardrules')
hardrules_annotation = os.path.join(output_dir, 'corpus_fasttext_prob_and_new_hardrules_annotation')

model = fasttext.load_model('lid.176.bin')

num_lines = sum(1 for line in open(data))

def identical(left, right):
    return left != right


def in_length_range(sentence):
    return 2 < len(nltk.word_tokenize(sentence)) <= 80


def minimal_edit_distance(left, right):
    return Levenshtein.distance(left, right) >= 2


def minimal_edit_distance_ratio(left, right):
    avg_sentence_length = (len(left) + len(right)) / 2
    return (Levenshtein.distance(left, right) / avg_sentence_length) >= 0.1


def length_ratio(left, right):
    return 0.4 <= float(len(left)) / float(len(right)) <= 2.5


def majority_alpha(sentence):
    return float(len(regex_alpha.findall(sentence))) / float(len(sentence)) >= 0.2


def consistency_of_special_tokens(left, right):
    same_urls= sorted(regex_url.findall(left)) == sorted(regex_url.findall(right))
    same_email_addresses = sorted(regex_email_address.findall(left)) == sorted(regex_email_address.findall(right))
    return same_urls and same_email_addresses


def discordant_with_hardrules(left, right):
    if not identical(left, right):
        return 'identical'
    elif not in_length_range(left):
        return 'in_length_range (left)'
    elif not in_length_range(right):
        return 'in_length_range (right)'
    elif not length_ratio(left, right):
        return 'length_ratio'
    elif not majority_alpha(left):
        return 'majority_alpha (left)'
    elif not majority_alpha(right):
        return 'majority_alpha (right)'
    elif not minimal_edit_distance(left, right):
        return 'minimal_edit_distance'
    elif not minimal_edit_distance_ratio(left, right):
        return 'minimal_edit_distance_ratio'
    elif not consistency_of_special_tokens(left, right):
        return 'consistency_of_special_tokens'
    return False


with open(data) as pc, open(corpus_en, 'w') as en, \
    open(corpus_de, 'w') as de, open(parallel_corpus_out, 'w') as pc_out, \
    open(hardrules_annotation, 'w') as an:
    parallel_corpus = csv.reader(pc, delimiter='\t', quoting=csv.QUOTE_NONE)
    writer_en = csv.writer(en)
    writer_de = csv.writer(de)
    writer_pc = csv.writer(pc_out, delimiter='\t')
    writer_an = csv.writer(an)

    for num, line in enumerate(parallel_corpus):
        print('Progress: {0:.3f}'.format((num / num_lines) * 100))
        en_sentence, de_sentence, _ = line
        disc_with_hardrules = discordant_with_hardrules(en_sentence, de_sentence)
        if not disc_with_hardrules:
            en_pred, en_prob = model.predict(en_sentence)
            de_pred, de_prob = model.predict(de_sentence)
            if (en_pred[0] == '__label__en' and de_pred[0] == '__label__de'):
                if en_prob >= prob_cutoff_value and de_prob >= prob_cutoff_value:
                    with lock:
                        writer_en.writerow([en_sentence])
                        writer_de.writerow([de_sentence])
                        writer_pc.writerow(['url1', 'url2', en_sentence, de_sentence])
                else:
                    writer_an.writerow(['fasttext_prob'])
            else:
                writer_an.writerow(['fasttext_label'])
        else:
            writer_an.writerow([disc_with_hardrules])
