
clear all;
clc;



%% filter parameters
fpar.nPix = 1024;
fpar.spokes =4;
fpar.freq = 13;
fpar.wDeg = 5;
fpar.clip = 1;
fpar.plot = 1;
fpar.n = 20;
fpar.rect = [1 1 768 768];
fpar.noise = 1;
fpar.radPhase = pi/2;
fpar.spokePhase = pi/4;
filterName = 'RadialCheckerboard';

% make radial checkerboard filter
[filterbank, fpar] = MakeFilter(filterName, fpar);

%% define weights to convert filtered inputs into eye inputs
eyeWeight(1).w = zeros(length(filterbank), 2); % left eye
eyeWeight(1).w(1, 1) = 1; eyeWeight(1).w(2, 2) = 1; % F * I + F' * I'
eyeWeight(2).w = zeros(length(filterbank), 2); % right eye
eyeWeight(2).w(2, 1) = 1; eyeWeight(2).w(1, 2) = 1; % F * I' + F' * I

%% parameters for FilterImage_Noise.m
% read in image and resize
origImg = imread('Scene10_SEMSYN.png');
origImg = mean(origImg,3); % take average of R, G, B matrices
%[min(img(:)), max(img(:))]
origImg = imscale(origImg./255);% scale the image between 0 and 1
%[min(img(:)), max(img(:))]
origImg = imresize(origImg,max(size(origImg))/fpar.nPix); % makes the long edge of image fill fpar.nPix
%[min(img(:)), max(img(:))]
origImg = insertImg(ones(fpar.nPix)*mean(origImg(:)), origImg); %

% filter image and noise and sum up weights.
[filtImg, eyeImg] = FilterImage(origImg, filterbank, fpar, eyeWeight);