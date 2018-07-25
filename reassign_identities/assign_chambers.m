%Annika Rings July 2018
%function for reassigning chamber numbers and identities of flies that were
%tracked by Flytracker

%depends on the nestStructSort package - this must be added to the path or
%located in the folder from which the function is executed.

%USAGE: in matlab command window, type: assign_chambers(inputdir)
%inputdir is the absolute or relative path to the input directory

%reads in data from a file called 'inputdir-calibration.mat' located in
%inputdir
%reads additional data from a file called 'trx.mat' located in the folder
%called 'inputdir_JAABA' in inputdir
%saves a structure 'ids' in a file called 'ids.mat' in the inputdir

%the reassign identities function automatically calls this function

function assign_chambers(inputdir)
startdir=pwd;
cd (inputdir);
calibfile=strcat(inputdir,'-calibration.mat');
JAABAfolder=strcat(inputdir,'_JAABA');
trxfile=fullfile(JAABAfolder,'trx.mat');
trxfile_new=strrep(trxfile,'.mat','_id_corrected.mat');
load(calibfile);
load(trxfile);
id_old=arrayfun(@(f) f.id,trx);
meanx=arrayfun(@(f) mean(rmmissing(f.x)),trx);
meany=arrayfun(@(f) mean(rmmissing(f.y)),trx);
meanx_c=num2cell(meanx);
[trx(:).meanx]=deal(meanx_c{:});
meany_c=num2cell(meany);
[trx(:).meany]=deal(meany_c{:});
centroid=sortrows(calib.centroids,1);
centroid(1:5)=sortrows(centroid(1:5),2);
centroid(6:10)=sortrows(centroid(6:10),2);
centroid(11:15)=sortrows(centroid(11:15),2);
centroid(16:20)=sortrows(centroid(16:20),2);
maxx_chambers=centroid(:,2)+round((calib.rois{1}(4))/2);
minx_chambers=centroid(:,2)-round((calib.rois{1}(4))/2);
maxy_chambers=centroid(:,1)+round((calib.rois{1}(4))/2);
miny_chambers=centroid(:,1)-round((calib.rois{1}(4))/2);
firstx=arrayfun(@(f) f.x(1),trx);
chambers=arrayfun(@(f) assign_one(f,maxy_chambers,miny_chambers,maxx_chambers,minx_chambers),trx);
startpos=left_right_assign(chambers,firstx);
[trx(:).startpos]=deal(startpos{:});
id_new=assign_identity(chambers);
id_new_c=num2cell(id_new);
[trx(:).id]=deal(id_new_c{:});
fields = {'meanx','meany'};
trx = rmfield(trx,fields);
trx=nestedSortStruct(trx,'id');
ids=struct('id_old',id_old,'id_new',id_new,'chambers',chambers);
save_assigned('ids',ids);
save(trxfile_new,'trx');

cd(startdir);
clear all;


function chambernumber=assign_one(f,maxy_chambers,miny_chambers,maxx_chambers,minx_chambers)

for i=1:20
    if f.meany<maxy_chambers(i)&&f.meany>miny_chambers(i)&&f.meanx<maxx_chambers(i)&&f.meanx>minx_chambers(i)
        chambernumber=i;
    end
end

function id_new=assign_identity(chambers)
individuals=[1 2; 3 4; 5 6; 7 8; 9 10; 11 12; 13 14; 15 16; 17 18; 19 20;21 22; 23 24; 25 26;27 28;29 30;31 32;33 34;35 36;37 38;39 40];
flag(1:20)=1;
for i=1:numel(chambers)
id_new(i)=individuals(chambers(i),flag(chambers(i))); flag(chambers(i))=2;
end

function save_assigned(filename,ids)

 save(filename,'ids');
    
 function startpos=left_right_assign(chambers,firstx)
     startpos={};
     for i=1:20
         firstxi=firstx(chambers==i);
         if numel(firstxi)==2
         if firstxi(1)<firstxi(2)
             
             startpos{(size(startpos,1)+1),1}={'l'};
             startpos{(size(startpos,1)+1),1}={'r'};
         else
              startpos{(size(startpos,1)+1),1}={'r'};
             startpos{(size(startpos,1)+1),1}={'l'};
         end
         elseif numel(firstxi)==1
             startpos{(size(startpos,1)+1),1}={'l'};
         end
             
     end

