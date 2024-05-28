import subprocess
import os

input_dir = './sumo/duplicated'
output_dir = './dataset'
matlab_dir = './mscript'

# scenarios = ['direct', 'curve_r150', 'curve_r60', 'curve_r40', 'curve_r30']
scenarios = ['korakuen']

# depart_speed = '0.00'

for scenario in scenarios:
    for max_speed in reversed(range(3, 20, 1)):
        for accel in reversed(range(1, 10, 1)):
            for depart_speed in ['0.00', '2.00', '4.00']:
                # sumocfgに書かれるファイル名
                filename_suffix = '_ms{}_ac{}_ds{}'.format(max_speed, accel, depart_speed)
                filename = scenario + filename_suffix
                output_subdir = os.path.join(output_dir, scenario)
                cmd1 = 'sumo --remote-port 8813 -c ' + input_dir + '/' + scenario + '/' + filename + '.sumocfg &'
                subprocess.call(cmd1, shell=True)
                cmd2 = '/Applications/MATLAB_R2023a.app/bin/matlab -nodesktop -nosplash -sd \"' + matlab_dir + '\" -batch \"beamtracking_ml(\'' + scenario + '-2dim\', 0, 1, 12, \'../' + output_subdir + '\', 0)\"'
                subprocess.call(cmd2, shell=True)
                cmd3 = '/Applications/MATLAB_R2023a.app/bin/matlab -nodesktop -nosplash -sd \"' + matlab_dir + '\" -batch \"beamtracking_ml(\'' + scenario + '-4way\', 0, 1, 12, \'../' + output_subdir + '\', 0)\"'
                subprocess.call(cmd1, shell=True)
                subprocess.call(cmd3, shell=True)