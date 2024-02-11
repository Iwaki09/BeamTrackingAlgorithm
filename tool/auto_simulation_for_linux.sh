#!/bin/bash

scenario="korakuen"
sumo --remote-port 8813 -c ./datasource/${scenario}.sumocfg &
matlab -nodesktop -nosplash -sd "./mscript" -batch "beamtracking_ml('${scenario}_ml_ver2')"