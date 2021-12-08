% Author: Aaron M. Allen
% Date: 2018.10.31
%     updated: 2021.12.02

% Description:
% This script uses the JAABADetect functio to apply JAABA classifiers in the JABfilelist.txt from the JABFromFlyTracker
% to videos that have been tracked with the Caltech FlyTracker. This script assume the directory structure that is
% generated by this tracker.



% add our MATLAB code to path if its not there already
check = which('DiagnosticPlots');
if isempty(check)
    parentdir = fileparts(mfilename('fullpath'));
    addpath(genpath(parentdir));
end


# this is not as clean as above, but might clean up later.
addpath(genpath('../../JAABA/perframe'));
JABFiles = 'JABsFromFlyTracker/JABfilelist.txt';     # add genpath() ?
wingJAB = 'JABsFromFlyTracker/WingGesture.jab';      # add genpath() ?


# The variable "OutputDirectory" and "FileName" are passed to the script when running from bash
# Do I need to change directory?
cd ([OutputDirectory '/' FileName]);




% Apply Classifiers
% ==========================================================================

diary([OutputDirectory '/' FileName '/Logs/JAABA_logfile.log'])
diary on

disp(datetime('now'));
disp(['Now applying classifiers for: ' FileName]);
error_handling_wrapper([OutputDirectory '/' FileName '/Logs/JAABA_errors.log'],'JAABADetect',[FileName '/' FileName '_JAABA'],'jablistfile',JABFiles);


diary off
exit
