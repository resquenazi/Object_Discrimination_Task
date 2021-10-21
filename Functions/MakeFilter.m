function [filterbank, fpar] = MakeFilter(filterName, fpar)

if ~exist('fpar', 'var')
    fpar = struct();
end

if  ~isfield(fpar, 'spokes')
    fpar.spokes=4;
    disp(['fpar.spokes not specified, using default value of ', num2str(fpar.spokes)]);
end

if  ~isfield(fpar, 'n')
    fpar.n=20;
    disp(['radial scaling n not specified, using default value of ', num2str(fpar.n)]);
end

if ~isfield(fpar, 'freq')
    fpar.freq=13; % number of cycles per degree
    disp(['fpar.freq not specified, using default value of ', num2str(fpar.freq)]);
    
end
if ~isfield(fpar, 'wDeg')
    fpar.wDeg = 5;
    disp(['fpar.wDeg not specified, using default value of ', num2str(fpar.wDeg)]);
end

if ~isfield(fpar, 'clip')
    fpar.clip = 0; % 1  - binarization; 2  - rectification
    disp(['fpar.clip not specified, using default value of ', num2str(fpar.clip)]);
    
end
if ~isfield(fpar, 'plot')
    fpar.plot = 1;
    disp(['fpar.plot not specified, using default value of ', num2str(fpar.plot)]);
end

if ~isfield(fpar, 'nPix')
    fpar.nPix = 768;
    disp(['fpar.nPix not specified, using default values of ', num2str(fpar.nPix)]);
end

if ~isfield(fpar, 'rect')
    fpar.rect = [1 1 fpar.nPix fpar.nPix];
    disp(['fpar.rect not specified, using default values of ', num2str(fpar.rect)]);
end

if ~isfield(fpar, 'noise')
    fpar.noise = 0;
    disp(['fpar.noise not specified, using default values of ', num2str(fpar.noise)]);
end

if  ~isfield(fpar, 'spokePhase')
    fpar.spokePhase=pi/4;
    disp(['spokePhase n not specified, using default value of ', num2str(fpar.spokePhase)]);
end

if  ~isfield(fpar, 'radPhase')
    fpar.radPhase=pi/2;
    disp(['radPhase n not specified, using default value of ', num2str(fpar.radPhase)]);
end

[X,Y] = meshgrid(linspace(-fpar.wDeg/2,fpar.wDeg/2,fpar.nPix+1)); %generating matrix that goes from -wDeg/2 (-2.5) to wdeg/2 (2.5) in steps of the size of "testImg" (n=1080)
X = X(1:end-1,1:end-1); %putting 0 in the center
Y = Y(1:end-1,1:end-1);

%% this stufilterbank can be an input variable
[THETA,RAD] = cart2pol(X,Y); % going from cartesian to polar coordinates

if strcmp(filterName, 'None')
    FILT = ones(size(RAD));
    FILT_INV= ones(size(RAD));
elseif strcmp(filterName, 'RadialCheckerboard')
    RAD = fpar.wDeg./(fpar.wDeg.^(1./fpar.n)).*((RAD+.25).^(1/fpar.n));
    F_RAD=sin(RAD*fpar.freq.*2*pi-fpar.radPhase); %  concentric ring filter
    F_SPOKES=sin(THETA*fpar.spokes-fpar.spokePhase); % wedgy filter
    FILT=F_RAD.*F_SPOKES; % radial checkerboard
    FILT_INV=-FILT; % radial checkerboard
elseif strcmp(filterName, 'Checkerboard')
    F_X = sin(.5*2*pi*((X)));
    F_Y = sin(.5*2*pi*((Y)));
    FILT = F_X.*F_Y;
    FILT_INV=-FILT; %  checkerboard
else
    errordlg('fiterName not recognized');
end
if fpar.clip == 1 % binarize
    FILT=FILT>=0;
    FILT_INV=FILT_INV>=0;
elseif fpar.clip == 2 % rectification
    FILT(FILT<0) = 0;
    FILT_INV(FILT_INV<0) = 0;
else
    FILT = (FILT+1)./2;
    FILT_INV = (FILT_INV+1)./2;
end

filterbank(1).filt = FILT;
filterbank(2).filt = FILT_INV;

if fpar.plot
    figure(1)
    for f = 1:length(filterbank)
        subplot(1, length(filterbank), f);
        image(uint8(255.*filterbank(f).filt)); axis equal; drawnow
        axis off; colormap(gray(256));
        title(['F ', num2str(f)])
    end
end

