# 必要なライブラリのインポート
from sklearn import datasets
from sklearn.model_selection import train_test_split
from sklearn.svm import LinearSVC, SVC
from sklearn.metrics import accuracy_score
from sklearn.preprocessing import StandardScaler

from sklearn.ensemble import RandomForestClassifier

import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import numpy as np

import csv
import os
import pandas as pd

import pprint

import pickle

dataset_dir = './dataset'
ml_models_dir = './ml_models'
model_name = './svm_noacc_ad2'

file_list = [file for file in os.listdir(dataset_dir) if file.startswith("all_dataset_")]

# 全てのCSVファイルを読み込んでDataFrameに結合
df = pd.concat([pd.read_csv(os.path.join(dataset_dir, file)) for file in file_list], ignore_index=True)
print(df.shape)

# 間引く
# interval = 1
# df = df.iloc[::interval]
df = df.sample(frac=0.05)

'''
位置(x), 位置(y), 基地局からの距離, 速度, 加速度x, 加速度y, 向き, SNRが良いほう(2dimなら0, 4wayなら1), accel絶対値
'''

ss = StandardScaler()
# X = ss.fit_transform(df[['dist', 'speed', 'accel_abs']].to_numpy())
# X = ss.fit_transform(df[['dist', 'speed', 'angle', 'angle_diff']].to_numpy())
X = ss.fit_transform(df[['angle', 'angle_diff']].to_numpy())
# X = ss.fit_transform(df[['x', 'y', 'speed']].to_numpy())
y = df['best'].to_numpy()

# データセットをトレーニングセットとテストセットに分割
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# SVMモデルの作成と学習

# ランダムフォレストモデルの作成と学習
rf_model = RandomForestClassifier(n_estimators=200, random_state=42)
rf_model.fit(X_train, y_train)

# テストデータでの予測
y_pred_rf = rf_model.predict(X_test)

# 精度の評価
accuracy_rf = accuracy_score(y_test, y_pred_rf)
print(f"Random Forest Accuracy: {accuracy_rf}")

# 3Dプロットの作成
fig = plt.figure(figsize=(10, 8))
ax = fig.add_subplot(111, projection='3d')

X_train_nonstd = ss.scale_*X_train + ss.mean_

with open(os.path.join(ml_models_dir, model_name+'_model.pkl'), 'wb') as f:
    pickle.dump(rf_model, f)
with open(os.path.join(ml_models_dir, model_name+'_stats.csv'), 'w') as f:
    writer = csv.writer(f)
    writer.writerow(ss.scale_)
    writer.writerow(ss.mean_)

# [dist, speed, angle, angle_diff] = ([12, 7.5, 90, 0] - ss.mean_) / ss.scale_
[angle, angle_diff] = ([90, 0] - ss.mean_) / ss.scale_
data = np.array([angle, angle_diff]).reshape(1, -1)
prediction1 = rf_model.predict(data)

# [dist, speed, angle, angle_diff] = ([19, 14, 111, 0.24] - ss.mean_) / ss.scale_
[angle, angle_diff] = ([111, 0.24] - ss.mean_) / ss.scale_
data = np.array([angle, angle_diff]).reshape(1, -1)
prediction2 = rf_model.predict(data)

print(prediction1, prediction2)