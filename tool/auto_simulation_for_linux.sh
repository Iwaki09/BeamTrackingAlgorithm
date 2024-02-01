#!/bin/bash

sumo --remote-port 8813 -c ./datasource/okutama.sumocfg &
matlab -nodesktop -nosplash -sd "./mscript" -batch "beamtracking_ml('okutama_ml')"