import warnings
import pandas as pd
import numpy as np
import os
import xgboost as xgb
import sys

warnings.filterwarnings('ignore')

# 引数を受け取る
scenario = sys.argv[1]
model_name = sys.argv[2]
model, specific = model_name.split('_')
type = sys.argv[3]
ver = sys.argv[4]
x = float(sys.argv[5])
y = float(sys.argv[6])
speed = float(sys.argv[7])
angle_prev = float(sys.argv[8])

ml_models_dir = '../datasource'

if (type == '1') or (type == '2'):
    # ガイドファイルを読み込んで、xからdistとangleを計算
    df_guide = pd.read_csv(os.path.join(ml_models_dir, scenario+'_guide.csv'), names=['x', 'y', 'angle'])
    nearest_x = df_guide.iloc[(df_guide['x'] - x).abs().idxmin()]['x']
    angle = df_guide[df_guide['x'] == nearest_x]['angle'].values[0]
    dist = np.sqrt((30-x)**2 + (y+5)**2)
    angle_diff = angle - angle_prev
elif type == '3':
    hoge

if (model == 'dt') or (model == 'svm'):
    
elif model == 'xgb':
    model = xgb.Booster({'nthread': 4})
    model.load_model(os.path.join(ml_models_dir, model+'_'+specific+'-type'+type+'-ver'+ver+'_model.json'))

if (type == '1') or (type == '3'):
    # 1行目がscale, 2行目がmean
    stats = pd.read_csv(os.path.join(ml_models_dir, model_name+'_stats.csv'), names=['dist', 'speed', 'angle', 'angle_diff']).to_numpy()
    # データを標準化
    [dist, speed, angle, angle_diff] = ([dist, speed, angle, angle_diff] - stats[1]) / stats[0]
    # デバッグ用
    tmp = [dist, speed, angle, angle_diff] * stats[0] + stats[1]
    # print(stats[0])

if model == 'dt':
    dt()
elif model == 'svm':
    
elif model == 'xgb':
    data = np.array([dist, speed, angle, angle_diff]).reshape(1, -1)
    data_xgb = xgb.DMatrix(data)
    prediction = model.predict(data_xgb)[0]

prediction2 = 1 if prediction >= 0.5 else 0

if prediction2 == 0:
    search_way = 22
elif prediction2 == 1:
    search_way = 4

print(search_way, tmp)