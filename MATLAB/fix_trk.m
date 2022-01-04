function fix_trk(correctionfile,featcorrectionfile)
load(correctionfile);
trk2=trk;
load(featcorrectionfile);
feat2=feat;
trackfile=dir('*-track.mat');
trackfilename=trackfile(1).name;
featfilename=strrep(trackfilename,'-track.mat','-feat.mat');
load(trackfilename);
load(featfilename);
idsfile='ids.mat';
load(idsfile);
all_flies=[1:40];
all_missing = all_flies(~ismember(all_flies,ids.id_new));
trk=replacetrkdata(all_missing,trk,trk2);
feat=replacetrkdata(all_missing,feat,feat2);
trk.flies_in_chamber=trk2.flies_in_chamber;

save(trackfilename,'trk');
save(featfilename,'feat');
