#!/bin/bash

scenario="charles"
sumo --remote-port 8813 -c ./sumo/original/${scenario}.sumocfg &
matlab -nodesktop -nosplash -sd "./mscript" -batch "beamtracking_ml('${scenario}_ml_ver4', 1, 1, 11, '../result', 0); exit;"