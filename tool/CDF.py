import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
import numpy as np
import os

input_dir1 = './datasource'
input_dir2 = './result'
output_dir = './result'
#              0            1            2            3           4             5        6             7           8          9
scenarios = ['direct', 'curve_r150', 'curve_r60', 'curve_r40', 'curve_r30', 'okutama', 'shinobazu', 'korakuen', 'yomiuri', 'paris', 
                'paris2', 'charles']

scenario = 'charles'
# scenario = 'korakuen'

linewidth = 4

scenario_path1 = os.path.join(input_dir1, scenario)
scenario_path2 = os.path.join(input_dir2, scenario)


df_2way = pd.read_csv(scenario_path1+'_2way.csv', names=['x', 'SNR_2way', 'SNR_o', 'SNR_s'])
df_2dim = pd.read_csv(scenario_path1+'_2dim.csv', names=['x', 'SNR_2dim', 'SNR_o', 'SNR_s'])
df_4way = pd.read_csv(scenario_path1+'_4way.csv', names=['x', 'SNR_4way', 'SNR_o', 'SNR_s'])
# df_ml1 = pd.read_csv(scenario_path2+'-ml-svm_generic-type2-ver1.csv', names=['x', 'SNR_ml', 'SNR_o', 'SNR_s', 'search_way'])
# df_ml2 = pd.read_csv(scenario_path2+'-ml-xgb_korakuen-type2-ver1.csv', names=['x', 'SNR_ml', 'SNR_o', 'SNR_s', 'search_way'])
# df_ml3 = pd.read_csv(scenario_path2+'-ml-xgb_charles-type1-ver1.csv', names=['x', 'SNR_ml', 'SNR_o', 'SNR_s', 'search_way'])
df_ml1 = pd.read_csv(scenario_path2+'-ml-svm_generic-type1-ver1.csv', names=['x', 'SNR_ml', 'SNR_o', 'SNR_s', 'search_way'])
df_ml2 = pd.read_csv(scenario_path2+'-ml-xgb_charles-type2-ver1.csv', names=['x', 'SNR_ml', 'SNR_o', 'SNR_s', 'search_way'])
df_ml3 = pd.read_csv(scenario_path2+'-ml-xgb_korakuen-type1-ver1.csv', names=['x', 'SNR_ml', 'SNR_o', 'SNR_s', 'search_way'])

dict_opt = {
    'x': df_2way['x'],
    'SNR_o': df_2way['SNR_o'],
}
df_opt = pd.DataFrame(data=dict_opt)

dict_con = {
    'x': df_2way['x'],
    'SNR_2way': df_2way['SNR_2way'],
}
df_con = pd.DataFrame(data=dict_con)

dict_swe = {
    'x': df_2way['x'],
    'SNR_s': df_2way['SNR_s'],
}
df_swe = pd.DataFrame(data=dict_swe)

dict_4way = {
    'x': df_4way['x'],
    'SNR_4way': df_4way['SNR_4way'],
}
df_4way= pd.DataFrame(data=dict_4way)

dict_2dim = {
    'x': df_2dim['x'],
    'SNR_2dim': df_2dim['SNR_2dim'],
}
df_2dim= pd.DataFrame(data=dict_2dim)

dict_ml1 = {
    'x': df_ml1['x'],
    'SNR_ml': df_ml1['SNR_ml'],
}
df_ml1= pd.DataFrame(data=dict_ml1)

dict_ml2 = {
    'x': df_ml2['x'],
    'SNR_ml': df_ml2['SNR_ml'],
}
df_ml2= pd.DataFrame(data=dict_ml2)

dict_ml3 = {
    'x': df_ml3['x'],
    'SNR_ml': df_ml3['SNR_ml'],
}
df_ml3= pd.DataFrame(data=dict_ml3)


df_opt.sort_values('SNR_o', inplace=True)
df_opt['cdf'] = df_opt['SNR_o'].rank() / len(df_opt['SNR_o'])

df_con.sort_values('SNR_2way', inplace=True)
df_con['cdf'] = df_con['SNR_2way'].rank() / len(df_con['SNR_2way'])

df_swe.sort_values('SNR_s', inplace=True)
df_swe['cdf'] = df_swe['SNR_s'].rank() / len(df_swe['SNR_s'])

df_4way.sort_values('SNR_4way', inplace=True)
df_4way['cdf'] = df_4way['SNR_4way'].rank() / len(df_4way['SNR_4way'])

df_2dim.sort_values('SNR_2dim', inplace=True)
df_2dim['cdf'] = df_2dim['SNR_2dim'].rank() / len(df_2dim['SNR_2dim'])

df_ml1.sort_values('SNR_ml', inplace=True)
df_ml1['cdf'] = df_ml1['SNR_ml'].rank() / len(df_ml1['SNR_ml'])

df_ml2.sort_values('SNR_ml', inplace=True)
df_ml2['cdf'] = df_ml2['SNR_ml'].rank() / len(df_ml2['SNR_ml'])

df_ml3.sort_values('SNR_ml', inplace=True)
df_ml3['cdf'] = df_ml3['SNR_ml'].rank() / len(df_ml3['SNR_ml'])

scatter_list = np.arange(30, 50.1, 2.5).tolist()

nearest_values_ml2 = [df_ml2['cdf'].iloc[(df_ml2['SNR_ml'] - val).abs().argsort()[:1]].values[0] for val in scatter_list]
nearest_values_ml1 = [df_ml1['cdf'].iloc[(df_ml1['SNR_ml'] - val).abs().argsort()[:1]].values[0] for val in scatter_list]
nearest_values_ml3 = [df_ml3['cdf'].iloc[(df_ml3['SNR_ml'] - val).abs().argsort()[:1]].values[0] for val in scatter_list]

plt.figure(figsize=(7, 8)) 

plt.plot(df_opt['SNR_o'], df_opt['cdf'], label='Optimal', color = '#005AFF', linewidth=linewidth)
# plt.plot(df_con['SNR_2way'], df_con['cdf'], label='Conventional', color = '#03AF7A', linewidth=linewidth, linestyle="dashed")
# plt.plot(df_swe['SNR_s'], df_swe['cdf'], label='Sweeping', color = '#4DC4FF', linewidth=linewidth, linestyle="dashed")
plt.plot(df_4way['SNR_4way'], df_4way['cdf'], label='4way', color = '#FF4B00', linewidth=linewidth, linestyle="dashed")
plt.plot(df_2dim['SNR_2dim'], df_4way['cdf'], label='2dim', color = '#F6AA00', linewidth=linewidth, linestyle="dashed")
plt.plot(df_ml1['SNR_ml'], df_ml1['cdf'], label='generic', color='#f781bf', linewidth=linewidth, linestyle="dashed")
plt.plot(df_ml2['SNR_ml'], df_ml2['cdf'], label='specific-TD', color = 'purple', linewidth=linewidth, linestyle="dashed")
plt.plot(df_ml3['SNR_ml'], df_ml3['cdf'], label='specific-CH', color='#a65628', linewidth=linewidth, linestyle="dashed")
plt.scatter(scatter_list, nearest_values_ml2, color='purple', marker='^', edgecolor='purple', facecolor='white', linewidths=linewidth, zorder=4, s=100)
plt.scatter(scatter_list, nearest_values_ml1, color='#f781bf', marker='o', edgecolor='#f781bf', facecolor='white', linewidths=linewidth, zorder=3, s=100)
plt.scatter(scatter_list, nearest_values_ml3, color='#a65628', marker='s', edgecolor='#a65628', facecolor='white', linewidths=linewidth, zorder=3, s=100)

plt.ylabel('CDF', fontsize=18)
plt.xlabel('SNR[dB]', fontsize=18)
# plt.xlim(25, 50)

plt.xticks(range(0, 70, 10)) 
plt.xticks(range(0, 70, 1)) 
# plt.xlim(xmin=plt.xlim()[0], xmax=47)
plt.xlim(xmin=35, xmax=41)
# plt.xlim(xmin=25, xmax=46)
plt.ylim(0, 1)
plt.ylim(0.2, 0.6)
plt.grid(alpha=0.3)

plt.xticks(fontsize=18)
plt.yticks(fontsize=18)
# plt.legend(loc='upper left', fontsize='xx-large')
plt.savefig(output_dir+'/'+scenario+'_CDF.pdf')
plt.show()

# print(df_pro)