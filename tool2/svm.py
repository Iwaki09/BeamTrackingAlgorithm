# 必要なライブラリのインポート
from sklearn import datasets
from sklearn.model_selection import train_test_split
from sklearn.svm import LinearSVC, SVC
from sklearn.metrics import accuracy_score
from sklearn.preprocessing import StandardScaler

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
model_name = './svm_noacc_ad'

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
X = ss.fit_transform(df[['dist', 'speed', 'angle', 'angle_diff']].to_numpy())
# X = ss.fit_transform(df[['x', 'y', 'speed']].to_numpy())
y = df['best'].to_numpy()

# データセットをトレーニングセットとテストセットに分割
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# SVMモデルの作成と学習

# svm_model = LinearSVC(C=1)  # カーネルは線形カーネルを使用
# svm_model = SVC(kernel='poly', degree=3, coef0=1, C=5)
svm_model = SVC(kernel='rbf', gamma=6, C=32768, random_state=0)
# svm_model = SVC(kernel='sigmoid')

svm_model.fit(X_train, y_train)

# テストデータでの予測
y_pred = svm_model.predict(X_test)

# 精度の評価
accuracy = accuracy_score(y_test, y_pred)
print(f"Accuracy: {accuracy}")

# 3Dプロットの作成
fig = plt.figure(figsize=(10, 8))
ax = fig.add_subplot(111, projection='3d')

# X = std*X_std + mean
X_train_nonstd = ss.scale_*X_train + ss.mean_
# print(X_train_nonstd)

# トレーニングデータのプロット
labels = ['2dim', '4way']
for i in np.unique(y_train):
    indices = np.where(y_train == i)  
    ax.scatter(X_train_nonstd[indices, 0], X_train_nonstd[indices, 1], X_train_nonstd[indices, 2], label=labels[i])

# 分離超平面のプロット
# 3次元データの場合、超平面は2次元平面として可視化できる
xx, yy = np.meshgrid(np.linspace(X[:, 0].min(), X[:, 0].max(), 100),
                     np.linspace(X[:, 1].min(), X[:, 1].max(), 100))

# 平面の式 ax+by+cz+d=0 a:svm_model.coef_[0, 0], b:svm_model.coef_[0, 1], c:svm_model.coef_[0, 2], d:vm_model.intercept_[0]
# zz = (-svm_model.intercept_[0] - svm_model.coef_[0, 0] * xx - svm_model.coef_[0, 1] * yy) / svm_model.coef_[0, 2]
# xx, yy, zz = [p * std + mean for p, std, mean in zip([xx, yy, zz], ss.scale_, ss.mean_)]
# ax.plot_surface(xx, yy, zz, alpha=0.3, color='gray')

# サポートベクトルのプロット
# ax.scatter(svm_model.support_vectors_[:, 0], svm_model.support_vectors_[:, 1], svm_model.support_vectors_[:, 2],
        #    facecolors='none', edgecolors='r', s=100, label='Support Vectors')

with open(os.path.join(ml_models_dir, model_name+'_model.pkl'), 'wb') as f:
    pickle.dump(svm_model, f)
with open(os.path.join(ml_models_dir, model_name+'_stats.csv'), 'w') as f:
    writer = csv.writer(f)
    writer.writerow(ss.scale_)
    writer.writerow(ss.mean_)

# プロットの設定
ax.set_xlabel('Distance from BS')
ax.set_ylabel('Speed')
ax.set_zlabel('Angle')
# ax.set_xlabel('X')
# ax.set_ylabel('Y')
# ax.set_zlabel('Speed')
ax.set_title('SVM 3D Plot')

# 凡例の表示
ax.legend()

# グラフの表示
# plt.show()

# print(df[['dist', 'speed', 'accel_abs']][100:11200].min())