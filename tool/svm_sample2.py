# 必要なライブラリのインポート
from sklearn import datasets
from sklearn.model_selection import train_test_split
from sklearn.svm import SVC
from sklearn.metrics import accuracy_score

import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import numpy as np

# Irisデータセットの読み込み
iris = datasets.load_iris()
X = iris.data[:100, :]  # 特徴量
y = iris.target[:100]  # ターゲット（クラス）

# データセットをトレーニングセットとテストセットに分割
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# SVMモデルの作成と学習
svm_model = SVC(kernel='linear')  # カーネルは線形カーネルを使用
svm_model.fit(X_train, y_train)

# テストデータでの予測
y_pred = svm_model.predict(X_test)

# 精度の評価
accuracy = accuracy_score(y_test, y_pred)
print(f"Accuracy: {accuracy}")

# 3Dプロットの作成
fig = plt.figure(figsize=(10, 8))
ax = fig.add_subplot(111, projection='3d')

# print(type(X_train))
# print(X_train)
# トレーニングデータのプロット
for i in np.unique(y_train):
    indices = np.where(y_train == i)
    ax.scatter(X_train[indices, 0], X_train[indices, 1], X_train[indices, 2], label=f'Class {i}')

# 分離超平面のプロット
# 3次元データの場合、超平面は2次元平面として可視化できる
xx, yy = np.meshgrid(np.linspace(X[:, 0].min(), X[:, 0].max(), 100),
                     np.linspace(X[:, 1].min(), X[:, 1].max(), 100))
zz = (-svm_model.intercept_[0] - svm_model.coef_[0, 0] * xx - svm_model.coef_[0, 1] * yy) / svm_model.coef_[0, 2]
ax.plot_surface(xx, yy, zz, alpha=0.3, color='gray')

# サポートベクトルのプロット
ax.scatter(svm_model.support_vectors_[:, 0], svm_model.support_vectors_[:, 1], svm_model.support_vectors_[:, 2],
           facecolors='none', edgecolors='r', s=100, label='Support Vectors')

# プロットの設定
ax.set_xlabel('Sepal Length (cm)')
ax.set_ylabel('Sepal Width (cm)')
ax.set_zlabel('Petal Length (cm)')
ax.set_title('SVM 3D Plot')

# 凡例の表示
ax.legend()

# グラフの表示
plt.show()