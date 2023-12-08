% Specify the video file name
videoFileName = 'your_video.mp4';

% Create a VideoReader object
videoReader = VideoReader(videoFileName);

% Get video properties
numFrames = videoReader.NumberOfFrames;

% Specify the region of interest (ROI) where the LED light is expected
roiRect = [1, 1, 50, 50]; % [x, y, width, height]

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

    % Convert the frame to grayscale on GPU if available
    if useGPU
        grayFrame = gpuArray(rgb2gray(currentFrame));
    else
        grayFrame = rgb2gray(currentFrame);
    end

    % Extract the ROI on GPU if available
    if useGPU
        roi = gpuArray(imcrop(grayFrame, roiRect));
    else
        roi = imcrop(grayFrame, roiRect);
    end

    % Threshold the ROI to find bright pixels on GPU if available
    binaryMask = roi > brightnessThreshold;

    % Set LED state for the current frame
    ledState(frameIndex) = any(binaryMask(:));
end

% Release the GPU resources
if useGPU
    reset(gpuDevice);
end

% Write LED state to CSV file
csvFileName = 'led_state.csv';
csvwrite(csvFileName, ledState);
disp(['LED state saved to ' csvFileName]);
