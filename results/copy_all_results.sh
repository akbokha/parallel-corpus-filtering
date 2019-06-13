#!/bin/bash -v

DIRS="$(ssh abdel@magni.inf.ed.ac.uk 'ls -d /fs/bil0/abdel/parallel-corpus-filtering/results/*/ | grep -Eo '[^/]+/?$' | tail -1')"

for dir in $DIRS ; do
    if ! test -f $dir/exp_files.tar.gz; then
        rsync -au --progress \
            abdel@magni.inf.ed.ac.uk:/fs/bil0/abdel/parallel-corpus-filtering/results/$dir ./$dir
        find ./$dir -name "*.bpe" \
            -o -name "*.de" \
            -o -name "*.en" \
            -o -name "*.json" \
            -o -name "*.npz" \
            | tee >(xargs rm -f) >(tar -czf ./$dir/exp_files.tar.gz -T -)
    fi
done
