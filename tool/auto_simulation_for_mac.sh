#!/bin/bash

scenario="paris"
sumo --remote-port 8813 -c ./datasource/${scenario}.sumocfg &
/Applications/MATLAB_R2023a.app/bin/matlab -nodesktop -nosplash -sd "~/Documents/01Research/01Source/BeamTrackingAlgorithm/mscript" -batch "beamtracking_ml('${scenario}_2dim'); exit;"
