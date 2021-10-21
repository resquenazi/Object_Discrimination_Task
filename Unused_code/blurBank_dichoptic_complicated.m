function blurBank_dichoptic_complicated

%addpath(genpath('C:\Users\Ione Fine\Documents\Work\Science\Programming Utilities\Fine Utilities'))
%rmpath(genpath('C:\Users\Ione Fine\Documents\Work\Science\Programming Utilities\UWtoolbox'));

testImg = imread('shortbusImg.jpg'); % read image
testImg = mean(testImg,3); % take average of R, G, B matrices
testImg = imscale(testImg); % scale the image between 0 and 1
subSampFac = 1;

n = [110]; %, 75,100,10];  % filter sizes, small sizes mean sharper filter

figure(1); clf;
set(gcf, 'Name', 'original')
subplot(1,2,1); image(256*testImg); colormap(gray(256)); axis off; hold on; % show original greyscale image
title('original image')
subplot(1,2,2); image(256-256*testImg); colormap(gray(256)); axis off; hold on; % show inverted greyscale image
title('original image')
axis off
%return 
%% non-dichoptic outcomes
zmat = zeros(size(testImg,1), size(testImg,2), 3); 
% size(x, 1) gives you number of rows, size(x, 2) gives you number of columns
orig2OnD = zmat;
orig2OffD = zmat;

% get the filtered images for on and off
[orig2On, orig2Off, on_bank, off_bank, fbank] = blurBank(squeeze(testImg),n);

% For display purposes..
% put the filtered "on" image into the "red" plane of the orig2OnD matrix
orig2OnD(:,:, 1) = (orig2On);
% put the filtered "off" image into the "green" plane of the orig2OffD matrix
orig2OffD(:, :, 2) = (orig2Off);

% This uses "image" to put them up in red/green
subplot(3,2,3); image(imscale(orig2OnD));  title('orig2On'); axis off
subplot(3,2,4); image(imscale(orig2OffD)); title('orig2Off'); axis off

% This uses "imshow" to put them up in greyscale
subplot(3,2,3); imshow(imscale(orig2On));  title('orig2On'); axis off
subplot(3,2,4); imshow(imscale(orig2Off)); title('orig2Off'); axis off


% normal and e-stim output

% plot normal vision off and on responses
set(gcf, 'Name', 'orig2On-orig2Off and orig2On+orig2Off responses')
orig2NatD(:, :, 1) = orig2On;
orig2NatD(:, :, 2) = orig2Off;
orig2NatD(:, :, 3) = 0;
subplot(3,2,5); image(imscale(orig2NatD)); title('natural'); axis off

orig2ElD(:, :, 1) = testImg;
orig2ElD(:, :, 2) = testImg;
orig2ElD(:, :, 3) = 0;
subplot(3,2,6); image(imscale(orig2ElD)); title('estim'); axis off

%% dichoptic outcomes

for fb=1; %:length(fbank)
    figure(fb+1); title(['Dichoptic blur filter ', num2str(n(fb))]);
    [deconv(fb).img] = deconvwnr(testImg,fbank(1).filt, 0);
    tI_L(fb).img = [deconv(fb).img];
    tI_R(fb).img = [1-deconv(fb).img];
    subplot(1,2,1); image(256 * imscale(tI_L(fb).img)); colormap(gray(256)); axis off
    subplot(1,2,2); image(256 * imscale(tI_R(fb).img)); colormap(gray(256)); axis off
%return
    % for looking at with red green glasses
    figure(fb+10); set(gcf, 'Name', 'dichoptic'); 
    tmp(:, :, 1)=(256 * imscale(tI_L(fb).img));
    tmp(:, :, 2)=(256 * imscale(tI_R(fb).img));
    tmp(:, :, 3)=0;

    % double check this isn't crazy
    figure(fb+1);
    [on_L, off_L] = blurBank(tI_L(fb).img, n);  % left
    L_OnOffD(fb).img(:, :, 1) = on_L;
    L_OnOffD(fb).img(:, :, 2) = off_L;
    L_OnOffD(fb).img(:, :, 3) = 0;
    subplot(3,2,3); image((10*L_OnOffD(fb).img)); title('left eye'); axis off; colormap(gray(256))
    
    % right
    [on_R, off_R] = blurBank(tI_R(fb).img, n);
    R_OnOffD(fb).img(:, :, 1) = on_R;
    R_OnOffD(fb).img(:, :, 2) = off_R;
    R_OnOffD(fb).img(:, :, 3) = 0; 
    subplot(3,2,4); image((10*R_OnOffD(fb).img)); title('right eye'); colormap(gray(256)); axis off;
    
    % combined dichoptic image
    Dich_both = R_OnOffD(fb).img + L_OnOffD(fb).img;
    subplot(3,2,5); image(Dich_both); title('hoth eyes'); colormap(gray(256)); axis off
    disp('done');
    
end

