import pandas as pd
import matplotlib.pyplot as plt

sumo_xml_dir = './sumo_xml'
input_dir = './result'
matlab_dir = './mscript'

scenarios = ['direct', 'curve_r150', 'curve_r60', 'curve_r40', 'curve_r30']

depart_speed = '0.00'

df_all = pd.DataFrame(columns=['x', 'speed', 'accel', 'angle', 'best'])
print(df_all)
for scenario in scenarios:
    if scenario != 'curve_r150':
        continue
    for max_speed in reversed(range(1, 20, 1)):
        for accel in reversed(range(1, 10, 1)):
            if max_speed < 2:
                continue
            if accel <= 0:
                continue
            filename_suffix = '_ms{}_ac{}_ds{}'.format(max_speed, accel, depart_speed)
            filename_2dim = scenario + filename_suffix + '_2dim.csv'
            filename_4way = scenario + filename_suffix + '_4way.csv'
            df_2dim = pd.read_csv(input_dir+'/'+filename_2dim, names=['x', 'speed', 'accel', 'angle', 'SNR_2dim'])
            df_4way = pd.read_csv(input_dir+'/'+filename_4way, names=['x', 'speed', 'accel', 'angle', 'SNR_4way'])

            df_2dim['SNR_4way'] = df_4way['SNR_4way']
            df_2dim['SNR_4way'].fillna(0, inplace=True)
            # 2dimなら0, 4wayなら1
            # なぜ下のコードはだめなの？
            # df_2dim['best'] = 0 if (df_2dim['SNR_2dim'] > df_2dim['SNR_4way']) else 1
            df_2dim['best'] = df_2dim.apply(lambda row: 0 if row['SNR_2dim'] > row['SNR_4way'] else 1, axis=1)
            # print(df_2dim)

            df_all = pd.concat([df_all, df_2dim[['x', 'speed', 'accel', 'angle', 'best']]])


# colors = df_all['best'].map({0: 'red', 1: 'blue'})
# plt.scatter(df_all['speed'], df_all['accel'], c=colors, label=df_all['best'].astype(str))

# # グラフにタイトルとラベルを追加
# plt.title('Scatter Plot of Speed vs Acceleration')
# plt.xlabel('Speed')
# plt.ylabel('Acceleration')
# plt.savefig('result.png')
            
plt.hist([df_all[df_all['best'] == 0]['x'], df_all[df_all['best'] == 1]['x']],
         bins=5, alpha=0.7, color=['red', 'blue'], label=['best=2dim', 'best=4way'])

# グラフにタイトルとラベルを追加
plt.title('Histogram of Distance by Best')
plt.xlabel('Distance from BS')
plt.ylabel('')

# 凡例を表示
plt.legend()

# グラフを表示
plt.savefig('result.png')
