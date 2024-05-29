#!/bin/bash

scenario="paris2"
sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
matlab -nodesktop -nosplash -sd "./mscript" -batch "beamtracking_ml('${scenario}-ml-svm_generic-type1-ver1', 0, 1, 11, '../result', 0); exit;"

sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
matlab -nodesktop -nosplash -sd "./mscript" -batch "beamtracking_ml('${scenario}-ml-svm_generic-type2-ver1', 0, 1, 11, '../result', 0); exit;"

sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
matlab -nodesktop -nosplash -sd "./mscript" -batch "beamtracking_ml('${scenario}-ml-dt_generic-type1-ver1', 0, 1, 11, '../result', 0); exit;"

sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
matlab -nodesktop -nosplash -sd "./mscript" -batch "beamtracking_ml('${scenario}-ml-dt_generic-type2-ver1', 0, 1, 11, '../result', 0); exit;"

sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
matlab -nodesktop -nosplash -sd "./mscript" -batch "beamtracking_ml('${scenario}-ml-xgb_generic-type1-ver1', 0, 1, 11, '../result', 0); exit;"

sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
matlab -nodesktop -nosplash -sd "./mscript" -batch "beamtracking_ml('${scenario}-ml-xgb_generic-type2-ver1', 0, 1, 11, '../result', 0); exit;"
