#!/bin/bash

sumo --remote-port 8813 -c ./datasource/curve_r60.sumocfg &
matlab -nodesktop -nosplash -sd "./mscript" -batch "beamtracking_4way_2dim('test_2dim')"