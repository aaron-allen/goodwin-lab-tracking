% Author (original version): Kristin Branson
% Author (modified version): Aaron M. Allen

% Date: 2022.01.05

% Description:
% modified to accept either the track.mat file or the trx.mat file

function td = FlyTrackerClassifySex_generic(matfile,varargin)

[filetype,fracmale,dosave] = ...
  myparse(varargin,...
  'filetype','trx','fracmale',.5,'dosave',true);

td = load(matfile);
if filetype == 'trx',
    nflies = numel(td.trx);
elseif filetype == 'track',
    nflies = size(td.trk.data,1);
end

nmale = round(fracmale*nflies);
nfemale = nflies - nmale;

if nmale == 1,
    if filetype == 'trx',
        for i = 1:nflies,
            td.trx(i).sex = 'male';
        end
    elseif filetype == 'track',
        td.trk.names{36} = ['sex']
        for i = 1:nflies,
            td.trk.data(i,:,36) = 'male';
        end
    end
elseif nfemale == 1,
    if filetype == 'trx',
        for i = 1:nflies,
            td.trx(i).sex = 'female';
        end
    elseif filetype == 'track',
        td.trk.names{36} = ['sex']
        for i = 1:nflies,
            td.trk.data(i,:,36) = 'female';
        end
    end
else
    area = nan(1,nflies);
    for i = 1:nflies,
        if filetype == 'trx',
            area(i) = nanmedian(td.trx(i).a.*td.trx(i).b);
        elseif filetype == 'track',
            area(i) = nanmedian(td.trk.data(i,:,4).*td.trk.data(i,:,5));
        end
    end
    [~,order] = sort(area);

    for i = 1:nmale,
        if filetype == 'trx',
            td.trx(order(i)).sex = 'male';
        elseif filetype == 'track',
            td.trk(order(i),:,36) = 'male';
        end
    end
    for i = nmale+1:nflies,
        if filetype == 'trx',
            td.trx(order(i)).sex = 'female';
        elseif filetype == 'track',
            td.trk(order(i),:,36) = 'female';
        end
    end
end

if dosave,
    save(matfile,'-struct','td');
end
