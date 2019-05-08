function onframes=ison(videoname,numframes)
[avimg,vinfo]=makeavimg(videoname);
onframes=zeros(vinfo.n_frames,1);
frames=min(numframes,vinfo.n_frames);
for id=0:(frames-1)
    [im,idnew] = video_read_frame(vinfo, id);
    numabovethresh=finddiff(avimg,im,0.35,2100,2400,700,900);
    if numabovethresh>40
        onframes(id+1)=1;
    end
end