#!/bin/bash

# scenario="charles"
# sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
# /Applications/MATLAB_R2023a.app/bin/matlab -nodesktop -nosplash -sd "~/Documents/01Research/01Source/BeamTrackingAlgorithm/mscript" -batch "beamtracking_ml('${scenario}-ml-xgb_charles-type1-ver1', 1, 1, 11, '../result', 0); exit;"

# sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
# /Applications/MATLAB_R2023a.app/bin/matlab -nodesktop -nosplash -sd "~/Documents/01Research/01Source/BeamTrackingAlgorithm/mscript" -batch "beamtracking_ml('${scenario}-ml-xgb_charles-type2-ver1', 1, 1, 11, '../result', 0); exit;"

# sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
# /Applications/MATLAB_R2023a.app/bin/matlab -nodesktop -nosplash -sd "~/Documents/01Research/01Source/BeamTrackingAlgorithm/mscript" -batch "beamtracking_ml('${scenario}-ml-svm_charles-type2-ver1', 1, 1, 11, '../result', 0); exit;"


scenario="korakue2"
sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
/Applications/MATLAB_R2023a.app/bin/matlab -nodesktop -nosplash -sd "~/Documents/01Research/01Source/BeamTrackingAlgorithm/mscript" -batch "beamtracking_ml('${scenario}-2way', 0, 1, 11, '../datasource', 0); exit;"

scenario="korakue2"
sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
/Applications/MATLAB_R2023a.app/bin/matlab -nodesktop -nosplash -sd "~/Documents/01Research/01Source/BeamTrackingAlgorithm/mscript" -batch "beamtracking_ml('${scenario}-4way', 0, 1, 11, '../datasource', 0); exit;"

scenario="korakue2"
sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
/Applications/MATLAB_R2023a.app/bin/matlab -nodesktop -nosplash -sd "~/Documents/01Research/01Source/BeamTrackingAlgorithm/mscript" -batch "beamtracking_ml('${scenario}-2dim', 0, 1, 11, '../datasource', 0); exit;"

# scenario="korakuen"
# sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
# /Applications/MATLAB_R2023a.app/bin/matlab -nodesktop -nosplash -sd "~/Documents/01Research/01Source/BeamTrackingAlgorithm/mscript" -batch "beamtracking_ml('${scenario}-4way', 1, 1, 13, '../trash', 0); exit;"
