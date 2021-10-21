
function Y = plotFFT2(img,x,y,k,sfRange)
%plotFFT2(img,x,y,k,sfRange)


if ~exist('x','var') || ~exist('y','var')
    x = [];
 y = [];

end

if isempty(x) || isempty(y)
        [x,y] = meshgrid(1:size(img,1));
end

nPix = size(x,1);

if ~exist('k','var')
    k = 1;
end

if ~exist('sfRange','var')
    wDeg =(max(x(1,:))-min(x(1,:)))*(nPix+1)/nPix;
    sfRange = nPix/(2*wDeg);
end

Y = complex2real2(fft2(img,k*nPix,k*nPix),x,y);

clf
subplot(1,2,1)
imagesc(x(1,:),y(:,1),img);
axis square;
colormap(gray(256));
xlabel('x')
ylabel('y');

subplot(1,2,2)
amp = 255*Y.amp/max(Y.amp(:));
image(Y.freq,Y.freq,amp);
axis square;
colormap(gray(256));
set(gca,'XLim',[-sfRange,sfRange]);
set(gca,'YLim',[-sfRange,sfRange]);
xlabel('w_x')
ylabel('w_y')
set(gca,'YDir','normal');
set(gcf,'PaperPosition',[.5,.5,2,4]);

end