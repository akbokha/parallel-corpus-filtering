#!/bin/bash -v

DIRS="$(ssh abdel@magni.inf.ed.ac.uk 'find /fs/bil0/abdel/parallel-corpus-filtering/dev-tools/experiments/* -maxdepth 0  -type d -exec basename {} \;')"

RESULTS_DIR="../dev-tools/experiments"
mkdir -p $RESULTS_DIR

for dir in $DIRS ; do
    if ! test -f $RESULTS_DIR/$dir/exp_files.tar.gz; then
        rsync -au --progress \
            abdel@magni.inf.ed.ac.uk:/fs/bil0/abdel/parallel-corpus-filtering/dev-tools/experiments/$dir $RESULTS_DIR
        find $RESULTS_DIR/$dir -name "*.bpe" \
            -o -name "*.de" \
            -o -name "*.en" \
            -o -name "*.json" \
            -o -name "*.npz" \
            | tee >(xargs rm -f) >(tar -czf $RESULTS_DIR/$dir/exp_files.tar.gz -T -)
    fi
done
