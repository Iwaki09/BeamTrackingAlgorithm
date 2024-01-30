#!/bin/bash

sumo --remote-port 8813 -c ./datasource/curve_r60.sumocfg &
/Applications/MATLAB_R2023a.app/bin/matlab -nodesktop -nosplash -sd "~/Documents/01Research/01Source/BeamTrackingAlgorithm/mscript" -batch "beamtracking_ml('curve_r60_4way'); exit;"
