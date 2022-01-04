%Annika Rings July 2018


%This function calls the assign_chambers function and the
%assign_score_identities function on inputdir
%these 2 functions have to be added to the path or they have to be located
%in the folder from which the function is executed
%further dependencies: nestStructSort package is required in one of the
%functions that i called from this function

%USAGE: in matlab command window, type: reassign_identities(inputdir)
%inputdir is the absolute or relative path to the input directory

%inputdir must contain the following:
%-a file named inputdir'-calibration.mat'
%-a JAABA folder named inputdir'_JAABA'
    %the JAABA folder must contain:
    %-a file named trx.mat
    %-a variable number of files named 'scores*.mat' (not necessary, but if
    %they don't exist, only the trx file will be corrected)


function reassign_identities(inputdir)
    startdir=pwd;
    JAABAfolder=strcat(inputdir,'_JAABA');
    assign_chambers(inputdir);
    cd(inputdir);
    assign_score_identities(JAABAfolder,'ids.mat');
    cd(startdir);
    clear all;
end
