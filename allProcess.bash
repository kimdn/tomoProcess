#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

bash $SCRIPT_DIR/motionCorr.bash
bash $Script_DIR/topazdenoise.bash
bash $SCRIPT_DIR/Restack_SerialEM.bash
bash $SCRIPT_DIR/IMOD_Auto.bash

