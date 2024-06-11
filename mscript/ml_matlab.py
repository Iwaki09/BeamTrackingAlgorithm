import warnings
# ここにないとダメ
warnings.filterwarnings('ignore')
import pickle
import pandas as pd
import numpy as np
import os
import xgboost as xgb
import sys

# 引数を受け取る
scenario = sys.argv[1]
modelname_arg = sys.argv[2]
modelname, specific = modelname_arg.split('_')
type = sys.argv[3][4:]
ver = sys.argv[4][3:]
x = float(sys.argv[5])
y = float(sys.argv[6])
speed = float(sys.argv[7])
angle_prev = float(sys.argv[8])

ml_models_dir = '../model'
guide_dir = '../datasource'

if (type == '1') or (type == '2'):
    # ガイドファイルを読み込んで、xからdistとangleを計算
    df_guide = pd.read_csv(os.path.join(guide_dir, scenario+'_guide.csv'), names=['x', 'y', 'angle'])
    nearest_x = df_guide.iloc[(df_guide['x'] - x).abs().idxmin()]['x']
    angle = df_guide[df_guide['x'] == nearest_x]['angle'].values[0]
    dist = np.sqrt((30-x)**2 + (y+5)**2)
    angle_diff = angle - angle_prev
elif type == '3':
    pass

if (modelname == 'dt') or (modelname == 'svm'):
    with open(os.path.join(ml_models_dir, modelname+'_'+specific+'-type'+type+'-ver'+ver+'_model.pkl'), 'rb') as model_path:
        model = pickle.load(model_path)
    
elif modelname == 'xgb':
    model = xgb.Booster({'nthread': 4})
    model.load_model(os.path.join(ml_models_dir, modelname+'_'+specific+'-type'+type+'-ver'+ver+'_model.json'))

if (type == '1') or (type == '3'):
    # 1行目がscale, 2行目がmean
    stats = pd.read_csv(os.path.join(ml_models_dir, modelname+'_'+specific+'-type'+type+'-ver'+ver+'_stats.csv'), names=['dist', 'speed', 'angle', 'angle_diff']).to_numpy()
    # データを標準化
    [dist, speed, angle, angle_diff] = ([dist, speed, angle, angle_diff] - stats[1]) / stats[0]
    # デバッグ用
    tmp = [dist, speed, angle, angle_diff] * stats[0] + stats[1]
    data = np.array([dist, speed, angle, angle_diff]).reshape(1, -1)
    # print(stats[0])
elif type == '2':
    stats = pd.read_csv(os.path.join(ml_models_dir, modelname+'_'+specific+'-type'+type+'-ver'+ver+'_stats.csv'), names=['angle', 'angle_diff']).to_numpy()
    # データを標準化
    [angle, angle_diff] = ([angle, angle_diff] - stats[1]) / stats[0]
    # デバッグ用
    tmp = [angle, angle_diff] * stats[0] + stats[1]
    data = np.array([angle, angle_diff]).reshape(1, -1)

if (modelname == 'dt') or (modelname == 'svm'):
    prediction = model.predict(data)
    prediction2 = prediction[0]
elif modelname == 'xgb':
    data_xgb = xgb.DMatrix(data)
    prediction = model.predict(data_xgb)[0]
    prediction2 = 1 if prediction >= 0.5 else 0

if prediction2 == 0:
    search_way = 22
elif prediction2 == 1:
    search_way = 4

print(search_way, tmp)