% this script allows you to load images that call filterImage and save
% dichoptic images to use later

%creating filter parameters

imageDr = [homeDr  filesep 'sceneswobjects'];
saveDr = [homeDr  filesep 'sceneswobjectsFiltered'];
fpar.nPix = 1024;
fpar.spokes = 11;
fpar.freq = 3;
fpar.wDeg = 5;
fpar.clip = 0;
fpar.plot = 0;
filterName = 'RadialCheckerboard';

%% define weights to convert filtered inputs into eye inputs
% first dim represents the filter, the second represents whether the image
% is the original contrast, or reversed
[filterbank, fpar] = MakeFilter(filterName, fpar);
eyeWeight(1).w = zeros(length(filterbank), 2); % left eye
eyeWeight(1).w(1, 1) = 1; eyeWeight(1).w(2, 2) = 1; % F * I + F' * I'
eyeWeight(2).w = zeros(length(filterbank), 2); % right eye
eyeWeight(2).w(2, 1) = 1; eyeWeight(2).w(1, 2) = 1; % F * I' + F' * I

cd(imageDr)
fileNames = dir;
for i=3:length(fileNames)
    cd(imageDr)
    origImg = imread(fileNames(i).name);
    % MB It's better to use rgb2gray, it weighs the channels differently
    origImg = mean(origImg,3); % take average of R, G, B matrices
    origImg = imscale(origImg./255);% scale the image between 0 and 1
    origImg = imresize(origImg,max(size(origImg))/fpar.nPix); % makes the long edge of image fill fpar.nPix
    origImg = insertImg(ones(fpar.nPix)*mean(origImg(:)), origImg); % fills the short size of the image with padding
    [filtImg, eyeImg] = FilterImage(origImg,filterbank, fpar, eyeWeight);
    cd(saveDr)
   imwrite(uint8(round(Scale(origImg)*255, 0)), strrep(filename{i}, '.png', '-original.png'))
   imwrite(uint8(round(Scale(eyeImg(1).Img)*255, 0)), strrep(filename{i}, '.png', '-L.png'))
   imwrite(uint8(round(Scale(eyeImg(2).Img)*255, 0)), strrep(filename{i}, '.png', '-R.png'))
end