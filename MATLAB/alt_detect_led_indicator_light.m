% add our MATLAB code to path if its not there already
check = which('AutoTracking');
if isempty(check)
    parentdir = fileparts(mfilename('fullpath'));
    addpath(genpath(parentdir));
end



videoFileName = [OutputDirectory, '/', FileName, '/', FileName, '--indicator_led.mp4'];        % Specify the video file name
videoReader = VideoReader(videoFileName);                                  % Create a VideoReader object
numFrames = videoReader.NumberOfFrames;                                    % Get video properties
brightnessThreshold = 254;                                                 % Threshold for detecting bright pixels
ledState = zeros(numFrames, 1);                                            % Initialize an array to store LED state for each frame

% Initialize variables to store indices with lowest and highest sums
lowestSumIndex = 0;
highestSumIndex = 0;
lowestSum = Inf;
highestSum = -Inf;

NumberOfPixels = str2num(NumberOfPixels);

% % Specify the region of interest (ROI) where the LED light is expected
% roiRect = [1, 1, NumberOfPixels, NumberOfPixels]; % [x, y, width, height]


%% 

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
        % roi = gpuArray(imcrop(grayFrame, roiRect));
        binaryMask = grayFrame > brightnessThreshold;
        ledSum(frameIndex) = sum(gather(binaryMask(:)), "all");
    else
        grayFrame = rgb2gray(currentFrame);
        % roi = imcrop(grayFrame, roiRect);
        binaryMask = grayFrame > brightnessThreshold;
        ledSum(frameIndex) = sum(binaryMask(:), "all");
    end
    % ledState(frameIndex) = ledSum(frameIndex) > minBrightPixels;
    

    % Check if this sum is the lowest or highest encountered so far
    if ledSum(frameIndex) < lowestSum
        lowestSum = ledSum(frameIndex);
        lowestSumIndex = frameIndex;
        lowestMask = binaryMask;
        lowestFrame = grayFrame;
    end
    
    if ledSum(frameIndex) > highestSum
        highestSum = ledSum(frameIndex);
        highestSumIndex = frameIndex;
        highestMask = binaryMask;
        highestFrame = grayFrame;
    end
end


%% 

% Use K-means clustering to determine the theshold between LED on and off
[idx, centroids] = kmeans(ledSum', 2);                                     % Perform K-means clustering
minBrightPixels = mean(centroids);                                         % Calculate the midpoint between centroids
ledState = ledSum > minBrightPixels;                                       % Binarize the ledSum array

%% 

% Plot images of matrices with lowestSumIndex and highestSumIndex
figure('Units', 'centimeters', 'Position', [0, 0, 21.0, 29.7], 'PaperSize', [21.0, 29.7], 'PaperPosition', [0, 0, 21.0, 29.7]);

% Plot image of matrix with lowest sum
subplot(4, 2, 1);
image(lowestFrame);
colormap(gray);
xlim([0, NumberOfPixels]);
ylim([0, NumberOfPixels]);
axis equal; % Fix aspect ratio
title(sprintf('Frame with Lowest Sum\n(Frame: %d, Sum: %d)', lowestSumIndex, lowestSum));

subplot(4, 2, 3);
imagesc(lowestMask);
colormap(gray);
xlim([0, NumberOfPixels]);
ylim([0, NumberOfPixels]);
axis equal; % Fix aspect ratio
title(sprintf('Binarized Frame with Lowest Sum\n(Threshold: >%d)', brightnessThreshold));


% Plot image of matrix with highest sum
subplot(4, 2, 2);
image(highestFrame);
colormap(gray);
xlim([0, NumberOfPixels]);
ylim([0, NumberOfPixels]);
axis equal; % Fix aspect ratio
title(sprintf('Frame with Highest Sum\n(Frame: %d, Sum: %d)', highestSumIndex, highestSum));

subplot(4, 2, 4);
imagesc(highestMask);
colormap(gray);
xlim([0, NumberOfPixels]);
ylim([0, NumberOfPixels]);
axis equal; % Fix aspect ratio
title(sprintf('Binarized Frame with Highest Sum\n(Threshold: >%d)', brightnessThreshold));


% Plot line graph of ledSum
subplot(4, 2, [5, 6]);
plot(ledSum);
ylim([-400, max(highestSum * 1.2, 10000)]); 
minBrightPixelsLine = refline(0, minBrightPixels);
minBrightPixelsLine.Color = 'r';
minBrightPixelsLine.LineStyle = '--';
text(numFrames, minBrightPixels * 1.6, ['Min Bright Pixels: ' num2str(minBrightPixels)], 'Color', 'r', 'HorizontalAlignment', 'right');
xlabel('Frame');
ylabel('ledSum');
title('Line Graph of ledSum');

% Plot line graph of ledState
subplot(4, 2, [7, 8]);
plot(ledState);
ylim([-0.2, 1.2]); 
xlabel('Frame');
ylabel('ledState');
title('Line Graph of ledState');


% Add an overall title at the top of the page
sgtitle(FileName);



%% 

% Create the "Results" subfolder if it doesn't exist
if ~exist([OutputDirectory, '/', FileName, '/Results/'], 'dir')
    mkdir([OutputDirectory, '/', FileName, '/Results/']);
end

% Save the plot as a PDF in the "Results" subfolder
pdfFilePath = [OutputDirectory, '/', FileName, '/Results/', FileName, '--led_indicator_plots.pdf'];
saveas(gcf, pdfFilePath);
disp(['LED plots saved to ' pdfFilePath]);


% Write LED state to CSV file
csvFileName = [OutputDirectory, '/', FileName, '/Results/', FileName, '--led_state.csv'];
csvwrite(csvFileName, ledState);
disp(['LED state saved to ' csvFileName]);



%%

% Release the GPU resources
if useGPU
    reset(gpuDevice);
end

%% 

exit
