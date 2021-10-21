%function CreateFilteredVideo(videoFile, filterName, fpar, durTime)
%
% Takes a video and filters it in a crazy way
%
% takes as input:
% name of the videofile
% name of the filter to use
% fpar which parameterizes the filter
% durTime - how much of the video to read (if not specified, does the whole
% thing)
% written IF, RE and KM 3/2019

% durTime = 20;

fpar.nPix = NaN;
fpar.spokes =4;
fpar.freq = 13;
fpar.wDeg = 5;
fpar.clip = 1;
fpar.plot = 1;
fpar.n = 20;
fpar.rect = [1 1 1024 1024];
fpar.noise = 0;
fpar.radPhase = pi/2;
fpar.spokePhase = pi/4;
filterName = 'RadialCheckerboard';

% fpar.nPix = NaN; % KM set it so that this information is calculated once the video image is read in.
% fpar.spokes = 4;
% fpar.freq = 13;
% fpar.wDeg = 5;
% fpar.clip = 1;
% fpar.plot = 0;
% fpar.n = 20;
% fpar.noise = 0;
% fpar.radPhase = pi/2;
% fpar.spokePhase = pi/4;
fpar.pad = 3;

% filterName = 'RadialCheckerboard';

%% open input videofile
if ~exist('videoFile') %#ok<*EXIST>
    videoFile = 'gameplay.mp4';
end
v = VideoReader(videoFile);

% v is a "VideoReader" object. Here's what an example looks like:
%
% v = 
% 
%   VideoReader with properties:
% 
%    General Properties:
%             Name: 'gameplay.mp4'
%             Path: '/home/viscog/GitHub/dichoptic_gaming'
%         Duration: 195.3483
%      CurrentTime: 0
%              Tag: ''
%         UserData: []
% 
%    Video Properties:
%            Width: 640
%           Height: 360
%        FrameRate: 29.9700
%     BitsPerPixel: 24
%      VideoFormat: 'RGB24'

%% open output videofiles

% if user does not specify a duration, use the full clip duration
if ~exist('durTime')
    durTime = v.Duration;
end

% Generate left-eye and right-eye video files
eyeL = VideoWriter([videoFile(1:end-4), '_left', '.avi']);
eyeR = VideoWriter([videoFile(1:end-4), '_right', '.avi']);
open(eyeL);
open(eyeR);

%% read in each image frame of the video

disp(['Reading in frames from ' videoFile '...'])
i=1;

while v.CurrentTime < durTime
    % v.CurrentTime is the current position in the video
    
    % read in the next video frame:
    mov(i).cdata = readFrame(v); % every time you readFrame(v), it advances v.CurrentTime to the next frame
    
    % mov is a structure with the field cdata
    % readFrame(v) imports image frames as a 3D variable (for example,
    % [360×640×3 uint8] if the video is 360x640), and we need to put this into greyscale
    
    mov(i).cdata = mean(mov(i).cdata,3); % take average of R, G, B matrices to put into greyscale
    
    % now cdata is only 2D and it has also been turned into a double (e.g. [360×640 double])
    % However, the values range from 0 to 255, and we need to rescale it between 0 and 1
    mov(i).cdata = imscale(mov(i).cdata./255);% scale the image between 0 and 1
    %mov(i).cdata = mov(i).cdata(1:fpar.nPix, 1:fpar.nPix); % scale the image between 0 and 1
    i = i+1;
end

% when this is done, all the video frames have been read in.
% mov is now a 1x(number of frames) struct array with the field cdata.

disp(['..done! ' num2str(length(mov)) ' total frames were imported'])

% We want a square image, so we are going to take the "long" side of the
% video image (expected to be the horizontal dim but generalized here in
% case someone tries something wacky)

fpar.nPix = max(size(mov(1).cdata));

% origImg = imresize(origImg,max(size(origImg))/fpar.nPix); % makes the long edge of image fill fpar.nPix
% origImg = insertImg(ones(fpar.nPix)*mean(origImg(:)), origImg); %
% 
% 
% padimg = zeros(size(mov(1).cdata, 1).*fpar.pad, size(mov(1).cdata, 2).*fpar.pad);
% fpar.nPix = size(padimg, 1);
% [tmp, rect] = insertImg(padimg, mov(1).cdata(:, :, 1));
% fpar.rect = rect;
% 
[filterbank, fpar] = MakeFilter(filterName, fpar);

%% define weights to convert filtered inputs into eye inputs
% first dim represents the filter, the second represents whether the image
% is the original contrast, or reversed
eyeWeight(1).w = zeros(length(filterbank), 2); % left eye
eyeWeight(1).w(1, 1) = 1; eyeWeight(1).w(2, 2) = 1; % F * I + F' * I'
eyeWeight(2).w = zeros(length(filterbank), 2); % right eye
eyeWeight(2).w(2, 1) = 1; eyeWeight(2).w(1, 2) = 1; % F * I' + F' * I

%% Filter and write images

disp('Filtering frames..')
disp(datestr(now)); tic;
for i=1:length(mov)
    if mod(i, 10)==0
        disp(['..converting frame ', num2str(i) ' of ' num2str(length(mov))]);
    end
    [img, rect] =  insertImg(ones(fpar.nPix)*mean(mov(i).cdata(:)), mov(i).cdata);
    [filtImg, eyeImg] = FilterImage(img,filterbank, fpar, eyeWeight);
    for e=1:2
        writeVideo(eyeL,uint8(round(Scale(eyeImg(1).Img)*255, 0)));
        writeVideo(eyeR,uint8(round(Scale(eyeImg(2).Img)*255, 0)));
    end
end
close(eyeL);
close(eyeR);
disp(datestr(now))
toc
