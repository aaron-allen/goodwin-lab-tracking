
% add our MATLAB code to path if its not there already
check = which('AutoTracking');
if isempty(check)
    parentdir = fileparts(mfilename('fullpath'));
    addpath(genpath(parentdir));
end


% The variable "OutputDirectory" and "FileName" are passed to the script when running from bash
% Do I need to change directory?
cd ([OutputDirectory '/' FileName]);


% Specify the video file name
videoFileName = [FileName '--indicator_led.mp4'];

% Create a VideoReader object
videoReader = VideoReader(videoFileName);

% Get video properties
numFrames = videoReader.NumberOfFrames;

% Specify the region of interest (ROI) where the LED light is expected
roiRect = [1, 1, NumberOfPixels, NumberOfPixels]; % [x, y, width, height]

% Threshold for detecting bright pixels
brightnessThreshold = 200;

% Use GPU if available
useGPU = true;

% Initialize an array to store LED state for each frame
ledState = zeros(numFrames, 1);

% Process each frame
for frameIndex = 1:numFrames
    % Read the current frame
    currentFrame = read(videoReader, frameIndex);

    % 1. Convert the frame to grayscale on GPU if available
    % 2. Extract the ROI on GPU if available
    % 3. Threshold the ROI to find bright pixels on GPU if available
    % 4. Set LED state for the current frame
    if useGPU
        grayFrame = gpuArray(rgb2gray(currentFrame));
        roi = gpuArray(imcrop(grayFrame, roiRect));
        binaryMask = roi > brightnessThreshold;
        ledState(frameIndex) = any(gather(binaryMask(:)));
    else
        grayFrame = rgb2gray(currentFrame);
        roi = imcrop(grayFrame, roiRect);
        binaryMask = roi > brightnessThreshold;
        ledState(frameIndex) = any(binaryMask(:));
    end
end

% Release the GPU resources
if useGPU
    reset(gpuDevice);
end

% Write LED state to CSV file
csvFileName = [FileName '--led_state.csv']
csvwrite(csvFileName, ledState);
disp(['LED state saved to ' csvFileName]);



exit
