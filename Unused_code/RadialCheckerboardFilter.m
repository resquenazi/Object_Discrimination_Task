function [img_1,img_2] = FilterImage(testImg, filterName, f)
% 

if ~isfield(f, 'spokes')
    f.spokes=6;
    disp(['f.spokes not specified, using default value of ', num2str(f.spokes)])
end
if ~isfield(f, 'sigma')
    sigma=1000;
    disp(['f.sigma not specified, using default value of ', num2str(f.sigma)])
if ~isfield(f, 'wDeg')
    wDeg = 5;
    disp(['f.wDeg not specified, using default value of ', num2str(f.wDeg)])
end

nPix = size(testImg, 1);

[X,Y] = meshgrid(linspace(-wDeg/2,wDeg/2,nPix+1)); %generating matrix that goes from -wDeg/2 (-2.5) to wdeg/2 (2.5) in steps of the size of "testImg" (n=1080)
X = X(1:end-1,1:end-1); %putting 0 in the center
Y = Y(1:end-1,1:end-1); 

[THETA,r] = cart2pol(X,Y); % going from cartesian to polar coordinates
r=(r./(nPix/2))*pi;

f=sin(r*sigma);         % 1st concentric filter
f1=sin(THETA*spokes);   % 1st radial filter
%f1=f1>=0;              % binarize
f11=f.*f1;              % point-wise multiply
f=sin(r*sigma+pi);      % 2nd concentric filter shifted by pi
f1=sin(THETA*spokes+pi);% 2nd radial filter shifted by pi
%f1=f1>=0;              % binarize
f12 = f.*f1;            % point-wise multiply
f=(f11+f12)>=0;         % add the two filters and threshold
%f_inv=(f11+f12)<=0;    % add the two filters and threshold
f = f11+f12;            % filter 1
f_inv = 1 - f;          % inverse filter
%centerDot = nPix/2;
%f(centerDot,centerDot)=0.5;
%f_inv(centerDot, centerDot)=0.5;
figure(1)
subplot (1,2,1), imagesc((f)), colormap gray;           %comment if running "CreateFilteredVideo.m"
subplot (1,2,2), imagesc(f_inv), colormap gray;

F_img = complex2real2(fft2(testImg,nPix,nPix),X,Y);
F_img1 = F_img
F_img1.amp = [f.*F_img1.amp]; % multiply in the fourier domain
img_1 = myifft2(F_img1);
      
F_img2 = F_img;
F_img2.amp = [f_inv.*F_img2.amp];
img_2 = myifft2(F_img2);
 
figure, imagesc(img_1), colormap gray;                          %comment if running "CreateFilteredVideo.m"
figure, imagesc(img_2), colormap gray;                          %comment if running "CreateFilteredVideo.m"
end