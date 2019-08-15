#!/bin/sh -v

DIRS="$(ssh abdel@magni.inf.ed.ac.uk 'find /fs/bil0/abdel/parallel-corpus-filtering/experiments/* -maxdepth 0  -type d -exec basename {} \;')"

echo $DIRS

RESULTS_DIR="/Volumes/SandiskFD/University/parallel-corpus-filtering/experiments"
mkdir -p $RESULTS_DIR

for dir in $DIRS ; do
    if ! test -f $RESULTS_DIR/$dir.tar.gz; then
        cd $RESULTS_DIR

        mkdir -p $dir/model

        scp abdel@magni.inf.ed.ac.uk:/fs/bil0/abdel/parallel-corpus-filtering/experiments/$dir/model/valid.log ./$dir/model/valid.log

        BEST=`cat ./$dir/model/valid.log | grep translation | sort -rg -k12,12 -t' ' | cut -f8 -d' ' | head -n1`

        rsync -au --progress \
            abdel@magni.inf.ed.ac.uk:/fs/bil0/abdel/parallel-corpus-filtering/experiments/$dir/model/model.iter$BEST.* ./$dir/model/

        rsync -au --progress \
            --exclude "train.*" \
            abdel@magni.inf.ed.ac.uk:/fs/bil0/abdel/parallel-corpus-filtering/experiments/$dir/data ./$dir

        rsync -au --progress \
            --exclude "*.npz" --exclude "*.bpe" --exclude "*.bleu" \
            abdel@magni.inf.ed.ac.uk:/fs/bil0/abdel/parallel-corpus-filtering/experiments/$dir/model ./$dir

        tar -czvf $dir.tar.gz $dir && rm -rf $dir
    fi
done
