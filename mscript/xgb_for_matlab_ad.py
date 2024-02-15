import pickle
import pandas as pd
import numpy as np
import os
import xgboost as xgb

def svm_for_matlab_anglediff(model_basename, scenario, x, y, speed, angle_prev):

    ml_models_dir = '../ml_models'

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
    stats = pd.read_csv(os.path.join(ml_models_dir, model_basename+'_stats.csv'), names=['angle', 'angle_diff']).to_numpy()
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

    # tmp[2]はangle
    return [search_way, tmp[0], tmp]

# model_basename = 'xgb_noacc_ad2'
# scenario = 'korakuen'
# x = 20
# y = 16
# speed = 5.5
# angle_prev = 90

res = svm_for_matlab_anglediff(model_basename, scenario, x, y, speed, angle_prev)
# print(res)