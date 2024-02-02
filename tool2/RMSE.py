import pandas as pd
import math
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import PolynomialFeatures
import numpy as np

linewidth = 2

mode = 'acc'

accs = ['2', '2_6', '3', '5', '10', '15', '20']

speeds = ['40', '50', '60', '70', '80', '90', '100']

if mode == 'speed':
    list = speeds
elif mode == 'acc':
    list = accs

res = []

for i in range(len(list)):

    if mode == 'speed':
        filename = 'r40_'+list[i]+'km.csv'
    elif mode == 'acc':
        filename = 'r40_50km_acc'+list[i]+'.csv'

# CSVファイルの読み込み
    df = pd.read_csv('./source/'+filename, names=['x', 'SNR_2dim', 'SNR_o', 'SNR_s'])

    df['diff'] = (df['SNR_2dim'] - df['SNR_o']) ** 2

    rmse = math.sqrt(df['diff'].sum()/len(df))

    res.append(rmse)

speeds_int = [40, 50, 60, 70, 80, 90, 100]  # 速度データ

# データをNumPy配列に変換
X = np.array(speeds_int).reshape(-1, 1)
y = np.array(res)

'''一時関数'''

# 線形回帰モデルの作成
model1 = LinearRegression()

# データをモデルに適合させる
model1.fit(X, y)

# 予測値の計算
predictions1 = model1.predict(X)

# 回帰直線の傾きと切片を取得
slope = model1.coef_[0]
intercept = model1.intercept_

# 結果の表示
print(f'回帰直線: y = {slope:.2f}x + {intercept:.2f}')

'''二次関数'''

# 二次関数の特徴量を追加
poly = PolynomialFeatures(degree=2)
X_poly = poly.fit_transform(X)

# 線形回帰モデルの作成
model = LinearRegression()

# データをモデルに適合させる
model.fit(X_poly, y)

# 予測値の計算
predictions = model.predict(X_poly)

print(f'二次関数の回帰式: y = {model.coef_[2]:.2f}x^2 + {model.coef_[1]:.2f}x + {model.intercept_:.2f}')

# グラフの描画
plt.scatter(X, y)
plt.plot(X, predictions1, color='blue')
plt.plot(X, predictions, color='red')
plt.xlabel('speed')
plt.ylabel('RMSE')
plt.grid('on')
plt.legend()
plt.show()


