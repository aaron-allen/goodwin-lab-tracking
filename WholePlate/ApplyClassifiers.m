% Aaron M. Allen, 2018.10.31
% This script uses the JAABADetect functio to apply JAABA classifiers in the JABfilelist.txt from the JABFromFlyTracker
% to videos that have been tracked with the Caltech FlyTracker. This script assume the directory structure that is
% generated by this tracker. 


addpath(genpath('/home/goodwintracking/TheCompleteFlyTrackingBundle/WholePlate'));
addpath /home/goodwintracking/TheCompleteFlyTrackingBundle/JAABA-master/perframe;
JABFiles = '/home/goodwintracking/TheCompleteFlyTrackingBundle/JABsFromFlyTracker/JABfilelist.txt';
wingJAB = '/home/goodwintracking/TheCompleteFlyTrackingBundle/JABsFromFlyTracker/WingGesture.jab';

% Apply Classifiers
% ==========================================================================
dirs = dir();
CurrDir = (pwd);
diary('JAABA_logfile.log')
for p = 1:numel(dirs)
    if ~dirs(p).isdir
      continue;
    end
    JAABAname = dirs(p).name;
    if ismember(JAABAname,{'.','..'})
      continue;
    end 
    diary on
    cd (JAABAname);
    JAABAdir =(pwd);
    
    
    % Added a bit of code to asses the number of flies per chamber, and if it varies
    % between chambers, to delete the offending rows from the trx.mat file. The Classifiers
    % have been trained assuming that there are 2 flies in each chamber, and won't work if
    % there isn't (except maybe the WingGesture).

    TrackFile = dir('*track.mat');
    load(TrackFile.name);
    cd ([JAABAname '_JAABA']);
    disp('Loading trx.mat')
    load('trx.mat');

    % Determining the average number of flies per chamber
    TotalFlies = 0;
    for F = 1:size(trk.flies_in_chamber,2)
        TotalFlies = TotalFlies + size(trk.flies_in_chamber{F},2);
    end
    FliesPerChamber = TotalFlies/size(trk.flies_in_chamber,2);

    % If the average flies per chamber is between 1 and 2 (ie was supposed to be 2, but
    % a fly died or escaped from a chamber), then the below deletes the entry in the trx.mat
    % file for the remaining fly in the offending chambers. This will allow the social
    % classifiers to be applied without issue.
    if (1 < FliesPerChamber) && (FliesPerChamber < 2)
        disp('The number of flies differs between chambers.');
        % cd ([JAABAname '_JAABA']);
        save('trxBackup.mat', 'trx', 'timestamps');
        for N = 1:size(trk.flies_in_chamber,2)
          if size(trk.flies_in_chamber{N},2) == 1
            disp('Deleting row of trx file.');
            trx([trx.id]==trk.flies_in_chamber{N}) = [];
          end
        save('trx.mat', 'trx', 'timestamps')    
        end
        % cd ..
    else
        if (FliesPerChamber == 2)
            disp('There are 2 flies per chamber.')
        else
            if (FliesPerChamber == 1)
                disp('There is 1 fly per chamber.')
            end
        end
    end
    cd (JAABAdir);
    disp(['Now applying classifiers for: ' JAABAname]);
    if (round(FliesPerChamber)==2)
        error_handling_wrapper('JAABA_errors.log','JAABADetect',[JAABAname '_JAABA'],'jablistfile',JABFiles);
    else
        error_handling_wrapper('JAABA_errors.log','JAABADetect',[JAABAname '_JAABA'],'jabfiles',wingJAB);
    end
    diary off
    cd (CurrDir)
end
exit
