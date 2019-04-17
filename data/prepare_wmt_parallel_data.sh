#!/bin/sh

# create top-level directory for all wmt news translation task parallel data
mkdir ./wmt_parallel_data && \
cd ./wmt_parallel_data

# rapid-2016 data: fetch, uncompress and remove all compressed file
mkdir ./rapid2016 && \
cd ./rapid2016

curl http://data.statmt.org/wmt18/translation-task/rapid2016.tgz > rapid2016.tgz && \
tar -xvzf rapid2016.tgz &&\
rm rapid2016.tgz
cd ..

# common-crawl data: fetch, uncompress and remove all compressed file
mkdir ./commoncrawl && \
cd ./commoncrawl

curl https://www.statmt.org/wmt13/training-parallel-commoncrawl.tgz > commoncrawl.tgz && \
tar -xvzf commoncrawl.tgz &&\
rm commoncrawl.tgz
cd ..

# europarl v7 data: fetch, uncompress and remove all compressed file
mkdir ./europarl && \
cd ./europarl

curl https://www.statmt.org/wmt13/training-parallel-europarl-v7.tgz > europarl.tgz && \
tar -xvzf europarl.tgz &&\
rm europarl.tgz &&\
mv training/* . &&\
rm -rf training
cd ..

# news-commentary v13 data: fetch, uncompress and remove all compressed file
mkdir ./news_commentary_v13 && \
cd ./news_commentary_v13

curl http://data.statmt.org/wmt18/translation-task/training-parallel-nc-v13.tgz > nc_v13.tgz && \
tar -xvzf nc_v13.tgz &&\
rm nc_v13.tgz &&\
mv training-parallel-nc-v13/* . &&\
rm -rf training-parallel-nc-v13
cd ..

# remove all the parallel data that does not contain German/is not parallel to a German corpus
find * -type f -not -name "*de*" -exec rm -f {} \;
