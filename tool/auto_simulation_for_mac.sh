#!/bin/bash

# sumo --remote-port 8813 -c ./datasource/curve_r60.sumocfg &
# cd /Applications/MATLAB_R2023a.app/bin/
# ./matlab -nodesktop -nosplash -sd "~/Documents/01Research/code/BeamTrackingAlgorithm/mscript" -batch "beamtracking_non_func; exit;"

/Applications/MATLAB_R2023a.app/bin/matlab -nodesktop -nosplash -sd "~/Documents/01Research/01Source/BeamTrackingAlgorithm/mscript" -batch "beamtracking_4way_2dim('curve_test_2dim'); exit;"
# /Applications/MATLAB_R2023a.app/bin/matlab -nodesktop -nosplash -sd "~/Documents/01Research/01Source/BeamTrackingAlgorithm/mscript" -batch "TraciTest2;"