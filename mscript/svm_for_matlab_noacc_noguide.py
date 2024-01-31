import pickle
import pandas as pd
import numpy as np
import os
import sklearn

def svm_for_matlab_noacc_noguide(model_basename, scenario, x, y, speed):

    ml_models_dir = '../ml_models'

    # ガイドファイルを読み込んで、xからdistとangleを計算
    df_guide = pd.read_csv(os.path.join(ml_models_dir, scenario+'_guide.csv'), names=['x', 'y', 'angle'])
    nearest_x = df_guide.iloc[(df_guide['x'] - x).abs().idxmin()]['x']
    angle = df_guide[df_guide['x'] == nearest_x]['angle'].values[0]
    dist = np.sqrt((30-x)**2 + (y+5)**2)

    # 保存したモデルをロード
    with open(os.path.join(ml_models_dir, model_basename+'_model.pkl'), 'rb') as model_path:
        svm_model = pickle.load(model_path)

    # 1行目がscale, 2行目がmean
    stats = pd.read_csv(os.path.join(ml_models_dir, model_basename+'_stats.csv'), names=['dist', 'speed', 'angle']).to_numpy()
    # データを標準化
    [dist, speed, angle] = ([dist, speed, angle] - stats[1]) / stats[0]
    # デバッグ用
    tmp = [dist, speed, angle] * stats[0] + stats[1]
    # print(stats[0])

    data = np.array([dist, speed, angle]).reshape(1, -1)
    prediction = svm_model.predict(data)

    if prediction[0] == 0:
        search_way = 22
    elif prediction[0] == 1:
        search_way = 4

    return [search_way, tmp]

res = svm_for_matlab_noacc(model_basename, scenario, x, y, speed)