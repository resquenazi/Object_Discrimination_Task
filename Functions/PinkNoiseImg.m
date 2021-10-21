function [pinkNoise] = PinkNoiseImg(numImgs)

% PinkNoise.m creates a 1/f noise image. 1/f noise attenuates high
% frequencies in an image in a 1/f fall off manner.

% To optimize parameters for ObjectRecognitionFourier, use the following:

% 1. alpha =1.2; (the power that 'f' in 1/f is raised to)
% 2. contrast = 2; (the contrast of the resulting 1/f noise (contrast = 0
%    results in gray image))
% 3. nPix =768; (number of pixels in the desired output

%% Initialize Variables

if  ~isfield('plot', 'var')
    plot=0;
    disp(['plot not specified, using default value of ', num2str(plot)]);
end

if  ~isfield('nPix', 'var')
    nPix=768;
    disp(['nPix not specified, using default value of ', num2str(nPix)]);
end

if  ~isfield('alpha', 'var')
    alpha=1.2;
    disp(['alpha not specified, using default value of ', num2str(alpha)]);
end

if  ~isfield('contrast', 'var')
    contrast=1.5;
    disp(['contrast not specified, using default value of ', num2str(contrast)]);
end

%% make white noise stimulus
for i = 1:numImgs
    img{i} = randn(nPix,nPix);
    %FFT of the noise stimulus
    for j = 1:length(img)
        fft_noise(j).img = complex2real2(fft2(img{1,j}));
        id{1,j} = fft_noise(j).img.sf>0;
        % attenuate the amplitudes with 1/sf^alpha
        fft_noise(j).img.amp(id{1,j}) = fft_noise(j).img.amp(id{1,j}).*(1./(fft_noise(j).img.sf(id{1,j}).^alpha));
        % create pinkNoise images
        pinkNoise(j).img = real(ifft2(real2complex2(fft_noise(j).img)));
        pinkNoise(j).img = (pinkNoise(j).img*contrast+128);
        pinkNoise(j).img = imscale(pinkNoise(j).img./255);
    end
end

%% Plot
if plot ==1
    for f = 1:length(pinkNoise)
        figure(1)
        subplot(1,2,f)
        image(uint8(255.*pinkNoise(f).img)); colormap(gray(256)), axis equal, axis tight
    end
end
end