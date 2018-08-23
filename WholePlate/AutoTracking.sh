#!/bin/bash

/usr/local/bin/matlab -nodisplay -nosplash -r "AutoTracking"
/usr/local/bin/matlab -nodisplay -nosplash -r "ApplyClassifiers"
/usr/local/bin/matlab -nodisplay -nosplash -r "script_reassign_identities"

exit
