# Parallel Corpus Filtering

This repository contains the scripts that were used for my dissertation, title _Parallel Corpus Filtering for Machine Translation._, at the University of Edinburgh. Some folders contain, in addition, back-ups of training logs of various NMT systems and language models that were trained and evaluated as part of this research project.

## Structure
* `bicleaner-train` - contains scripts that can be used to train bicleaner-classifier's.
* `classification` - contains scripts that can be used to classify sentence-pairs using bicleaner-classifier.
* `data` - contains some (relatively) small data files that are used across the project.
* `dev-tools` - contains the official configuration files and scripts that are used in the Shared Task on Parallel Corpus Filtering.
* `experiments` - contains the training logs and filtering performance scores of the systems that were evaluated in the research project.
* `filtering` - contains scripts that were used for rule-based filtering of parallel data.
* `hardrules` - contains scripts that were used to filter parallel data using bicleaner-hardrules.
* `models` - contains scripts that were used to train and evaluate NMT systems and language models that were used for dual conditional cross-entropy (dcce) scoring and cross-entropy difference (ced) scoring.
* `scoring` - contains scripts that were used for dcce and ced scoring.
* `scripts` - contains miscellaneous scripts used to, for example, back-up data from the cluster. 
* `subsampling` - contains scripts that are used to sample parallel data using sentence-pair scores.

