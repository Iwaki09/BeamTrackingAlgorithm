# BeamTrackingAlgorithm
## フォルダの説明
- /beamtracking : 将来的にPythonに翻訳したものがここに入る予定
- /dataset : 機械学習のモデルに突っ込む用のcsvファイルたち。
- /datasource : 大元のsumoファイルたち。簡単な実験に使ったり、複製のオリジナルとして使ったり。
- /ml_models : ml関係のモデルファイルや標準化に使った情報を書いてあるファイル
- /ml_result : mlの結果を置く。
- /mscript : matlabファイル
- /result : 自動化シミュレーションの結果置き場。この後/datasetに行く
- /sumo_xml : 大量に複製されたsumoスクリプト
- /tool : いろいろやるpythonファイル
- /tool2 : angle_diffを加えたもの。toolとの統合が面倒だったので分けた。

## mscript/beamtracking_4way_2dim
機械学習用に整形済

input: outputファイル名
output: 位置(x), 位置(y), 基地局からの距離, 速度, 加速度x, 加速度y, 向き, SNRのリスト