function [avimg,vinfo]=makeavimg(videoname,numframes)
vinfo = video_open(videoname)
avimg=zeros(vinfo.sx,vinfo.sy);
frames=min(numframes,vinfo.n_frames);
for id=0:(frames-1)
[im,idnew] = video_read_frame(vinfo, id);
avimg=avimg+im;
end
avimg=avimg./frames;
