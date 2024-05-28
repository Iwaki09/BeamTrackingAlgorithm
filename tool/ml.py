# 必要なライブラリのインポート
from sklearn import datasets
from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeClassifier
from sklearn.svm import SVC
from sklearn.metrics import accuracy_score
from sklearn.preprocessing import StandardScaler
from xgboost import XGBClassifier

import csv
import click
import os
import pandas as pd
import pickle


@click.command()
@click.argument('modelname')
@click.argument('specific', default='generic')
@click.option('--type', '--t', required=True)
@click.option('--ver', '--v', required=True)
@click.option('--interval', '--i', type=int, default=1)
def cli(modelname, specific, interval, type, ver):

    dataset_dir = './dataset/all'
    ml_models_dir = './model'

    if specific == 'generic':
        file_list = ['all_dataset_curve_r30.csv', 'all_dataset_curve_r40.csv', 'all_dataset_curve_r60.csv', 'all_dataset_curve_r150.csv', 'all_dataset_direct.csv']
    else:
        file_list = ['all_dataset_'+specific+'.csv']

    # 全てのCSVファイルを読み込んでDataFrameに結合
    df = pd.concat([pd.read_csv(os.path.join(dataset_dir, file)) for file in file_list], ignore_index=True)

    # 間引く
    df = df.iloc[::interval]

    '''
    位置(x), 位置(y), 基地局からの距離, 速度, 加速度x, 加速度y, 向き, SNRが良いほう(2dimなら0, 4wayなら1), accel絶対値
    '''

    ss = StandardScaler()
    if type == '1':
        X = ss.fit_transform(df[['dist', 'speed', 'angle', 'angle_diff']].to_numpy())
    elif type == '2':
        X = ss.fit_transform(df[['angle', 'angle_diff']].to_numpy())
    else:
        print('type is wrong')
        exit()
    y = df['best'].to_numpy()

    # データセットをトレーニングセットとテストセットに分割
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    if modelname == 'dt':
        model = DecisionTreeClassifier(criterion='gini', 
                                                    max_depth=None, 
                                                    min_samples_split=2, 
                                                    min_samples_leaf=1, 
                                                    max_features=None)
        model.fit(X_train, y_train)
        y_pred = model.predict(X_test)
        with open(os.path.join(ml_models_dir, modelname+'_'+specific+'-type'+type+'-ver'+ver+'_model.pkl'), 'wb') as f:
            pickle.dump(model, f)
    elif modelname == 'svm':
        if type == '1':
            model = SVC(kernel='rbf', gamma=7, C=2**15, random_state=0)
        elif type == '2':
            model = SVC(kernel='rbf', gamma=1, C=2**10, random_state=0)
        model.fit(X_train, y_train)
        y_pred = model.predict(X_test)
        with open(os.path.join(ml_models_dir, modelname+'_'+specific+'-type'+type+'-ver'+ver+'_model.pkl'), 'wb') as f:
            pickle.dump(model, f)
    elif modelname == 'xgb':
        model = XGBClassifier()
        model.fit(X_train, y_train)
        y_pred = model.predict(X_test)
        model.save_model(os.path.join(ml_models_dir, modelname+'_'+specific+'-type'+type+'-ver'+ver+'_model.json'))

    with open(os.path.join(ml_models_dir, modelname+'_'+specific+'-type'+type+'-ver'+ver+'_stats.csv'), 'w') as f:
        writer = csv.writer(f)
        writer.writerow(ss.scale_)
        writer.writerow(ss.mean_)

    # 精度の評価
    accuracy = accuracy_score(y_test, y_pred)
    print(f"Accuracy: {accuracy}")


if __name__ == '__main__':
    cli()

'''
import matplotlib.pyplot as plt

X = X * ss.scale_ + ss.mean_

# データの準備
data_class0 = X[y == 0]  # ラベルが0のデータ
data_class1 = X[y == 1]  # ラベルが1のデータ

# プロット
plt.figure(figsize=(10, 6))

# ラベルが0のデータをプロット
plt.scatter(data_class0[:, 0], data_class0[:, 1], c='blue', label='Label 0')

# ラベルが1のデータをプロット
plt.scatter(data_class1[:, 0], data_class1[:, 1], c='red', label='Label 1')

# 軸ラベルとタイトルの設定
plt.xlabel('Angle')
plt.ylabel('Angle Difference')
plt.title('Distribution of Labels based on Angle and Angle Difference')

# 凡例の表示
plt.legend()

# グリッドの表示
plt.grid(True)

# プロットの表示
# plt.show()
'''