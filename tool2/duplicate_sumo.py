# 速度と加速度を変数としてsumoのxml(三種類)を複製
# とりあえずはcurve_r60道路

import os

import xml.etree.ElementTree as ET

# ファイルの読み込みとxmlツールの設定

datasource_dir = './datasource'
output_rootdir = './sumo_xml'

scenarios = ['direct', 'curve_r150', 'curve_r60', 'curve_r40', 'curve_r30']

for scenario in scenarios:

    output_dir = os.path.join(output_rootdir, scenario)
    os.mkdir(output_dir)

    net_xml_filename = os.path.join(datasource_dir, scenario+'.net.xml')
    rou_xml_filename = os.path.join(datasource_dir, scenario+'.rou.xml')
    sumocfg_filename = os.path.join(datasource_dir, scenario+'.sumocfg')

    tree_net = ET.parse(net_xml_filename)
    tree_rou = ET.parse(rou_xml_filename)
    tree_cfg = ET.parse(sumocfg_filename)

    root_net = tree_net.getroot()
    root_rou = tree_rou.getroot()
    root_cfg = tree_cfg.getroot()

    # sumoファイルの複製

    for max_speed in range(0, 20, 1):
        for accel in range(0, 10, 1):

            # 車道の最高速度の設定。
            root_net[1][0].attrib['speed'] = str(max_speed)

            # 車両の出発時間。
            depart_position = '0.00'
            root_rou[1].attrib['depart'] = depart_position

            # 車両の出発速度。とりあえず０
            depart_speed = '0.00'
            root_rou[1].attrib['departSpeed'] = depart_speed

            # 車両の加速度
            root_rou[0].attrib['accel'] = str(accel)

            # 車両の減速度(加速度と同じにする)
            root_rou[0].attrib['decel'] = str(accel)

            # 車両の全長
            root_rou[0].attrib['length'] = '5.0'

            # 車両の最高速度。大きめに取る
            root_rou[0].attrib['maxSpeed'] = '300.00'

            # sumocfgに書かれるファイル名
            filename_suffix = '_ms{}_ac{}_ds{}'.format(max_speed, accel, depart_speed)

            root_cfg[0][0].attrib['value'] = scenario+filename_suffix+'.net.xml'
            root_cfg[0][1].attrib['value'] = scenario+filename_suffix+'.rou.xml'

            # ファイル書き込み
            tree_net.write(os.path.join(output_dir, scenario+filename_suffix+'.net.xml'), encoding='UTF-8')
            tree_rou.write(os.path.join(output_dir, scenario+filename_suffix+'.rou.xml'), encoding='UTF-8')
            tree_cfg.write(os.path.join(output_dir, scenario+filename_suffix+'.sumocfg'), encoding='UTF-8')