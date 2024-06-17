# BeamTrackingAlgorithm
## フォルダの説明
- /beamtracking_python : 将来的にPythonに翻訳したものがここに入る予定
- /dataset : 機械学習のモデルに突っ込む用のcsvファイルたち。
- /datasource : グラフのプロットなどに使う元データ
- /model : ml関係のモデルファイルや標準化に使った情報を書いてあるファイル
- /result : mlの結果やプロットファイル
- /mscript : matlabファイル
- /sumo : 大量に複製されたsumoスクリプト
- /tool : データ処理系のpythonファイル


## mscript/beamtracking_4way_2dim
機械学習用に整形済

input: outputファイル名
output: 位置(x), 位置(y), 基地局からの距離, 速度, 加速度x, 加速度y, 向き, SNRのリスト