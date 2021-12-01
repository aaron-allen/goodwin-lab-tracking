#!/bin/bash

/usr/local/bin/matlab -nodisplay -nosplash -r "AutoTracking"
/usr/local/bin/matlab -nodisplay -nosplash -r "script_detect_optogenetic_light"
/usr/local/bin/matlab -nodisplay -nosplash -r "DeleteSingletonFlies"
/usr/local/bin/matlab -nodisplay -nosplash -r "ApplyClassifiers"
/usr/local/bin/matlab -nodisplay -nosplash -r "script_reassign_identities"


exit
