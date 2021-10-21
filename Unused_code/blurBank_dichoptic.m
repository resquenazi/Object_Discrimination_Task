function blurBank_dichoptic

testImg = imread('shortbusImg.jpg');
testImg = mean(testImg,3);
subSampFac = 1;
n =  [100 , 50, 25, 10];  % filter sizes

figNum=1;
figure(figNum); clf;
set(gcf, 'Name', 'original') 
subplot(1,2,1); image(testImg); colormap(gray(256)); hold on; figNum = figNum + 1;

%% non-dichoptic outcomes
zmat = zeros(size(testImg,1), size(testImg,2), 3);
orig2On = zmat;
orig2Off = zmat;

[on, off] = blurBank(squeeze(testImg),n);
orig2On(:,:, 1) = imscale(on);
orig2Off(:, :, 2) = imscale(off);

figure(figNum); clf;
set(gcf, 'Name', 'orig2On and orig2Off responses')
subplot(1,2,1); image(orig2On); hold on
subplot(1,2,2); image(orig2Off); figNum = figNum + 1;

%% normal and e-stim output
figure(figNum); clf;
set(gcf, 'Name', 'orig2On-orig2Off and orig2On+orig2Off responses') 
orig2OnMorig2Off(:, :, 1) = orig2On(:, :, 1);
orig2OnMorig2Off(:, :, 2) = squeeze(orig2Off(:, :, 2));
orig2OnMorig2Off(:, :, 3) = 0;
subplot(1,2,1); image(orig2OnMorig2Off / 2); hold on

orig2OnPorig2Off(:, :, 1) = orig2On(:, :, 1);
orig2OnPorig2Off(:, :, 2) = 1-orig2Off(:, :, 2);
orig2OnPorig2Off(:, :, 3) = 0;
subplot(1,2,2); image(orig2OnPorig2Off / 2); figNum = figNum + 1;


%% dichoptic outcomes
L_On = zmat;L_Off = zmat; R_On = zmat; R_Off = zmat;
tI = squeeze(orig2On(:, :, 1));
%tI = testImg;
[on, off] = blurBank(1-tI, n);
L_On(:, :, 1) = imscale(on);
L_Off(:, :, 2)= imscale(off);

LOnMOff(:, :, 1) = L_On(:, :, 1);
LOnMOff(:, :, 2) = squeeze(L_Off(:, :, 2));
LOnMOff(:, :, 3) = 0;

tI=squeeze(orig2Off(:, :, 2));
%tI = testImg;
[on, off] = blurBank(tI,n);
R_On(:, :, 1) = imscale(on);
R_Off(:, :, 2) = imscale(off);

ROnMOff(:, :, 1) = R_On(:, :, 1);
ROnMOff(:, :, 2) = squeeze(R_Off(:, :, 2));
ROnMOff(:, :, 3) = 0;

figure(figNum); clf
set(gcf, 'Name', 'L/R eye dichoptic stimulation');
subplot(1,2,1); image(LOnMOff./2);
subplot(1,2,2); image(ROnMOff./2); figNum = figNum + 1;

figure(figNum); clf
set(gcf, 'Name', 'dichoptic stimulation');
subplot(1, 2,1);image(LOnMOff./2+ROnMOff./2)

function stim = imscale(stim)
stim = (stim-min(stim(:)))/(max(stim(:))-min(stim(:)));



    