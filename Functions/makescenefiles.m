%% MakeSceneFiles
% this code generates stimuli for ObjectRecognitionFourierwDrift task

cd('/home/viscog/GitHub/dichoptic_gaming')
homeDr = pwd;
objectDr = [homeDr  filesep 'goodObjectsTraining'];
maskDr = [homeDr  filesep 'goodMasksTraining'];
sceneDr = [homeDr  filesep 'scenes_object_absent'];
saveDr_A = [homeDr  filesep 'filtered_scenes_objects_absent_training'];
saveDr_P = [homeDr  filesep 'filtered_scenes_objects_present_training'];

tmp = input('delete current files ? (y/n) ...', 's');
if strcmp(tmp, 'y')
    cd(saveDr_A);
    unix('rm *.png');
    cd(saveDr_P);
    unix('rm *.png');
end
tmp = input('show images? (y/n) ...', 's');
if strcmp(tmp, 'y')
    plotIt = 1;
else
    plotIt = 0;
end

addpath(genpath(homeDr));
objectsList = get_objectlist_training();
%% parameters
scFac = exp(linspace(log(1.5), log(4.5), 6)+0.12); % 6 possible object sizes
nLocs = 3; % each object on each scene will have 3 random locations
rotRange = 30 ; % object can be rotated by up to 30 degress

%% load one version of each scene
cd(sceneDr);
sceneList = dir([sceneDr filesep 'Scene*.png']);
tmp = dir;
ct = 1;
for s = 3:length(tmp)
    sceneList(ct).name = tmp(s).name;
    ct = ct+1;
end

cd(objectDr);
for o = 33:length(objectsList)
    disp(['object ', num2str(o),  ' out of ', num2str(length(objectsList))]);
  
    for sz = 1:length(scFac)
        disp(['size ', num2str(sz),  ' out of ', num2str(length(scFac))]);
        for s = 1:length(sceneList)   
            for l = 1:nLocs
                  cd(objectDr);
                cd(sceneDr);
                o_imgOrig = imread([objectsList{o}, '.png']);
                o_imgOrig = mean(o_imgOrig, 3);
                cd(maskDr)
                o_maskOrig = imread([objectsList{o}, '_mask.png']);
                o_maskOrig = mean(o_maskOrig, 3);
                o_maskOrig = conv2(o_maskOrig, [.5 .5 .5; .5 1 .5; .5 .5 .5]./5, 'same');
                
                o_imgOrig =double(imresize(o_imgOrig, 1/scFac(sz)));
                o_maskOrig =double(imresize(o_maskOrig, 1/scFac(sz)));
                clear o_img o_mask
                imgRot=randi(rotRange*2, 1)-rotRange;
                o_img = imrotate(o_imgOrig, imgRot, 'nearest', 'loose');
                o_mask = imrotate(o_maskOrig, imgRot, 'nearest', 'loose');
                goodPix = o_mask./255;
                goodPix(goodPix<.999) = 0;
                goodPix(goodPix>=.999) = 1;
                [i, j] = find(goodPix);
                % crop to the size of the actual object
                o_img = o_img(min(i)-1:max(i)+1, min(j)-1:max(j)+1);
                goodPix = goodPix(min(i)-1:max(i)+1, min(j)-1:max(j)+1);
                
               
                s_img = imread(sceneList(s).name);
                s_img = mean(s_img, 3);
                s_img=s_img(:, 129:end-128);
                if size(s_img, 1)~=size(s_img, 2)
                    error('warning, scene cropped incorrectly');
                end
                [~, s_img_AF] = filterImage(s_img);
                subplot(2,2,1); imagesc(s_img);
                subplot(2,2,2); imagesc(s_img_AF(1).Img);
                
                max_dim = max(size(o_img));
                im_padding = 700;
                rand_padding = randi([max_dim+1 im_padding],1,1);
                if rand_padding == max_dim
                    rand_padding = rand_padding + 1;
                end
                scene_size = 768;
                s_img_P = double(s_img);
                loc_r = randi(rand_padding-size(o_img,1)) + (scene_size-rand_padding)/2; % object image in central middle square
                loc_c = randi(rand_padding-size(o_img, 2))+ (scene_size-rand_padding)/2;
                
                s_img_P(loc_r:loc_r+size(o_img, 1)-1, loc_c:loc_c+size(o_img, 2)-1) = ...
                    goodPix.* o_img +...
                    (1-goodPix).*s_img_P(loc_r:loc_r+size(o_img, 1)-1, loc_c:loc_c+size(o_img, 2)-1);
                
                [filt, s_img_PF] = filterImage(s_img_P);
                if plotIt
                    subplot(2,2,3); imagesc(s_img_P);
                    subplot(2,2,4); imagesc(s_img_PF(1).Img); colormap(gray); drawnow;
                end
                
                %% save object present images
                cd(saveDr_P)
                filename = [objectsList{o}, ...
                    '_Scene_', sceneList(s).name(6:end-4), ...
                    '_scFac_', num2str(round(scFac(sz)*10)),  ...
                    '_Loc_', num2str(loc_r), '_', num2str(loc_c), ...
                    '_Rot_', num2str(imgRot + rotRange),  ...
                    '_P_L.png'];
                imwrite(uint8(round(Scale(s_img_PF(1).Img)*255, 0)),filename);
                
                filename = [objectsList{o}, ...
                    '_Scene_', sceneList(s).name(6:end-4), ...
                    '_scFac_', num2str(round(scFac(sz)*10)),  ...
                    '_Loc_', num2str(loc_r), '_', num2str(loc_c), ...
                    '_Rot_', num2str(imgRot + rotRange),  ...
                    '_P_R.png'];
                imwrite(uint8(round(Scale(s_img_PF(2).Img)*255, 0)), filename);
                
                
                %% save object absent images
                cd(saveDr_A)
                filename = [objectsList{o}, ...
                    '_Scene_', sceneList(s).name(6:end-4), ...
                    '_scFac_', num2str(round(scFac(sz)*10)),  ...
                    '_Loc_', num2str(loc_r), '_', num2str(loc_c), ...
                    '_Rot_', num2str(imgRot + rotRange),  ...
                    '_A_L.png'];
                
                imwrite(uint8(round(Scale(s_img_AF(1).Img)*255, 0)),filename);
                filename = [objectsList{o}, ...
                    '_Scene_', sceneList(s).name(6:end-4), ...
                    '_scFac_', num2str(round(scFac(sz)*10)),  ...
                    '_Loc_', num2str(loc_r), '_', num2str(loc_c), ...
                    '_Rot_', num2str(imgRot + rotRange),  ...
                    '_A_R.png'];
                imwrite(uint8(round(Scale(s_img_AF(2).Img)*255, 0)),filename);
            end
        end
    end
end

function  [filtImg, eyeImg] = filterImage(origImg, varargin)% this script allows you to load images that call filterImage and save
% dichoptic images to use later

%creating filter parameters
if nargin<2
    fpar.nPix = 768;
    fpar.spokes =4;
    fpar.freq = 13;
    fpar.wDeg = 5;
    fpar.clip = 1;
    fpar.plot = 0;
    fpar.n = 20;
    fpar.rect = [1 1 768 768];
    fpar.noise = 0;
    fpar.radPhase = pi/2;
    fpar.spokePhase = pi/4;
    fpar.filterName = 'RadialCheckerboard';
end
%% define weights to convert filtered inputs into eye inputs
% first dim represents the filter, the second represents whether the image
% is the original contrast, or reversed

[filterbank, fpar] = MakeFilter(fpar.filterName, fpar);
eyeWeight(1).w = zeros(length(filterbank), 2); % left eye
eyeWeight(1).w(1, 1) = 1; eyeWeight(1).w(2, 2) = 1; % F * I + F' * I'
eyeWeight(2).w = zeros(length(filterbank), 2); % right eye
eyeWeight(2).w(2, 1) = 1; eyeWeight(2).w(1, 2) = 1; % F * I' + F' * I

if ndims(origImg) ==3
    origImg = mean(origImg,3); % take average of R, G, B matrices
end
origImg = imscale(origImg./255);% scale the image between 0 and 1
origImg = imresize(origImg,max(size(origImg))/fpar.nPix); % makes the long edge of image fill fpar.nPix
origImg = insertImg(ones(fpar.nPix)*mean(origImg(:)), origImg); % fills the short size of the image with padding
[filtImg, eyeImg] = FilterImage(origImg,filterbank, fpar, eyeWeight);

end



