function [trk_updated]=replacetrkdata(missing,trk,trk2)
trk_updated=trk;
for ind=1:size(missing,2)
    trk_updated.data(missing(ind),:,:)=trk2.data(missing(ind),:,:);
end
