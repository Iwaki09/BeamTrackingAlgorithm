"""dist, angle, angle_diff"""

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
model_name = './svm_noacc_test'

def svm_exp(model, C=1, degree=1, coef0=1, gamma=1):

    file_list = [file for file in os.listdir(dataset_dir) if file.startswith("all_dataset_")]

    # 全てのCSVファイルを読み込んでDataFrameに結合
    df = pd.concat([pd.read_csv(os.path.join(dataset_dir, file)) for file in file_list], ignore_index=True)
    print(df.shape)

    # 間引く
    # interval = 50
    df = df.sample(frac=0.005)

    '''
    位置(x), 位置(y), 基地局からの距離, 速度, 加速度x, 加速度y, 向き, SNRが良いほう(2dimなら0, 4wayなら1), accel絶対値
    '''

    ss = StandardScaler()
    X = ss.fit_transform(df[['dist', 'angle', 'angle_diff']].to_numpy())
    y = df['best'].to_numpy()

    # データセットをトレーニングセットとテストセットに分割
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    # SVMモデルの作成と学習
    if model == 'linear':
        svm_model = LinearSVC(C=1)  # カーネルは線形カーネルを使用
    elif model == 'poly':
        svm_model = SVC(kernel='poly', degree=3, coef0=1, C=5)
    elif model == 'rbf':
        svm_model = SVC(kernel='rbf', gamma=8, C=2**16, random_state=0)
    elif model == 'sigmoid':
        svm_model = SVC(kernel='sigmoid')

    svm_model.fit(X_train, y_train)

    # テストデータでの予測
    y_pred = svm_model.predict(X_test)

    # 精度の評価
    accuracy = accuracy_score(y_test, y_pred)
    # print(f"Accuracy: {accuracy}")

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

    # with open(os.path.join(ml_models_dir, model_name+'_model.pkl'), 'wb') as f:
    #     pickle.dump(svm_model, f)
    # with open(os.path.join(ml_models_dir, model_name+'_stats.csv'), 'w') as f:
    #     writer = csv.writer(f)
    #     writer.writerow(ss.scale_)
    #     writer.writerow(ss.mean_)

    [dist, angle, angle_diff] = [12, 90, 0]
    data = np.array([dist, angle, angle_diff]).reshape(1, -1)
    prediction1 = svm_model.predict(data)

    [dist, angle, angle_diff] = [19, 111, 0.24]
    data = np.array([dist, angle, angle_diff]).reshape(1, -1)
    prediction2 = svm_model.predict(data)

    return prediction1, prediction2, accuracy

C_list = [1, 5, 10, 50, 100, 2**10, 2**15]

# for C in C_list:
#     pre1, pre2, accuracy = svm_exp('linear', C=C)
#     content = 'model: linear, C: {}, pre1: {}, pre2: {}, acc: {}'.format(C, pre1, pre2, accuracy)
#     with open('log2.txt', 'a') as file:
#         file.write(content+'\n')

# for C in C_list:
#     for degree in [1,3,5,9]:
#         pre1, pre2, accuracy = svm_exp('poly', C=C, degree=degree)
#         content = 'model: poly, C: {}, degree: {},  pre1: {}, pre2: {}, acc: {}'.format(C, degree, pre1, pre2, accuracy)
#         with open('log2.txt', 'a') as file:
#             file.write(content+'\n')

for C in C_list:
    for gamma in range(1, 10):
        pre1, pre2, accuracy = svm_exp('rbf', C=C, gamma=gamma)
        content = 'model: rbf, C: {}, gamma: {},  pre1: {}, pre2: {}, acc: {}'.format(C, gamma, pre1, pre2, accuracy)
        with open('log2.txt', 'a') as file:
            file.write(content+'\n')

pre1, pre2, accuracy = svm_exp('sigmoid')
content = 'model: sigmoid, pre1: {}, pre2: {}, acc: {}'.format(pre1, pre2, accuracy)
with open('log2.txt', 'a') as file:
    file.write(content+'\n')