%%
clear all;

homeDr = 'C:\Users\Rebecca Esquenazi\GitHub\dichoptic_gaming';
resDr = fullfile(homeDr, 'Results', 'Training_Data');
cd(resDr)
list = dir('*.mat');

% Kelly's regexp magic to get subjet names
subjectList = regexprep({list.name}, '_.*', '');
subjects = unique(subjectList);

% for every subject, isolate the session number and order it correctly
% for analysis purposes only grab first 5 files
for i = 1:length(subjects)
    indx = strcmp(subjects{i}, subjectList);
    subjectFiles = list(indx);
    tmp = regexp({subjectFiles.name}, '.*Training_(?<n>\d+)', 'names');
    order = cellfun(@(x) str2double(x.n), tmp);
    [~,orderIndx] = sort(order);
    savefiles{i} = subjectFiles(orderIndx(1:5));
end

%% calculate percent correct for each object for each subject

for sid = 1:length(subjects)
    for i = 1:length(savefiles{sid})
        load(savefiles{sid}(i).name, 'rObj');
        trueObj = {rObj.filename}';
        
        for o = 1:size(trueObj,1)
            tmp = trueObj(o);
            stopStr = ('_Scene');
            rObj(o).trueObjList = cell2mat(extractBefore(tmp,stopStr));
        end
        
        correct = cat(1,rObj(:).correct);
        trueObject = {rObj(:).trueObjList};
        objectList = unique(trueObject);
        scFac = cat(1,rObj(:).scFac);
        scFacList = unique(scFac);
        
        for k = 1:length(objectList)
            obIndx = objectList{k};
            pCorrectObj(i,k,sid) = mean(correct(obIndx));
            for s = 1:length(scFacList)
                scFacIndx = scFac == scFac(k);
                pCorrectObjScFac(i,k,s,sid) = mean(correct(scFacIndx));
            end
        end
    end
end

% percent correct for each object averaged across participants

pCorrectObjAvg = mean(pCorrectObj,3);
pCorrectObjScFacAvg = mean(pCorrectObjScFac,4);

%% plot percent correct averaged across participants


for p = 1:size(pCorrectObjAvg,1)
    figure(p)
    barh(categorical(objectList),(pCorrectObjAvg(p,:)));
    xlim([0,1])
    ylabel(['Object Name']);
    xlabel(['Percent Correct']);
end

%%

%remove underscore from object names for plotting
for i = 1:size(objectList,2)
    objectName = objectList{i};
    tmp = regexp(objectName,'_');
    if ~isempty(tmp)
        objectName(tmp) = ' ';
    end
    objectList{i} = objectName;
end

figure(1); clf; 
for i = 1:size(pCorrectObjAvg)
    subplot(size(pCorrectObjAvg,1), 1, i); hold on;
    [sorted_data, new_indices] = sort(pCorrectObjAvg(i,:), 'ascend');
    sorted_labels = objectList(new_indices);
    barh(1:length(sorted_data(1:10)), sorted_data(1:10));
    plot([0.5 0.5], [0 length(sorted_data(1:10))+01], 'r--', 'LineWidth', 2);
    set(gca, 'XLim', [0 1], 'YTick', 1:length(sorted_data(1:10)), ...
        'YTickLabel', sorted_labels(1:10));
    title(['Training Session ' num2str(i)]);
end

%%

session = [1 2];
x = pCorrectObjAvg(session(1),:);
y = pCorrectObjAvg(session(2),:);
r = corrcoef(x(:), y(:));
xJitter = 5e-3 * rand(size(x));
yJitter = 5e-3 * rand(size(y));
figure(2); clf; hold on;
plot(x(:), y(:), '.');
text(x+xJitter, y+yJitter, objectList);
plot([0 1], [0 1], 'k:');
set(gca, 'XLim', [0.5 1], 'YLim', [0.5 1]);
axis square
colormap copper









