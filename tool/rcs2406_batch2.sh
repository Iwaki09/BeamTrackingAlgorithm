#!/bin/bash

python -m tool.ml svm generic  --t 1 --v 1 --i 100
python -m tool.ml svm generic  --t 2 --v 1 --i 100
python -m tool.ml dt generic  --t 1 --v 1 --i 1
python -m tool.ml dt generic  --t 2 --v 1 --i 1
python -m tool.ml xgb generic  --t 1 --v 1 --i 1
python -m tool.ml xgb generic  --t 2 --v 1 --i 1
