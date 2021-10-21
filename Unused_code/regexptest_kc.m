clear all; close all;

%%

homeDr = pwd;
imageDir = [homeDr  filesep 'filtered_scenes_objects_present_newPar'];

%%

objectsList = get_objectlist();
files = dir(fullfile(imageDir, '*.png'));

templateLR = unique(regexprep({files.name}, '[LR].png', ''));
fileNames = cell(length(templateLR), 2);
fileNames(:,1) = cellfun(@(x) [x 'L.png'], templateLR, 'UniformOutput', false);
fileNames(:,2) = cellfun(@(x) [x 'R.png'], templateLR, 'UniformOutput', false);

%%

nTrials = 40; % number of trials
nConds = 2; % number of conditions
nTrialPerCond = nTrials / nConds;

%%

order = repmat(1:nConds, 1, nTrialPerCond);
order = order(randperm(length(order)));

%% Fill Paradigm Structure

paradigm = cell(nTrials, 4);
paradigm(:,1) = num2cell(order(:));
paradigm(:,2) = objectsList(randsample(1:nTrials, nTrials, true));
for i = 1:nTrials
    prompt = paradigm{i,2};
    matchIndx = regexp(fileNames(:,1), prompt);
    imageMatch = cellfun(@(x) ~isempty(x), matchIndx);
    
    if paradigm{i,1} == 1 % correct condition
        matchImages = fileNames(imageMatch,:);
    else % incorrect condition (2)
        matchImages = fileNames(~imageMatch,:);
    end
    
    paradigm(i,3:4) = matchImages(randsample(size(matchImages,1),1),:);
end
