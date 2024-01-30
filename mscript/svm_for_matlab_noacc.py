import pickle
import pandas as pd
import numpy as np
import os
import sklearn

def svm_for_matlab_noacc(model_basename, scenario, x, speed):

    ml_models_dir = '../ml_models'

    # ガイドファイルを読み込んで、xからdistとangleを計算
    df_guide = pd.read_csv(os.path.join(ml_models_dir, scenario+'_guide.csv'), names=['x', 'y', 'angle'])
    y = df_guide.loc[df_guide['x'] == x, 'y'].head(1)
    angle = df_guide.loc[df_guide['x'] == x, 'angle'].head(1)
    dist = 

    # 保存したモデルをロード
    with open(os.path.join(ml_models_dir, model_basename+'.pkl'), 'rb') as model_path:
        svm_model = pickle.load(model_path)

    # 1行目がscale, 2行目がmean
    stats = pd.read_csv(os.path.join(ml_models_dir, 'svm_stats_noacc.csv'), names=['dist', 'speed', 'angle']).to_numpy()
    # データを標準化
    [dist, speed, angle] = ([dist, speed, angle] - stats[1]) / stats[0]
    # デバッグ用
    tmp = [dist, speed, angle]
    print(stats[0])

    data = np.array([dist, speed, angle]).reshape(1, -1)
    prediction = svm_model.predict(data)

    if prediction[0] == 0:
        search_way = 22
    elif prediction[0] == 1:
        search_way = 4

    return [search_way, tmp]

res = svm_for_matlab_noacc(model_basename, dist, speed, angle)