#!/bin/bash -v

# experiment folder that needs to be copied to local machine. All folders (*) if not specified
EXP=${1:-"*"}

rsync -au --progress \
    abdel@magni.inf.ed.ac.uk:/fs/bil0/abdel/parallel-corpus-filtering/results/$EXP .

if [ "$EXP" != "*" ]; then
    find ./$EXP -name "*.bpe" \
        -o -name "*.de" \
        -o -name "*.en" \
        -o -name "*.json" \
        -o -name "*.npz" \
        | tee >(xargs rm -f) >(tar -czf ./$EXP/exp_files.tar.gz -T -)
else
    for d in */ ; do
        find ./$d -name "*.bpe" \
            -o -name "*.de" \
            -o -name "*.en" \
            -o -name "*.json" \
            -o -name "*.npz" \
            | tar -czf ./$d/exp_files.tar.gz -T -
    done
fi
