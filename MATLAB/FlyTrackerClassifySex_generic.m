% Author (original version): Kristin Branson
% Author (modified version): Aaron M. Allen

% Date: 2022.01.05

% Description:
% modified to accept either the track.mat file or the trx.mat file

function td = FlyTrackerClassifySex_generic(matfile,filetype,fracmale,dosave)




td = load(matfile);
if strcmp(filetype, 'trx'),
    nflies = numel(td.trx);
elseif strcmp(filetype, 'track'),
    nflies = size(td.trk.data,1);
end

nmale = round(fracmale*nflies);
nfemale = nflies - nmale;

if nmale == 1,
    if strcmp(filetype, 'trx'),
        for i = 1:nflies,
            td.trx(i).sex = 'M';
        end
    elseif strcmp(filetype, 'track'),
        td.trk.names{36} = ['sex'];
        for i = 1:nflies,
            td.trk.data(i,:,36) = 'M';
        end
    end
elseif nfemale == 1,
    if strcmp(filetype, 'trx'),
        for i = 1:nflies,
            td.trx(i).sex = 'F';
        end
    elseif strcmp(filetype, 'track'),
        td.trk.names{36} = ['sex'];
        for i = 1:nflies,
            td.trk.data(i,:,36) = 'F';
        end
    end
else
    area = nan(1,nflies);
    for i = 1:nflies,
        if strcmp(filetype, 'trx'),
            area(i) = nanmedian(td.trx(i).a.*td.trx(i).b);
        elseif strcmp(filetype, 'track'),
            area(i) = nanmedian(td.trk.data(i,:,4).*td.trk.data(i,:,5));
        end
    end
    [~,order] = sort(area);

    if strcmp(filetype, 'trx'),
        for i = 1:nmale,
            td.trx(order(i)).sex = 'M';
        end
        for i = nmale+1:nflies,
            td.trx(order(i)).sex = 'F';
        end
    elseif strcmp(filetype, 'track'),
        td.trk.names{36} = ['sex'];
        for i = 1:nmale,
            td.trk.data(order(i),:,36) = 'M';
        end
        for i = nmale+1:nflies,
            td.trk.data(order(i),:,36) = 'F';
        end
    end
end

if dosave,
    save(matfile,'-struct','td');
end
