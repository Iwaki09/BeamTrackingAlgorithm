#!/bin/bash

scenario="korakuen"
sumo-gui --remote-port 8813 -c ./datasource/${scenario}.sumocfg &
matlab -nodesktop -nosplash -sd "./mscript" -batch "beamtracking_ml('${scenario}_ml')"