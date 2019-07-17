cut -f1 en-de.bicleaner07.txt | shuf -n 10000000 | perl -ne 'print if(split(/\s/, $_) < 100)' | head -n 1000000 > paracrawl_v4_en_de_1M_sen.en
cut -f2 en-de.bicleaner07.txt | shuf -n 10000000 | perl -ne 'print if(split(/\s/, $_) < 100)' | head -n 1000000 > paracrawl_v4_en_de_1M_sen.de

cut -f1 en-de.bicleaner07.txt | shuf -n 1000000 | perl -ne 'print if(split(/\s/, $_) < 100)' | head -n 100000 > paracrawl_v4_en_de_1M_sen_val.en
cut -f2 en-de.bicleaner07.txt | shuf -n 1000000 | perl -ne 'print if(split(/\s/, $_) < 100)' | head -n 100000 > paracrawl_v4_en_de_1M_sen_val.de
