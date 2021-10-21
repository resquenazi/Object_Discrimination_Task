origImg = imread('Scene10_pot.png');

fpar.nPix = 768;
fpar.spokes =4;
fpar.freq = 13;
fpar.wDeg = 5;
fpar.clip = 1;
fpar.plot = 0;
fpar.n = 20;
fpar.rect = [1 1 768 768];
fpar.noise = 0;
fpar.radPhase = pi/2;
fpar.spokePhase = pi/4;
fpar.filterName = 'RadialCheckerboard';

%% Plot binarized and blurred filters and images side by side

% create binarized filters
[filterbankClip, fpar] = MakeFilter(fpar.filterName, fpar);
eyeWeight(1).w = zeros(length(filterbankClip), 2); % left eye
eyeWeight(1).w(1, 1) = 1; eyeWeight(1).w(2, 2) = 1; % F * I + F' * I'
eyeWeight(2).w = zeros(length(filterbankClip), 2); % right eye
eyeWeight(2).w(2, 1) = 1; eyeWeight(2).w(1, 2) = 1; % F * I' + F' * I

%filter image with binarized filters
origImg = mean(origImg,3); % take average of R, G, B matrices
origImg = imscale(origImg./255);% scale the image between 0 and 1
origImg = imresize(origImg,max(size(origImg))/fpar.nPix); % makes the long edge of image fill fpar.nPix
origImg = insertImg(ones(fpar.nPix)*mean(origImg(:)), origImg); % fills the short size of the image with padding
[filtImgClip, eyeImgClip] = FilterImage(origImg,filterbankClip, fpar, eyeWeight);

imwrite(uint8(round(Scale(eyeImgClip(1).Img)*255, 0)),'clock_L_clip.png');
imwrite(uint8(round(Scale(eyeImgClip(2).Img)*255, 0)),'clock_R_clip.png');


% create blurred filters
fpar.clip = 0;
[filterbankBlur, fpar] = MakeFilter(fpar.filterName, fpar);
eyeWeight(1).w = zeros(length(filterbankBlur), 2); % left eye
eyeWeight(1).w(1, 1) = 1; eyeWeight(1).w(2, 2) = 1; % F * I + F' * I'
eyeWeight(2).w = zeros(length(filterbankBlur), 2); % right eye
eyeWeight(2).w(2, 1) = 1; eyeWeight(2).w(1, 2) = 1; % F * I' + F' * I

%filter image with blurred filters
origImg = mean(origImg,3); % take average of R, G, B matrices
origImg = imscale(origImg./255);% scale the image between 0 and 1
origImg = imresize(origImg,max(size(origImg))/fpar.nPix); % makes the long edge of image fill fpar.nPix
origImg = insertImg(ones(fpar.nPix)*mean(origImg(:)), origImg); % fills the short size of the image with padding
[filtImgBlur, eyeImgBlur] = FilterImage(origImg,filterbankBlur, fpar, eyeWeight);

imwrite(uint8(round(Scale(eyeImgBlur(1).Img)*255, 0)),'clock_L_blur.png');
imwrite(uint8(round(Scale(eyeImgBlur(2).Img)*255, 0)),'clock_R_blur.png');


% plot
subplot(2,2,1)
imagesc(filterbankBlur(1).filt); colormap gray
title('Blurred', 'FontSize', 16, 'FontName', 'Arial');
axis off;

subplot(2,2,2)
imagesc(filterbankClip(1).filt); colormap gray
title('Binarized', 'FontSize', 16, 'FontName', 'Arial');
axis off;

subplot(2,2,3)
imagesc(eyeImgBlur(1).Img); colormap gray
axis off;

subplot(2,2,4)
imagesc(eyeImgClip(1).Img); colormap gray
axis off;

%% Subtract binarized and non binarized images 
imgDiff = abs(eyeImgClip(1).Img - eyeImgBlur(1).Img);
imgDiff = imgDiff*2.8;
imagesc(imgDiff); colormap gray; axis off
title('Difference Between Binarized and Blur Filtered Images', 'FontSize', 16, 'FontName', 'Arial');

%% Supplementary figure 1

imagesc(origImg); colormap gray; title('Unfiltered Image', 'FontSize', 16, 'FontName', 'Arial'); 
axis off;

subplot(1,2,1)
imagesc(eyeImgClip(1).Img); colormap gray; title('Left Eye', 'FontSize', 16, 'FontName', 'Arial'); 
axis off;
subplot(1,2,2)
imagesc(eyeImgClip(2).Img); colormap gray; title('Right Eye', 'FontSize', 16, 'FontName', 'Arial'); 
axis off;

%%
a = imfuse(origImg, imgDiff);