#!/bin/bash

scenario="korakuen"
sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
/Applications/MATLAB_R2023a.app/bin/matlab -nodesktop -nosplash -sd "~/Documents/01Research/01Source/BeamTrackingAlgorithm/mscript" -batch "beamtracking_ml('${scenario}-2way', 0, 1, 11, '../trash', 0); exit;"

sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
/Applications/MATLAB_R2023a.app/bin/matlab -nodesktop -nosplash -sd "~/Documents/01Research/01Source/BeamTrackingAlgorithm/mscript" -batch "beamtracking_ml('${scenario}-2dim', 0, 1, 11, '../trash', 0); exit;"

sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
/Applications/MATLAB_R2023a.app/bin/matlab -nodesktop -nosplash -sd "~/Documents/01Research/01Source/BeamTrackingAlgorithm/mscript" -batch "beamtracking_ml('${scenario}-4way', 0, 1, 11, '../trash', 0); exit;"
