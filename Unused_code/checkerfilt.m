testImg = imread('shortbusImg.jpg');

figure(1); 
wDeg = 5;  %size of image (in degrees)
nPix = size(testImg, 1);  %resolution of image (pixels);
[X,Y] = meshgrid(linspace(-wDeg/2,wDeg/2,nPix+1)); %generating matrix that goes from -wDeg/2 (-2.5) to wdeg/2 (2.5) in steps of the size of "testImg" (n=1080)
X = X(1:end-1,1:end-1); %subtracting 1 (why?)
Y = Y(1:end-1,1:end-1); %subtracting 1(why?)
sigma = .01;  %width of Gaussian (1/e half-width)
orientation = -45;  %deg (counter-clockwise from vertical)
sf = 1.5; %spatial frequency (cycles/deg)


ramp = sin(orientation*pi/180)*X-cos(orientation*pi/180)*Y;
grating = sin(2*pi*sf*ramp);
plaid = (grating+flipud(grating))/2;
filter1 = plaid;
showImage(filter1,X,Y);
return
%%

figure(2)
wDeg = 5;  %size of image (in degrees)
nPix = size(testImg, 1);  %resolution of image (pixels);
[X,Y] = meshgrid(linspace(-wDeg/2,wDeg/2,nPix+1)); %generating matrix that goes from -wDeg/2 (-2.5) to wdeg/2 (2.5) in steps of the size of "testImg" (n=1080)
X = X(1:end-1,1:end-1); %subtracting 1 (why?)
Y = Y(1:end-1,1:end-1); %subtracting 1(why?)
sigma = .01;  %width of Gaussian (1/e half-width)
orientation = 45;  %deg (counter-clockwise from vertical)
sf = 1.5; %spatial frequency (cycles/deg)

ramp = sin(orientation*pi/180)*X-cos(orientation*pi/180)*Y;
grating = sin(2*pi*sf*ramp);
plaid = (grating+flipud(grating))/2;
filter2 = plaid;
showImage(filter2,X,Y);

subplot(1,2,1);showImage(filter1,X,Y);
subplot(1,2,2);showImage(filter2,X,Y);