function [filtImg, eyeImg] = FilterImage(Img, filterbank, fpar, eyeWeight)
%% Fourier the image and it's inverse

[X,Y] = meshgrid(linspace(-fpar.wDeg/2,fpar.wDeg/2,fpar.nPix+1)); %generating matrix that goes from -wDeg/2 (-2.5) to wdeg/2 (2.5) in steps of the size of "testImg" (n=1080)
X = X(1:end-1,1:end-1); %putting 0 in the center
Y = Y(1:end-1,1:end-1);
Img_Fourier = complex2real2(fft2(Img, fpar.nPix,fpar.nPix), X,Y);
ImgCR_Fourier = complex2real2(fft2(1-Img,fpar.nPix,fpar.nPix),X,Y);

%% original image, original Fourier filter

for f=1:length(filterbank)
    tmp = Img_Fourier;
    tmp.amp = [filterbank(f).filt.*tmp.amp]; % multiply in the fourier domain
    filtImg(f, 1).img = myifft2(tmp);
    
    if fpar.noise == 1
        numImgs = 2;
        nPix = fpar.nPix;
        [pinkNoise] = PinkNoiseImg(numImgs);
        Pink_Fourier(1).img = complex2real2(fft2(pinkNoise(1).img,fpar.nPix,fpar.nPix),X,Y);
        Pink_Fourier(2).img = complex2real2(fft2(pinkNoise(2).img,fpar.nPix,fpar.nPix),X,Y);
        tmp(f) = Pink_Fourier(f).img;
        tmp(f).amp = [filterbank(f).filt.*tmp(f).amp]; % multiply in the fourier domain
        filtImg(f, 2).img = myifft2(tmp(f));
    end
    
    if fpar.noise == 0
        tmp = ImgCR_Fourier;
        tmp.amp = [filterbank(f).filt.*tmp.amp]; % multiply in the fourier domain
        filtImg(f, 2).img = myifft2(tmp);
    end
end

for e = 1:2 % for each eye
    eyeImg(e).Img = zeros(size(filtImg(f, 1).img));
    for f=1:length(filterbank)
        for c = 1:2
            eyeImg(e).Img = eyeImg(e).Img + [filtImg(f,c).img .*eyeWeight(e).w(f, c)];
        end
    end
end

% just for Matlab
if fpar.plot
    
    cstr={' C orig', ' C rev'};
    estr={'LE', 'RE'};
    figure(1); set(gcf, 'Name', 'Input image and CR image')
    
    for c=1:2 % original contrast and reversed
        subplot(1, 2, c);
        if fpar.noise == 0
            if c==1
                img = Img(fpar.rect(2):fpar.rect(4), fpar.rect(1):fpar.rect(3));
            else
                img = 1-Img(fpar.rect(2):fpar.rect(4), fpar.rect(1):fpar.rect(3));
            end
        end
        if fpar.noise == 1
            if c==1
                img = Img(fpar.rect(2):fpar.rect(4), fpar.rect(1):fpar.rect(3));
            else
                img = pinkNoise(c).img(fpar.rect(2):fpar.rect(4), fpar.rect(1):fpar.rect(3));
            end
        end
        [min(img(:)), max(img(:))]
        image(uint8(255.*img)); axis equal; axis off;  colormap(gray(256));
        title(['F ', num2str(f), cstr{c}])
    end
    
    figure(2); set(gcf, 'Name', 'filtered images')
    for f=1:length(filterbank)
        for c=1:2 % original contrast and reversed
            subplot(length(filterbank),2,[[(f-1)*length(filterbank)]+c]);
            img = filtImg(f, c).img(fpar.rect(2):fpar.rect(4), fpar.rect(1):fpar.rect(3));
            image(uint8(255.*img)); axis equal; axis off;  colormap(gray(256));
            title(['F ', num2str(f), cstr{c}])
        end
    end
    figure(3); set(gcf, 'Name', 'Eye Input')
    for e = 1:2
        subplot(1, 2, e);
        img = eyeImg(e).Img(fpar.rect(2):fpar.rect(4), fpar.rect(1):fpar.rect(3));
        imagesc(img./sum(eyeWeight(e).w(:))); axis equal; axis off;  colormap(gray(256));
        title(estr{e})
    end
    figure(4); set(gcf, 'Name', 'Orig & contrast Reversed Imgs')
    for i = 1:2
        subplot(1, 2, 1);
        img = [filtImg(1,1).img + filtImg(2,1).img] ./ 2.0;
        imagesc(uint8(255.*img)); axis equal; axis off;  colormap(gray(256));
        subplot(1, 2, 2);
        img = [filtImg(2,2).img + filtImg(1,2).img];
        imagesc(uint8(255.*img)); axis equal; axis off;  colormap(gray(256));
    end
end
