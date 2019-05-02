function [avimg,vinfo]=makeavimg(videoname)
vinfo = video_open(videoname)
avimg=zeros(vinfo.sx,vinfo.sy);
for id=0:(vinfo.n_frames-1)
[im,idnew] = video_read_frame(vinfo, id);
avimg=avimg+im;
end
avimg=avimg./vinfo.n_frames;
