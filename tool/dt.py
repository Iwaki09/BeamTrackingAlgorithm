# 必要なライブラリのインポート
from sklearn import datasets
from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import accuracy_score
from sklearn.preprocessing import StandardScaler

import csv
import os
import pandas as pd
import pickle
import sys

dataset_dir = './dataset/all'
ml_models_dir = './model'
model_name = sys.argv[0]

file_list = [file for file in os.listdir(dataset_dir) if file.startswith("all_dataset_")]

# 全てのCSVファイルを読み込んでDataFrameに結合
df = pd.concat([pd.read_csv(os.path.join(dataset_dir, file)) for file in file_list], ignore_index=True)
print(df.shape)

# 間引く
interval = 4
df = df.iloc[::interval]

'''
位置(x), 位置(y), 基地局からの距離, 速度, 加速度x, 加速度y, 向き, SNRが良いほう(2dimなら0, 4wayなら1), accel絶対値
'''

ss = StandardScaler()
X = ss.fit_transform(df[['dist', 'speed', 'angle']].to_numpy())
y = df['best'].to_numpy()

# データセットをトレーニングセットとテストセットに分割
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# 決定木モデルの作成と学習
decision_tree_model = DecisionTreeClassifier(criterion='gini', 
                                             max_depth=None, 
                                             min_samples_split=2, 
                                             min_samples_leaf=1, 
                                             max_features=None)
decision_tree_model.fit(X_train, y_train)

# テストデータでの予測
y_pred = decision_tree_model.predict(X_test)

# 精度の評価
accuracy = accuracy_score(y_test, y_pred)
print(f"Accuracy: {accuracy}")

# モデルの保存
with open(os.path.join(ml_models_dir, model_name+'_model.pkl'), 'wb') as f:
    pickle.dump(decision_tree_model, f)
with open(os.path.join(ml_models_dir, model_name+'_stats.csv'), 'w') as f:
    writer = csv.writer(f)
    writer.writerow(ss.scale_)
    writer.writerow(ss.mean_)
