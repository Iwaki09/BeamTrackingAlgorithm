#!/bin/bash

scenario="charles"
sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
/Applications/MATLAB_R2023a.app/bin/matlab -nodesktop -nosplash -sd "~/Documents/01Research/01Source/BeamTrackingAlgorithm/mscript" -batch "beamtracking_ml('${scenario}_2way', 1, 1, 13, '../model', 0); exit;"
