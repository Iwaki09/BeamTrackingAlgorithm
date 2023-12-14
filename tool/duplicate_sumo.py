# 速度と加速度を変数としてsumoのxml(三種類)を複製
# とりあえずはcurve_r60道路

import os

import xml.etree.ElementTree as ET

# ファイルの読み込みとxmlツールの設定

datasource_dir = './datasource'
output_dir = './sumo_xml'

scenario = 'curve_r60'

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

for speed in range(0, 30, 2):
    for accel in [0]:

        # 車道の最高速度の設定。
        root_net[1][0].attrib['speed'] = str(speed)

        # 車両の出発速度。とりあえず０
        root_rou[0].attrib['departSpeed'] = '0.00'

        # 車両の加速度

        # sumocfgに書かれるファイル名
        filename_suffix = '_s{}_a{}'.format(speed, accel)

        root_cfg[0][0].attrib['value'] = scenario+filename_suffix+'.net.xml'
        root_cfg[0][1].attrib['value'] = scenario+filename_suffix+'.rou.xml'

        # ファイル書き込み
        tree_net.write(os.path.join(output_dir, scenario+filename_suffix+'.net.xml'), encoding='UTF-8')
        tree_rou.write(os.path.join(output_dir, scenario+filename_suffix+'.rou.xml'), encoding='UTF-8')
        tree_cfg.write(os.path.join(output_dir, scenario+filename_suffix+'.sumocfg'), encoding='UTF-8')