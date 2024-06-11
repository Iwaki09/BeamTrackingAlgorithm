import pandas as pd
import matplotlib.pyplot as plt
import matplotlib
import os
import click

matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42


@click.command()
@click.argument('scenario')
@click.argument('plotlist', nargs=-1)
@click.option('--linewidth', '--lw', type=int, default=2)
@click.option('--ver', '--v')
@click.option('--scoreprint', '--s', is_flag=True)
def plot_main(scenario, plotlist, linewidth, ver, scoreprint):
    input_dir1 = './datasource'
    input_dir2 = './result'
    output_dir = './result'
    if ver:
        output_filename = os.path.join(output_dir, scenario+'_SNR_ver'+ver+'.pdf')
    else:
        output_filename = os.path.join(output_dir, scenario+'_SNR.pdf')
    #              0            1            2            3           4             5        6             7           8          9
    # scenarios = ['direct', 'curve_r150', 'curve_r60', 'curve_r40', 'curve_r30', 'okutama', 'shinobazu', 'korakuen', 'yomiuri', 'paris', 
    #              'paris2', 'charles']
    # tags = ['']

    # scenario = scenarios[11]

    # 1: NoMLで単体 2: NoMLで全部(未完成) 11: MLをplot
    plotlist = list(plotlist)
    # print(plotlist)

    # if (plotmode == 'normal') or (plotmode == 'n'):
    #     plot_individual_normal(input_dir1, scenario, output_dir, linewidth)
    # elif (plotmode == 'ml'):
    #     plotlist = ['']
    #     plot_individual_ml(input_dir1, input_dir2, scenario, output_dir, linewidth, ver)
    plot_individual(input_dir1, input_dir2, output_filename, scenario, plotlist, linewidth, scoreprint)


def plot_individual_normal(input_dir, scenario, output_dir, linewidth):
    scenario_path = os.path.join(input_dir, scenario)
    df_2way = pd.read_csv(scenario_path+'_2way.csv', names=['x', 'SNR_2way', 'SNR_o', 'SNR_s'])
    df_2dim = pd.read_csv(scenario_path+'_2dim.csv', names=['x', 'SNR_2dim', 'SNR_o', 'SNR_s'])
    df_4way = pd.read_csv(scenario_path+'_4way.csv', names=['x', 'SNR_4way', 'SNR_o', 'SNR_s'])

    dfs = [df_2way, df_2dim, df_4way]

    min_df_x = dfs[0]['x']
    for df in dfs:
        if len(df['x']) < len(min_df_x):
            min_df_x = df['x']

    # if (min_df_x.equals(dfs[0]['x'])):
    #     df_non = pd.read_csv(scenario_path+'_2way2.csv', names=['x', 'SNR_non'])
    # elif (min_df_x.equals(dfs[1]['x'])):
    #     df_non = pd.read_csv(scenario_path+'_2dim2.csv', names=['x', 'SNR_non'])
    # else:
    #     df_non = pd.read_csv(scenario_path+'_4way2.csv', names=['x', 'SNR_non'])

    # df_2way = df_2way.iloc[:len(min_df_x)]
    # df_2dim = df_2dim.iloc[:len(min_df_x)]
    # df_4way = df_4way.iloc[:len(min_df_x)]

    # df_all = pd.DataFrame({
    #     'x': df_2way['x'],
    #     'SNR_opt': df_2way['SNR_o'],
    #     'SNR_con': df_2way['SNR_2way'],
    #     'SNR_swe': df_2way['SNR_s'],
    #     'SNR_2dim': df_2dim['SNR_2dim'],
    #     'SNR_4way': df_4way['SNR_4way'],
    # })

    # print(df_2dim)
    plt.plot(df_2way['x'], df_2way['SNR_o'], label='Optimal', color = '#005AFF', linewidth=linewidth)
    plt.plot(df_2way['x'], df_2way['SNR_2way'], label='Conventional', color = '#03AF7A', linewidth=linewidth)
    plt.plot(df_2way['x'], df_2way['SNR_s'], label='Sweeping', color = '#4DC4FF', linewidth=linewidth)
    plt.plot(df_4way['x'], df_4way['SNR_4way'], label='4way(Proposal I)', color = '#FF4B00', linewidth=linewidth)
    plt.plot(df_2dim['x'], df_2dim['SNR_2dim'], label='2dim(Proposal II)', color = '#F6AA00', linewidth=linewidth)
    # plt.plot(df_non['x'], df_non['SNR_non'], color = 'black', linewidth=linewidth)
    plt.xlabel('position[m]')
    plt.ylabel('SNR[dB]')
    plt.xlim(5, 60.1)

    plt.xticks([5,10,20,30,40,50,60]) 
    plt.ylim(0, 60)
    plt.grid(alpha=0.3)
    plt.legend(loc='upper right')
    plt.savefig(os.path.join(output_dir, scenario+'_SNR_all.pdf'))

    # df_all.to_csv(output_dir+scenario_now+'_all.csv')
    # df_non.to_csv(output_dir+scenario_now+'_all2.csv')

    plt.show()

    plt.clf()


def plot_individual(input_dir1, input_dir2, output_filename, scenario, plotlist, linewidth, scoreprint):
    scenario_path1 = os.path.join(input_dir1, scenario)
    scenario_path2 = os.path.join(input_dir2, scenario)

    dfs = []

    if scoreprint:
        df_2dim = pd.read_csv(scenario_path1+'_2dim.csv', names=['x', 'SNR_2dim', 'SNR_o', 'SNR_s'])
        df_4way = pd.read_csv(scenario_path1+'_4way.csv', names=['x', 'SNR_4way', 'SNR_o', 'SNR_s'])
        df_2dim['SNR_4way'] = df_4way['SNR_4way']
        df_2dim['SNR_4way'].fillna(0, inplace=True)
        df_2dim['best'] = df_2dim.apply(lambda row: 22 if row['SNR_2dim'] > row['SNR_4way'] else 4, axis=1)

    plotlist_extend = []
    plotlist_remove = []
    for elem in plotlist:
        if elem in ['2way', 'opt', 'swe']:
            df= pd.read_csv(scenario_path1+'_2way.csv', names=['x', 'SNR_t', 'SNR_o', 'SNR_s'])
            dfs.append(df)
        if elem == '2dim':
            df = pd.read_csv(scenario_path1+'_2dim.csv', names=['x', 'SNR_t', 'SNR_o', 'SNR_s'])
            dfs.append(df)
        if elem == '4way':
            df = pd.read_csv(scenario_path1+'_4way.csv', names=['x', 'SNR_t', 'SNR_o', 'SNR_s'])
            dfs.append(df)      
        if '-' in elem:
            modelname_specific, type, ver = elem.split('-')
            modelname, specific = modelname_specific.split('_')
            plotlist_extend.append(modelname)
            df = pd.read_csv(scenario_path2+'-ml-'+modelname_specific+'-type'+type+'-ver'+ver+'.csv', names=['x', 'SNR_t', 'SNR_o', 'SNR_s', 'search_way'])
            dfs.append(df)
            plotlist_remove.append(elem)

            if scoreprint:
                correct = (df_2dim['best'] == df['search_way']).sum()
                score = correct / len(df)
                print("{}'s score: {}".format(modelname, score))

    plotlist.extend(plotlist_extend)
    for remove in plotlist_remove:
        if remove in plotlist:
            plotlist.remove(remove)
    # print(plotlist)

    # df_4way = pd.read_csv(scenario_path1+'_4way.csv', names=['x', 'SNR_4way', 'SNR_o', 'SNR_s'])
    # df_ml = pd.read_csv(scenario_path2+'_ml_ver'+ver+'.csv', names=['x', 'SNR_ml', 'SNR_o', 'SNR_s', 'search_way'])

    # dfs = [df_2way, df_2dim, df_4way, df_ml]

    '''黒部分
    min_df_x = dfs[0]['x']
    for df in dfs:
        if len(df['x']) < len(min_df_x):
            min_df_x = df['x']

    print(min_df_x.shape)
    for i, df in enumerate(dfs):
        if min_df_x.equals(df['x']):
            df_non = pd.read_csv(scenario_path1+'_'+plotlist[i]+'2.csv', names=['x', 'SNR_non'])

        df = df.iloc[:len(min_df_x)]
        print(df.shape)
    '''

    # if (min_df_x.equals(dfs[0]['x'])):
    #     df_non = pd.read_csv(scenario_path1+'_2way2.csv', names=['x', 'SNR_non'])
    # elif (min_df_x.equals(dfs[1]['x'])):
    #     df_non = pd.read_csv(scenario_path1+'_2dim2.csv', names=['x', 'SNR_non'])
    # elif (min_df_x.equals(dfs[2]['x'])):
    #     df_non = pd.read_csv(scenario_path1+'_4way2.csv', names=['x', 'SNR_non'])
    # else:
    #     df_non = pd.read_csv(scenario_path2+'_ml_ver'+ver+'2.csv', names=['x', 'SNR_non'])

    # df_2way = df_2way.iloc[:len(min_df_x)]
    # df_2dim = df_2dim.iloc[:len(min_df_x)]
    # df_4way = df_4way.iloc[:len(min_df_x)]
    # df_ml = df_ml.iloc[:len(min_df_x)]

    # df_all = pd.DataFrame({
    #     'x': df_2way['x'],
    #     'SNR_opt': df_2way['SNR_o'],
    #     'SNR_con': df_2way['SNR_2way'],
    #     'SNR_swe': df_2way['SNR_s'],
    #     'SNR_2dim': df_2dim['SNR_2dim'],
    #     'SNR_4way': df_4way['SNR_4way'],
    #     'SNR_ml': df_ml['SNR_ml'],
    # })

    plot_dict = {
        '2way': {
            'label': 'Conventional',
            'color': '#03AF7A',
        },
        '2dim': {
            'label': '2dim',
            'color': '#F6AA00'
        },
        '4way': {
            'label': '4way',
            'color': '#FF4B00'
        },
        'opt': {
            'label': 'Optimal',
            'color': '#005AFF'
        },
        'swe': {
            'label': 'Sweeping',
            'color': '#4DC4FF',
        },
        'dt': {
            'label': 'DT',
            'color': '#f781bf',
        },
        'svm': {
            'label': 'SVM',
            'color': 'purple',
        },
        'xgb': {
            'label': 'XGB',
            'color': '#a65628',
        },
    }

    for i, df in enumerate(dfs):
        if plotlist[i] == 'opt':
            plt.plot(df['x'], df['SNR_o'], label=plot_dict[plotlist[i]]['label'], color=plot_dict[plotlist[i]]['color'], linewidth=linewidth)
        elif plotlist[i] == 'swe':
            plt.plot(df['x'], df['SNR_s'], label=plot_dict[plotlist[i]]['label'], color=plot_dict[plotlist[i]]['color'], linewidth=linewidth)
        elif i == 3:
            plt.plot(df['x'], df['SNR_t'], label='generic', color='#f781bf', linewidth=linewidth)
        elif i == 4:
            plt.plot(df['x'], df['SNR_t'], label='specific-TD', color='purple', linewidth=linewidth)
        elif i == 5:
            plt.plot(df['x'], df['SNR_t'], label='specific-CH', color='#a65628', linewidth=linewidth)
        else:
            plt.plot(df['x'], df['SNR_t'], label=plot_dict[plotlist[i]]['label'], color=plot_dict[plotlist[i]]['color'], linewidth=linewidth, linestyle="dashed")

    # plt.plot(df_2way['x'], df_2way['SNR_o'], label='Optimal', color = '#005AFF', linewidth=linewidth)
    # plt.plot(df_2way['x'], df_2way['SNR_2way'], label='Conventional', color = '#03AF7A', linewidth=linewidth)
    # plt.plot(df_2way['x'], df_2way['SNR_s'], label='Sweeping', color = '#4DC4FF', linewidth=linewidth)
    # plt.plot(df_4way['x'], df_4way['SNR_4way'], label='4way', color = '#FF4B00', linewidth=linewidth)
    # plt.plot(df_2dim['x'], df_2dim['SNR_2dim'], label='2dim', color = '#F6AA00', linewidth=linewidth)
    # plt.plot(df_ml['x'], df_ml['SNR_ml'], label='ML', color = 'purple', linewidth=linewidth, linestyle='dashed')
    # plt.plot(df_non['x'], df_non['SNR_non'], color = 'black', linewidth=linewidth)
    plt.xlabel('position[m]')
    plt.ylabel('SNR[dB]')
    plt.xlim(5, 60.1)

    plt.xticks([5,10,20,30,40,50,60]) 
    plt.ylim(20, 50)
    plt.grid(alpha=0.3)
    plt.legend(loc='upper right')
    plt.savefig(output_filename)

    # df_all.to_csv(output_dir+scenario_now+'_all.csv')
    # df_non.to_csv(output_dir+scenario_now+'_all2.csv')

    plt.show()

    plt.clf()

if __name__ == '__main__':
    plot_main()

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