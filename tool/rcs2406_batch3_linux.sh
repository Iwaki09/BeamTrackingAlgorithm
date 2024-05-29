#!/bin/bash

# scenario="korakuen"
# sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
# matlab -nodesktop -nosplash -sd "./mscript" -batch "beamtracking_ml('${scenario}-ml-svm_charles-type1-ver1', 0, 1, 11, '../result', 0); exit;"

# sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
# matlab -nodesktop -nosplash -sd "./mscript" -batch "beamtracking_ml('${scenario}-ml-svm_charles-type2-ver1', 0, 1, 11, '../result', 0); exit;"

# sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
# matlab -nodesktop -nosplash -sd "./mscript" -batch "beamtracking_ml('${scenario}-ml-dt_charles-type1-ver1', 0, 1, 11, '../result', 0); exit;"

# sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
# matlab -nodesktop -nosplash -sd "./mscript" -batch "beamtracking_ml('${scenario}-ml-dt_charles-type2-ver1', 0, 1, 11, '../result', 0); exit;"

# sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
# matlab -nodesktop -nosplash -sd "./mscript" -batch "beamtracking_ml('${scenario}-ml-xgb_charles-type1-ver1', 0, 1, 11, '../result', 0); exit;"

# sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
# matlab -nodesktop -nosplash -sd "./mscript" -batch "beamtracking_ml('${scenario}-ml-xgb_charles-type2-ver1', 0, 1, 11, '../result', 0); exit;"

scenario="charles"
# sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
# matlab -nodesktop -nosplash -sd "./mscript" -batch "beamtracking_ml('${scenario}-ml-svm_korakuen-type1-ver1', 0, 1, 11, '../result', 0); exit;"

# sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
# matlab -nodesktop -nosplash -sd "./mscript" -batch "beamtracking_ml('${scenario}-ml-svm_korakuen-type2-ver1', 0, 1, 11, '../result', 0); exit;"

# sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
# matlab -nodesktop -nosplash -sd "./mscript" -batch "beamtracking_ml('${scenario}-ml-dt_korakuen-type1-ver1', 0, 1, 11, '../result', 0); exit;"

sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
matlab -nodesktop -nosplash -sd "./mscript" -batch "beamtracking_ml('${scenario}-ml-dt_korakuen-type2-ver1', 0, 1, 11, '../result', 0); exit;"

sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
matlab -nodesktop -nosplash -sd "./mscript" -batch "beamtracking_ml('${scenario}-ml-xgb_korakuen-type1-ver1', 0, 1, 11, '../result', 0); exit;"

sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
matlab -nodesktop -nosplash -sd "./mscript" -batch "beamtracking_ml('${scenario}-ml-xgb_korakuen-type2-ver1', 0, 1, 11, '../result', 0); exit;"
