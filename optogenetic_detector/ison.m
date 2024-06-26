function ison(videoname,numframes)
outputfilename=strrep(videoname,'.ufmf','_onframes.mat');
output_timings=strrep(videoname,'.ufmf','_performance.mat');
tic
[avimg,vinfo]=makeavimg(videoname,numframes);
t0=toc;
tic
frames=min(numframes,vinfo.n_frames);
onframes=zeros(frames,1);
t2=toc;
tic
for id=0:(frames-1)
    
    [im,idnew] = video_read_frame(vinfo, id);
    
    numabovethresh=finddiff(avimg,im,0.35,2100,2400,600,1000);
    if numabovethresh>40
        onframes(id+1)=1;
    end
    
end
t4=toc;
save(outputfilename,'onframes');
save(output_timings,'t0','t2','t4');