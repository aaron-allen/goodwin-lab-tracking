%%Annika Rings May 2018

%Script to Convert Ctrax+wingtracking data to JAABA input data for all
%experimental directories in the specified input directory

%USAGE type (in Matlab Command window): Ctrax2JAABA_wholedir(input_directory,
%output_directory)
%input_directory and output_directory must be the full paths to the
%respective directories

function Ctrax2JAABA_wholedir(rootdatadir, expdirstr)

dirs = dir(rootdatadir);

for i = 1:numel(dirs)
  if ~dirs(i).isdir
    continue;
  end
  
  name = dirs(i).name;
  if ismember(name,{'.','..'})
    continue;
  end
  disp('Now converting directory:');
  disp(name);



inmoviefilestr = 'movie.ufmf';
intrxfilestr = 'test.mat';
annfilestr = 'movie.ufmf.ann';
inperframedirstr = 'perframe';
currentdir=name;

expdir = fullfile(expdirstr,currentdir);
inmoviefile = fullfile(rootdatadir,currentdir,inmoviefilestr);
intrxfile = fullfile(rootdatadir,currentdir,intrxfilestr);
annfile = fullfile(rootdatadir,currentdir,annfilestr);
inperframedir = fullfile(rootdatadir,currentdir,inperframedirstr);
fps=25;
overridefps = true;
arenatype = 'Circle';
perframedirstr ='perframe';
[success,msg] = ConvertCtrax2JAABA('inmoviefile',inmoviefile,'intrxfile',intrxfile,'annfile',annfile,'inperframedir',inperframedir,'fps',fps,'overridefps',overridefps,'arenatype', arenatype,'perframedirstr',perframedirstr,'expdir',expdir)
end