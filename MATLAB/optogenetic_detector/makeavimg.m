function [avimg, sigma, vinfo] = makeavimg(videoname, numframes)
vinfo = video_open(videoname);
avimg = zeros(vinfo.sx, vinfo.sy);
sumofsquares = zeros(vinfo.sx, vinfo.sy);
frames = min(numframes, vinfo.n_frames);
%loading frames one by one
%this is slow, but intended to save memory compared to loading the whole
%video
for id = 0:(frames - 1)
    [im, idnew] = video_read_frame(vinfo, id);
    avimg = avimg + im;
    imsquare = im .* im;
    sumofsquares = sumofsquares + imsquare;
end


avimg = avimg ./ frames;
sqav = avimg .* avimg;
sigma = sqrt((sumofsquares - (sqav .* frames)) ./ (frames - 1));
