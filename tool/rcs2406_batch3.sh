#!/bin/bash

scenario="charles"
sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
/Applications/MATLAB_R2023a.app/bin/matlab -nodesktop -nosplash -sd "~/Documents/01Research/01Source/BeamTrackingAlgorithm/mscript" -batch "beamtracking_ml('${scenario}-ml-svm_korakuen-type1-ver1', 0, 1, 11, '../result', 0); exit;"

sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
/Applications/MATLAB_R2023a.app/bin/matlab -nodesktop -nosplash -sd "~/Documents/01Research/01Source/BeamTrackingAlgorithm/mscript" -batch "beamtracking_ml('${scenario}-ml-svm_korakuen-type2-ver1', 0, 1, 11, '../result', 0); exit;"

sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
/Applications/MATLAB_R2023a.app/bin/matlab -nodesktop -nosplash -sd "~/Documents/01Research/01Source/BeamTrackingAlgorithm/mscript" -batch "beamtracking_ml('${scenario}-ml-dt_korakuen-type1-ver1', 0, 1, 11, '../result', 0); exit;"

sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
/Applications/MATLAB_R2023a.app/bin/matlab -nodesktop -nosplash -sd "~/Documents/01Research/01Source/BeamTrackingAlgorithm/mscript" -batch "beamtracking_ml('${scenario}-ml-dt_korakuen-type2-ver1', 0, 1, 11, '../result', 0); exit;"

sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
/Applications/MATLAB_R2023a.app/bin/matlab -nodesktop -nosplash -sd "~/Documents/01Research/01Source/BeamTrackingAlgorithm/mscript" -batch "beamtracking_ml('${scenario}-ml-xgb_korakuen-type1-ver1', 0, 1, 11, '../result', 0); exit;"

sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
/Applications/MATLAB_R2023a.app/bin/matlab -nodesktop -nosplash -sd "~/Documents/01Research/01Source/BeamTrackingAlgorithm/mscript" -batch "beamtracking_ml('${scenario}-ml-xgb_korakuen-type2-ver1', 0, 1, 11, '../result', 0); exit;"
