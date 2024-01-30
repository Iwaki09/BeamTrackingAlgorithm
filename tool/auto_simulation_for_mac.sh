#!/bin/bash

sumo --remote-port 8813 -c ./datasource/direct.sumocfg &
/Applications/MATLAB_R2023a.app/bin/matlab -nodesktop -nosplash -sd "~/Documents/01Research/01Source/BeamTrackingAlgorithm/mscript" -batch "beamtracking_ml('direct_4way'); exit;"
