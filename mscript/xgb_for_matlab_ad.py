import warnings
warnings.filterwarnings('ignore')

import pandas as pd
import numpy as np
import os
import xgboost as xgb
import sys

# 引数を受け取る
model_basename = sys.argv[1]
scenario = sys.argv[2]
x = float(sys.argv[3])
y = float(sys.argv[4])
speed = float(sys.argv[5])
angle_prev = float(sys.argv[6])


ml_models_dir = '../models'

# ガイドファイルを読み込んで、xからdistとangleを計算
df_guide = pd.read_csv(os.path.join(ml_models_dir, scenario+'_guide.csv'), names=['x', 'y', 'angle'])
nearest_x = df_guide.iloc[(df_guide['x'] - x).abs().idxmin()]['x']
angle = df_guide[df_guide['x'] == nearest_x]['angle'].values[0]
dist = np.sqrt((30-x)**2 + (y+5)**2)

angle_diff = angle - angle_prev

# 保存したモデルをロード
model = xgb.Booster({'nthread': 4})
model.load_model(os.path.join(ml_models_dir, model_basename+'_model.json'))

# 1行目がscale, 2行目がmean
stats = pd.read_csv(os.path.join(ml_models_dir, model_basename+'_stats.csv'), names=['dist', 'speed', 'angle', 'angle_diff']).to_numpy()
# データを標準化
[dist, speed, angle, angle_diff] = ([dist, speed, angle, angle_diff] - stats[1]) / stats[0]
# デバッグ用
tmp = [dist, speed, angle, angle_diff] * stats[0] + stats[1]
# print(stats[0])

data = np.array([dist, speed, angle, angle_diff]).reshape(1, -1)
data_xgb = xgb.DMatrix(data)
prediction = model.predict(data_xgb)[0]
prediction2 = 1 if prediction >= 0.5 else 0

if prediction2 == 0:
    search_way = 22
elif prediction2 == 1:
    search_way = 4

print(search_way, tmp[2], tmp[3])