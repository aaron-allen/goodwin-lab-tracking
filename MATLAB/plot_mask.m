% add our MATLAB code to path if its not there already
check = which('AutoTracking');
if isempty(check)
    parentdir = fileparts(mfilename('fullpath'));
    addpath(genpath(parentdir));
end

%%

% The variable "OutputDirectory" and "FileName" are passed to the script when running from bash
% Do I need to change directory?
cd ([OutputDirectory '/' FileName]);


videoFilePath = [FileName '.mp4'];                          % Define the path to the video file
videoObj = VideoReader(videoFilePath);                      % Read the video file
firstFrame = readFrame(videoObj);                           % Read the first frame
load('calibration.mat')                                     % Load the calibration data
maskArray = calib.full_mask; 

% Resize the mask array if necessary to match the frame size
if any(size(maskArray) ~= [videoObj.Height, videoObj.Width])
    maskArray = imresize(maskArray, [videoObj.Height, videoObj.Width]);
end

% Apply transparency to the mask
alpha = 0.5; % Set transparency level (adjust as needed)
overlayedImage = firstFrame;
overlayedImage(repmat(maskArray, [1, 1, 3])) = ...
    alpha * firstFrame(repmat(maskArray, [1, 1, 3])) + ...
    (1 - alpha) * 255; % Overlay the mask with transparency


% Create a 3-panel plot with specific size
figure('Units', 'centimeters', 'Position', [0, 0, 21, 29.7]);

% Plot video image on the left
subplot(3, 1, 1);
imshow(firstFrame);
title('Video Image');

% Plot mask alone in the middle
subplot(3, 1, 2);
imshow(maskArray);
title('Mask Alone');

% Plot overlay on the right
subplot(3, 1, 3);
imshow(overlayedImage);
title('Overlay');



%%

% Create the "Results" subfolder if it doesn't exist
if ~exist('Results', 'dir')
    mkdir('Results');
end

% Save the plot as a PDF in the "Results" subfolder
pdfFilePath = ['Results/', FileName, '--auto_detected_chambers.pdf'];
% pdfFilePath = fullfile('Results', FileName, '--auto_detected_chambers.pdf');
saveas(gcf, pdfFilePath);


%%

exit
