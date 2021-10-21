%% makescenefiles
%cd('C:\Users\Ione Fine\Documents\code\dichoptic_gaming\')
homeDr = pwd;
objectDr = [homeDr  filesep 'Training_Objects'];
saveDr = [homeDr  filesep 'training_masks'];

%% parameters

cd(objectDr);
oList = dir;

for o = 3:length(oList)
    cd(objectDr);
    o_img = imread(oList(o).name);
    goodPix = sum(o_img, 3);
    whiteBg = mode(goodPix(:));
    goodPix(goodPix~=whiteBg) = 255;
    goodPix(goodPix==whiteBg) = 0;


mask(:, :, 1) = goodPix;
mask(:, :, 2) = goodPix;
mask(:, :, 3) = goodPix;
cd(saveDr)
filename = [oList(o).name(1:end-4), '_mask.png'];
imagesc(goodPix); drawnow; 
imwrite(mask, filename)
end


