#!/bin/bash

scenario="paris"
sumo --remote-port 8813 -c ./datasource/${scenario}.sumocfg &
matlab -nodesktop -nosplash -sd "./mscript" -batch "beamtracking_ml('${scenario}_ml_ver1')"