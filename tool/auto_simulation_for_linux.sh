#!/bin/bash

sumo --remote-port 8813 -c ./datasource/shinobazu.sumocfg &
matlab -nodesktop -nosplash -sd "./mscript" -batch "beamtracking_ml('shinobazu_ml')"