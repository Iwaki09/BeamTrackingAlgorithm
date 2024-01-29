import pandas as pd
import matplotlib.pyplot as plt

import os

def plot_main():
    input_dir1 = './datasource'
    input_dir2 = './ml_result'
    output_dir = './ml_result'

    scenarios = ['direct', 'curve_r150', 'curve_r60', 'curve_r40', 'curve_r30']
    tags = ['']

    scenario = scenarios[2]

    # 1: NoMLで単体 2: NoMLで全部(未完成) 11: MLをplot
    plot_mode = 1

    if plot_mode == 1:
        plot_individual_normal(os.path.join(input_dir1, scenario))


def plot_individual_normal(scenario):
    df_2way = pd.read_csv(scenario+'_2way.csv', names=['x', 'SNR_2way', 'SNR_o', 'SNR_s'])
    df_2dim = pd.read_csv(scenario+'_2dim.csv', names=['x', 'SNR_2dim', 'SNR_o', 'SNR_s'])
    df_4way = pd.read_csv(scenario+'_4way.csv', names=['x', 'SNR_4way', 'SNR_o', 'SNR_s'])

    dfs = [df_2way, df_2dim, df_4way]

    min_df_x = dfs[0]['x']
    for df in dfs:
        if len(df['x']) < len(min_df_x):
            min_df_x = df['x']

    if (min_df_x.equals(dfs[0]['x'])):
        df_non = pd.read_csv(scenario_now+'_2way2.csv', names=['x', 'SNR_non'])
    elif (min_df_x.equals(dfs[1]['x'])):
        df_non = pd.read_csv(scenario_now+'_2dim2.csv', names=['x', 'SNR_non'])
    else:
        df_non = pd.read_csv(scenario_now+'_4way2.csv', names=['x', 'SNR_non'])

    df_2way = df_2way.iloc[:len(min_df_x)]
    df_2dim = df_2dim.iloc[:len(min_df_x)]
    df_4way = df_4way.iloc[:len(min_df_x)]

    df_all = pd.DataFrame({
        'x': df_2way['x'],
        'SNR_opt': df_2way['SNR_o'],
        'SNR_con': df_2way['SNR_2way'],
        'SNR_swe': df_2way['SNR_s'],
        'SNR_2dim': df_2dim['SNR_2dim'],
        'SNR_4way': df_4way['SNR_4way'],
    })

    # print(df_2dim)
    plt.plot(df_2way['x'], df_2way['SNR_o'], label='Optimal', color = 'blue', linewidth=linewidth)
    plt.plot(df_2way['x'], df_2way['SNR_2way'], label='Conventional', color = 'orange', linewidth=linewidth)
    plt.plot(df_2way['x'], df_2way['SNR_s'], label='Sweeping', color = 'green', linewidth=linewidth)
    plt.plot(df_2dim['x'], df_2dim['SNR_2dim'], label='2dim', color = 'red', linewidth=linewidth)
    plt.plot(df_4way['x'], df_4way['SNR_4way'], label='4way', color = 'pink', linewidth=linewidth)
    plt.plot(df_non['x'], df_non['SNR_non'], color = 'black', linewidth=linewidth)
    plt.xlabel('position[m]')
    plt.ylabel('SNR[dB]')
    plt.xlim(5, 60.1)

    plt.xticks([5,10,20,30,40,50,60]) 
    plt.ylim(0, 60)
    plt.grid(alpha=0.3)
    plt.legend(loc='upper right')
    # plt.savefig(output_dir+scenario_now+'_SNR_all.pdf')

    # df_all.to_csv(output_dir+scenario_now+'_all.csv')
    # df_non.to_csv(output_dir+scenario_now+'_all2.csv')

    plt.show()

    plt.clf()

# for road in ['direct', 'curve_r150', 'curve_r60', 'curve_r40', 'curve_r30']:
#     for speed in ['30to45', '45to60', '60to75', '75to90']:

#         if road != 'curve_r30':
#             continue
#         if speed != '75to90':
#             continue

#         scenario_now = road+'_'+speed

#         output_dir = './'

#         linewidth = 2

#         # CSVファイルの読み込み
#         df_2way = pd.read_csv(scenario_now+'_2way.csv', names=['x', 'SNR_2way', 'SNR_o', 'SNR_s'])
#         df_2dim = pd.read_csv(scenario_now+'_2dim.csv', names=['x', 'SNR_2dim', 'SNR_o', 'SNR_s'])
#         df_4way = pd.read_csv(scenario_now+'_4way.csv', names=['x', 'SNR_4way', 'SNR_o', 'SNR_s'])
#         df_oran = pd.read_csv(scenario_now+'_oran.csv', names=['x', 'SNR_oran', 'SNR_o', 'SNR_s'])

#         dfs = [df_2way, df_2dim, df_4way, df_oran]

#         min_df_x = dfs[0]['x']
#         for df in dfs:
#             if len(df['x']) < len(min_df_x):
#                 min_df_x = df['x']

#         if (min_df_x.equals(dfs[0]['x'])):
#             df_non = pd.read_csv(scenario_now+'_2way2.csv', names=['x', 'SNR_non'])
#         elif (min_df_x.equals(dfs[1]['x'])):
#             df_non = pd.read_csv(scenario_now+'_2dim2.csv', names=['x', 'SNR_non'])
#         elif (min_df_x.equals(dfs[2]['x'])):
#             df_non = pd.read_csv(scenario_now+'_4way2.csv', names=['x', 'SNR_non'])
#         else:
#             df_non = pd.read_csv(scenario_now+'_oran2.csv', names=['x', 'SNR_non'])

#         df_2way = df_2way.iloc[:len(min_df_x)]
#         df_2dim = df_2dim.iloc[:len(min_df_x)]
#         df_4way = df_4way.iloc[:len(min_df_x)]
#         df_oran = df_oran.iloc[:len(min_df_x)]

#         df_all = pd.DataFrame({
#             'x': df_2way['x'],
#             'SNR_opt': df_2way['SNR_o'],
#             'SNR_con': df_2way['SNR_2way'],
#             'SNR_swe': df_2way['SNR_s'],
#             'SNR_2dim': df_2dim['SNR_2dim'],
#             'SNR_4way': df_4way['SNR_4way'],
#             'SNR_oran': df_oran['SNR_oran'],
#         })


#         # print(df_2dim)
#         plt.plot(df_2way['x'], df_2way['SNR_o'], label='Optimal', color = 'blue', linewidth=linewidth)
#         plt.plot(df_2way['x'], df_2way['SNR_2way'], label='Conventional', color = 'orange', linewidth=linewidth)
#         plt.plot(df_2way['x'], df_2way['SNR_s'], label='Sweeping', color = 'green', linewidth=linewidth)
#         plt.plot(df_2dim['x'], df_2dim['SNR_2dim'], label='2dim', color = 'red', linewidth=linewidth)
#         plt.plot(df_4way['x'], df_4way['SNR_4way'], label='4way', color = 'pink', linewidth=linewidth)
#         plt.plot(df_oran['x'], df_oran['SNR_oran'], label='ORAN', color = 'yellow', linewidth=linewidth)
#         plt.plot(df_non['x'], df_non['SNR_non'], color = 'black', linewidth=linewidth)
#         plt.xlabel('position[m]')
#         plt.ylabel('SNR[dB]')
#         plt.xlim(5, 60.1)

#         plt.xticks([5,10,20,30,40,50,60]) 
#         plt.ylim(0, 60)
#         plt.grid(alpha=0.3)
#         plt.legend(loc='upper right')
#         plt.savefig(output_dir+scenario_now+'_SNR_all.pdf')

#         df_all.to_csv(output_dir+scenario_now+'_all.csv')
#         df_non.to_csv(output_dir+scenario_now+'_all2.csv')

#         plt.show()

#         plt.clf()

if __name__ == '__main__':
    plot_main()