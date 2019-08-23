#!/bin/bash
set +e

experiments="$(find ../experiments/* -maxdepth 0  -type d -exec basename {} \;)"

for experiment in $experiments; do
    ./score-test.sh $experiment
    ./score-pcf-test.sh $experiment
done
