#!/bin/bash

scenario="curve_r40"
sumo --remote-port 8813 -c ./datasource/${scenario}.sumocfg &
matlab -nodesktop -nosplash -sd "./mscript" -batch "beamtracking_ml('${scenario}_ml_ver2')"