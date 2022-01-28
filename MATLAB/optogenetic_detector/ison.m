function ison(videoname, numframes)
    [path_string, base_name, video_ext] = fileparts(videoname);
    outputfilename = [base_name '_onframes.mat'];
    output_timings = [base_name '_performance.mat'];

    disp('    Making average image ...');
    tic
    [avimg, stdev, vinfo] = makeavimg(videoname, numframes);
    t0 = toc;

    tic
    frames = min(numframes, vinfo.n_frames);
    onframes = false(frames, 1);
    % find the positions of the indicator led;
    max_ypos = vinfo.sy;
    max_xpos = round(vinfo.sx/2 + vinfo.sx/10);
    min_ypos =  max_ypos - (round(max_ypos/8));
    min_xpos = round(vinfo.sx/2 - vinfo.sx/10);
    numpixels_lightarea = (max_ypos - min_ypos) * (max_xpos - min_xpos);
    t2 = toc;

    disp('    Finding differences ...');
    tic
    for id = 0:(frames - 1)
        if mod(id,1000) == 0,
            disp([ '        frame = ' num2str(id) ]);
        end

        [im, idnew] = video_read_frame(vinfo, id);

        numabovethresh = finddiff(avimg, im, mean(mean(real(stdev))), min_ypos, max_ypos, min_xpos, max_xpos);
        if numabovethresh > round(numpixels_lightarea/50)
            onframes(id+1) = true;
        end

    end
    t4 = toc;

    save(outputfilename, 'onframes');
    save(output_timings, 't0', 't2', 't4');
end
