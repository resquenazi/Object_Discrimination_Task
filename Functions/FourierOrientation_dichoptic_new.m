function FourierOrientation_dichoptic


%addpath(genpath('C:\Users\rebec\Desktop\MATLAB\trunk\UWToolbox'));
addpath(genpath('C:\Users\Ione Fine\Documents\Work\Science\Programming Utilities\UW_toolbox\'));
addpath(genpath('C:\Users\Ione Fine\Documents\Work\Science\Programming Utilities\Fine Utilities'));

testImg = imread('shortbusImg.jpg');
testImg = mean(testImg,3); % take average of R, G, B matrices
testImg = imscale(testImg); % scale the image between 0 and 1

figure(1); clf;
set(gcf, 'Name', 'original')
subplot(3,2,1); image(256*testImg); colormap(gray(256)); axis off; hold on; % show original greyscale image
title('original image')

%% creating the filter
wDeg = 5;  %size of image (in degrees)
nPix = size(testImg, 1);  %resolution of image (pixels);
[X,Y] = meshgrid(linspace(-wDeg/2,wDeg/2,nPix+1)); %generating matrix that goes from -wDeg/2 (-2.5) to wdeg/2 (2.5) in steps of the size of "testImg" (n=1080)
X = X(1:end-1,1:end-1); %subtracting 1 (why?)
Y = Y(1:end-1,1:end-1); %subtracting 1(why?)
orientation = -45;  %deg (counter-clockwise from vertical)
sf = 1.5; %spatial frequency (cycles/deg)
ramp = sin(orientation*pi/180)*X-cos(orientation*pi/180)*Y;
grating = sin(2*pi*sf*ramp);
plaid = (grating+flipud(grating))/2;
filter1 = plaid;

%%
orientation = 45;  %deg (counter-clockwise from vertical)
ramp = sin(orientation*pi/180)*X-cos(orientation*pi/180)*Y;
grating = sin(2*pi*sf*ramp);
plaid = (grating+flipud(grating))/2;
filter2 = plaid;

%%

% move the images into the 2D domain
F_img = complex2real2(fft2(testImg,nPix,nPix),X,Y); % normal image in the Fourier space

% back to the filters
figure(2)
subplot(1,2,1);imagesc(F_img.freq, F_img.freq, filter1); colormap(gray)
subplot(1,2,2);imagesc(F_img.freq, F_img.freq, filter2); colormap(gray)

% multiple the images and the filters in the Fourier domain
figure(3)
F_img1 = F_img;
tic
for i=1:600
    F_img = complex2real2(fft2(testImg,nPix,nPix),X,Y)
    F_img1.amp = [filter1.*F_img1.amp]; % multiply in the fourier domain
      img_1 = myifft2(F_img1);
end
    toc
    % take it back into the real world, and plot
  
    subplot(1,3,1); imagesc(img_1);axis off; axis equal
    
    % do it again with the other filter
    F_img2 = F_img;
    F_img2.amp = [filter2.*F_img2.amp];
    img_2 = myifft2(F_img2);subplot(2,2,2); imagesc(img_2);
    subplot(1,3,2); imagesc(img_2);axis off; axis equal
    % this gives you two images, each of which has been filtered in the fourier space,
    % so once again each images contains half of the fourier
    % information
    
    subplot(1, 3, 3); % if we add them we should get our original image?
    imagesc(img_1+img_2); colormap(gray); axis off; axis equal
    
    %
    % %% non-dichoptic outcomes
    % figure(4)
    % zmat = zeros(size(testImg,1), size(testImg,2), 3);
    % orig2OnD = zmat;
    % orig2OffD = zmat;
    %
    % % on and off responses
    % [orig2On, orig2Off, on_bank, off_bank, fbank] = blurBank(squeeze(testImg),100);
    % orig2OnD(:,:, 1) = (orig2On);
    % orig2OffD(:, :, 2) = (orig2Off);
    %
    % subplot(3,2,3); image(imscale(orig2OnD));  title('orig2On'); axis off
    % subplot(3,2,4); image(imscale(orig2OffD)); title('orig2Off'); axis off
    %
    % % normal and e-stim output
    % set(gcf, 'Name', 'orig2On-orig2Off and orig2On+orig2Off responses')
    % orig2NatD(:, :, 1) = orig2On;
    % orig2NatD(:, :, 2) = orig2Off;
    % orig2NatD(:, :, 3) = 0;
    % subplot(3,2,5); image(imscale(orig2NatD)); title('natural'); axis off
    %
    % orig2ElD(:, :, 1) = testImg;
    % orig2ElD(:, :, 2) = testImg;
    % orig2ElD(:, :, 3) = 0;
    % subplot(3,2,6); image(imscale(orig2ElD)); title('estim'); axis off
end

    function stim = imscale(stim)
        stim = (stim-min(stim(:)))/(max(stim(:))-min(stim(:)));
    end