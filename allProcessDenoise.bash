#!/bin/bash

#bash /home/mose831/ImageProcessingScripts/cryoem_processing/tomoProcess/motionCorr.bash
bash /home/mose831/ImageProcessingScripts/cryoem_processing/tomoProcess/topazDenoise.bash
bash /home/mose831/ImageProcessingScripts/cryoem_processing/tomoProcess/Restack_SerialEM_denoise.bash
bash /home/mose831/ImageProcessingScripts/cryoem_processing/tomoProcess/IMOD_Auto_denoise.bash
bash /home/mose831/ImageProcessingScripts/cryoem_processing/tomoProcess/reconstructFromDenoise.bash

