function [t0,t2,t4,onframes]=ison(videoname,numframes)
outputfilename=strrep(videoname,'.ufmf','_onframes.mat');
output_timings=strrep(videoname,'.ufmf','_performance.mat');
tic
[avimg,vinfo]=makeavimg(videoname,numframes);
t0=toc;
tic
frames=min(numframes,vinfo.n_frames);
onframes=zeros(frames,1);
t2=toc;

for id=0:(frames-1)
    tic
    [im,idnew] = video_read_frame(vinfo, id);
    t4=toc;
    numabovethresh=finddiff(avimg,im,0.35,2100,2400,600,1000);
    if numabovethresh>40
        onframes(id+1)=1;
    end
    
end
save(outputfilename,'onframes');
save(output_timings,'t0','t2','t4');