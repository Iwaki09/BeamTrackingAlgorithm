import pandas as pd
import matplotlib.pyplot as plt

scenario = ['direct', 'r150', 'r60', 'r40', 'r30']

scenario_now = scenario[3]

if scenario_now == scenario[0]:
    road = 'direct'
else:
    road = 'curve'

output_dir = './res/'

linewidth = 2

# CSVファイルの読み込み
df_2way = pd.read_csv('./source/'+scenario_now+'_2way.csv', names=['x', 'SNR_2way', 'SNR_o', 'SNR_s'])
df_4way = pd.read_csv('./source/'+scenario_now+'_4way_ang2.csv', names=['x', 'SNR_4way', 'SNR_o'])
df_2dim = pd.read_csv('./source/'+scenario_now+'_2dim.csv', names=['x', 'SNR_2dim', 'SNR_o'])

df_4way['SNR_4way'] *= -1
df_2dim['SNR_2dim'] *= -1

plt.plot(df_2way['x'], df_2way['SNR_o'], label='Optimal', color = 'black', linewidth=linewidth)
plt.plot(df_2way['x'], df_2way['SNR_s'], label='Sweeping', color = 'orange', linewidth=linewidth)
plt.plot(df_2way['x'], df_2way['SNR_2way'], label='Conventional', color = 'blue', linewidth=linewidth)
plt.plot(df_4way['x'], df_4way['SNR_4way'], label='Proposed I', color = 'green', linewidth=linewidth)
plt.plot(df_2dim['x'], df_2dim['SNR_2dim'], label='Proposed II', color = 'red', linewidth=linewidth)
plt.xlabel('position[m]')
plt.ylabel('SNR[dB]')
plt.xlim(0, 60.1)

plt.xticks(range(0, 70, 10)) 
plt.ylim(0, 60)
plt.grid(alpha=0.3)
plt.legend(loc='upper right')
plt.savefig(output_dir+road+'_'+scenario_now+'_all.pdf')

plt.show()