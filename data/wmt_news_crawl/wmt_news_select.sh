cat news.2015.en.shuffled.deduped news.2016.en.shuffled.deduped news.2017.en.shuffled.deduped | shuf -n 10000000 | perl -ne 'print if(split(/\s/, $_) < 100)' | head -n 1000000 > news_2015_-_2017_shuffled_1M_sen.en
cat news.2015.de.shuffled.deduped news.2016.de.shuffled.deduped news.2017.de.shuffled.deduped | shuf -n 10000000 | perl -ne 'print if(split(/\s/, $_) < 100)' | head -n 1000000 > news_2015_-_2017_shuffled_1M_sen.de

cat news.2015.en.shuffled.deduped news.2016.en.shuffled.deduped news.2017.en.shuffled.deduped | shuf -n 1000000 | perl -ne 'print if(split(/\s/, $_) < 100)' | head -n 100000 > news_2015_-_2017_shuffled_1M_sen_val.en
cat news.2015.de.shuffled.deduped news.2016.de.shuffled.deduped news.2017.de.shuffled.deduped | shuf -n 1000000 | perl -ne 'print if(split(/\s/, $_) < 100)' | head -n 100000 > news_2015_-_2017_shuffled_1M_sen_val.de
