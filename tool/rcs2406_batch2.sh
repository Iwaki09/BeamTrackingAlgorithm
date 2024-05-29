#!/bin/bash

python -m tool.ml svm korakuen  --t 1 --v 1 --i 10
python -m tool.ml svm korakuen  --t 2 --v 1 --i 10
python -m tool.ml dt korakuen  --t 1 --v 1 --i 1
python -m tool.ml dt korakuen  --t 2 --v 1 --i 1
python -m tool.ml xgb korakuen  --t 1 --v 1 --i 1
python -m tool.ml xgb korakuen  --t 2 --v 1 --i 1

python -m tool.ml svm paris2  --t 1 --v 1 --i 10
python -m tool.ml svm paris2  --t 2 --v 1 --i 10
python -m tool.ml dt paris2  --t 1 --v 1 --i 1
python -m tool.ml dt paris2  --t 2 --v 1 --i 1
python -m tool.ml xgb paris2  --t 1 --v 1 --i 1
python -m tool.ml xgb paris2  --t 2 --v 1 --i 1
