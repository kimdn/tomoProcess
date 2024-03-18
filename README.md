Project directory
All scripts should be run in the same base directory containing raw data. 
Dependencies: This base directory must contain
a /frames/ directory, containing the raw movies output from the camera
a /stacks/ directory which contains .mdoc metadata files for each tilt series
a gain reference in .dm4 format (gain reference name is not critical but .dm4 format is)
a cryodirective.adoc file
The base directory is allowed to contain other files, such as atlases, medium mag montages, or other individual images. No other .dm4 files besides the gain may be in this base directory (if some present, move to a new subdirectory to prevent issues)
Parameters and definitions for cryodirective file can be found at: https://bio3d.colorado.edu/imod/doc/directives.html
Scripts needed
motionCorr.bash
Restack_SerialEM.bash
IMOD_Auto.bash
allProcess.bash
These scripts do not need to be located in the base directory, but must always be executed from the base directory location and should be stored together.
motionCorr by default bins the raw frames by a factor of 2, and uses 5x5 patches on 2 GPUs. Settings must be edited in script if different options desired.
Execution
Each script can be run individually (in order) if desired. The order of execution should be:
motionCorr.bash
Restack_SerialEM.bash
IMOD_Auto.bash
If the cryodirective.adoc file is already expected to be accurate for the dataset, only the allProcess.bash script needs to be run (it will call each script sequentially)
