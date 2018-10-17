%Annika Rings July 2018
%function for reassigning identities of flies in the JAABA output files
%named 'scores*.mat'
%USAGE: in matlab command window, type: assign_score_identities(scoresdir,idsfile)
%scoresdir is the absolute or relative path to the input directory that
%contains the scores files
%idsfile is the file containing a structure with old and new ids of the
%flies (as created by the assign_chambers function)

%this function saves an id-corrected version of each scores file appending the
%ending _id_corrected.mat in the scoresdir


function assign_score_identities(scoresdir,idsfile)
startdir=pwd;
load(idsfile);
if ~isempty(dir('*track_old.mat'))
    
else    
    trackfile=dir('*-track.mat');
    trackfilename=trackfile(1).name;
    trackfilename_old=strrep(trackfilename,'.mat','_old.mat');
    trackoutputfile=strrep(trackfilename,'.mat','_id_corrected.mat');
    id_correct_trackfile(trackfilename,trackoutputfile,ids);
    movefile(trackfilename, trackfilename_old);
    copyfile(trackoutputfile,trackfilename);
    
    featfile=dir('*-feat.mat');
    featfilename=featfile(1).name;
    featfilename_old=strrep(featfilename,'.mat','_old.mat');
    featoutputfile=strrep(featfilename,'.mat','_id_corrected.mat');
    id_correct_featfile(featfilename,featoutputfile,ids);
    movefile(featfilename, featfilename_old);
    copyfile(featoutputfile,featfilename);
end
cd (scoresdir);

scoresfiles=dir('scores*.mat');
scoresfilenames=arrayfun(@(f) f.name,scoresfiles,'UniformOutput',false);
outputfilenames=cellfun(@(f) strrep(f,'.mat','_id_corrected.mat'),scoresfilenames,'UniformOutput',false);
cellfun(@(scoresfilename,outputfilename) id_correct_scorefile(scoresfilename,outputfilename,ids),scoresfilenames,outputfilenames);
cd ('perframe');

matfiles=dir('*.mat');
matfilenames=arrayfun(@(f) f.name,matfiles,'UniformOutput',false);
outputfilenames=cellfun(@(f) strrep(f,'.mat','_id_corrected.mat'),matfilenames,'UniformOutput',false);
cellfun(@(matfilename,outputfilename) id_correct_matfile(matfilename,outputfilename,ids),matfilenames,outputfilenames);

cd(startdir);
clear all;
end

function id_correct_trackfile(trackfilename,outputfilename,ids)
load(trackfilename);
data=trk.data;

id_new = ids.id_new;
id_old = ids.id_old;
for i=1:numel(id_old)
data_new(id_new(i),:,:)=data(id_old(i),:,:);

end

trk.data=deal(data_new);
save(outputfilename,'trk');
end

function id_correct_featfile(featfilename,outputfilename,ids)
load(featfilename);
data=feat.data;

id_new = ids.id_new;
id_old = ids.id_old;
for i=1:numel(id_old)
data_new(id_new(i),:,:)=data(id_old(i),:,:);

end

feat.data=deal(data_new);
save(outputfilename,'feat');
end

function id_correct_scorefile(scoresfilename,outputfilename,ids)
load(scoresfilename);
scores=allScores.scores;
postprocessed=allScores.postprocessed;
id_new = ids.id_new;
id_old = ids.id_old;
for i=1:numel(id_old)
postprocessed_new{1,id_new(i)}=postprocessed{1,id_old(i)};
scores_new{1,id_new(i)}=scores{1,id_old(i)};
end

allScores.scores=deal(scores_new);
allScores.postprocessed=deal(postprocessed_new);
save(outputfilename,'allScores');
end

function id_correct_matfile(matfilename,outputfilename,ids)
load(matfilename);
id_new = ids.id_new;
id_old = ids.id_old;
for i=1:numel(id_old)
data_new{1,id_new(i)}=data{1,id_old(i)};
end

data=data_new;
save(outputfilename,'data','units');
end