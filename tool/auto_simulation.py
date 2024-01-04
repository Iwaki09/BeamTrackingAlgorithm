import subprocess

sumo_xml_dir = './sumo_xml'
output_dir = './result'
matlab_dir = './mscript'

scenarios = ['direct', 'curve_r150', 'curve_r60', 'curve_r40', 'curve_r30']

depart_speed = '0.00'

for scenario in scenarios:
    if scenario == 'direct':
        continue
    for max_speed in reversed(range(1, 20, 1)):
        for accel in reversed(range(1, 10, 1)):
            # sumocfgに書かれるファイル名
            filename_suffix = '_ms{}_ac{}_ds{}'.format(max_speed, accel, depart_speed)
            filename = scenario + filename_suffix
            cmd1 = 'sumo --remote-port 8813 -c ' + sumo_xml_dir + '/' + scenario + '/' + filename + '.sumocfg &'
            subprocess.call(cmd1, shell=True)
            cmd2 = 'matlab -nodesktop -nosplash -sd \"' + matlab_dir + '\" -batch \"beamtracking_4way_2dim(\'' + filename + '_2dim\')\"'
            subprocess.call(cmd2, shell=True)

            subprocess.call(cmd1, shell=True)
            cmd3 = 'matlab -nodesktop -nosplash -sd \"' + matlab_dir + '\" -batch \"beamtracking_4way_2dim(\'' + filename + '_4way\')\"'
            subprocess.call(cmd3, shell=True)