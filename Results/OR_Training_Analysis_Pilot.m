% Object Recognition Training _Analysis plots the dprime score of each
% participant in each session of the training phase of the
% dichoptic gaming experiment
% cd('/home/viscog/GitHub/dichoptic_gaming/Results');

clear all;
close all;
homeDr = 'C:\Users\Rebecca Esquenazi\GitHub\dichoptic_gaming';
resDr = fullfile(homeDr, 'Results', 'Training_OldFilt_OldParadigm');
cd(resDr)
list = dir('*.mat');


% reps for bootstrapping error bars
nReps = 10000;

% Kelly's regexp magic to get subjet names
subjectList = regexprep({list.name}, '_.*', '');
subjects = unique(subjectList);

% for every subject, isolate the session number and order it correctly
for i = 1:length(subjects)
    indx = strcmp(subjects{i}, subjectList);
    subjectFiles = list(indx);
    tmp = regexp({subjectFiles.name}, '.*[Pp]ilot_(?<n>\d+)', 'names');
    order = cellfun(@(x) str2double(x.n), tmp);
    [~,orderIndx] = sort(order);
    savefiles{i} = subjectFiles(orderIndx);
    maxruns(i) = length(savefiles{i});
end


dPrimeTraining=  {};
dPrimeTrainingSE = {};
pCorrectTraining={};
pCorrectObSize = {};
pCorrectObSizeSE = {};

% loop through subjects, calculate d-prime and bootstrap error barss
for sid = 1:length(subjects)
    % loop through runs for this subject
    for i = 1:length(savefiles{sid}) % the number of saved runs each subject has
        load(savefiles{sid}(i).name, 'rObj');
        correct = cat(1,rObj(:).correct);
        condition = cat(1,rObj(:).condition);
        scFac = cat(1,rObj(:).scFac);
        scFacList = unique(scFac);
        
        for s = 1:length(scFacList)
            indx = scFac == scFacList(s);
            pCorrectObSize{sid}{i,s} = mean(correct(indx));
            pCorrectObSizeSE{sid}{i,s} = sqrt(sum(indx) * pCorrectObSize{sid}{i,s}...
                * (1-pCorrectObSize{sid}{i,s})) / sum(indx);
        end
        
        pCorrectTraining{sid}(i) = mean(correct);
        pCorrectTrainingSE{sid}(i) = sqrt(length(correct)...
            * pCorrectTraining{sid}(i) * (1 - pCorrectTraining{sid}(i)))...
            / length(correct);
        
        % hits and false alarms
        nHitTrials = sum(condition==1);
        pHit = sum(correct(condition==1))/nHitTrials;
        nFATrials = sum(condition==2);
        pFA = 1-sum(correct(condition==2))/nFATrials;
        
        % z scores for hits and false alarms
        zHit = norminv(pHit);
        zFA = norminv(pFA);
        
        % d-prime is difference between z-scores
        dPrimeTraining{sid}(i) = zHit-zFA;
        
        %bootstrap to get error bars
        
        % Generate nReps fake 'hit' data sets based on pHit
        respHit = floor(rand(nHitTrials,nReps)+repmat(pHit,nHitTrials,nReps));
        
        % hack: allow for at least one hit or miss
        pHitSamp = min(max(mean(respHit),1/nHitTrials),1-1/nHitTrials);
        
        % Generate nReps fake 'FA' data sets based on pFA
        respFA = floor(rand(nFATrials,nReps)+repmat(pFA,nFATrials,nReps));
        
        % hack: allow for at least one correct rejection or false alarm
        pFASamp = min(max(mean(respFA),1/nFATrials),1-1/nFATrials);
        
        % z scores and d-prime, as above
        zHitSamp = norminv(pHitSamp);
        zFASamp = norminv(pFASamp);
        dPrimeSamp = zHitSamp-zFASamp;
        
        % error bar is standard deviation of fake d-primes acros nReps
        dPrimeTrainingSE{sid}(i) = std(dPrimeSamp);
    end
    
end

%% plotting percent correct by scale factor across sessions

colList = {'r','g','b','m', 'y', 'c'};



for sid = 1:length(subjects)
    subplot(1,3,sid)
    
    
    for c = 1:size(pCorrectObSize{sid},2)
        s(c) = errorbar(1:size(pCorrectObSize{sid},1),...
            [pCorrectObSize{sid}{:,c}],...
            [pCorrectObSizeSE{sid}{:,c}],...
'k', 'Color', [.8 .8 .8], 'MarkerFaceColor', colList{c});
        hold on
    end
    hold on
        for c = 1:size(pCorrectObSize{sid},2)
        s(c) = plot(1:size(pCorrectObSize{sid},1),...
            [pCorrectObSize{sid}{:,c}],...
            'Marker', 'o', ...
            'MarkerSize', 6,...
            'Color', 'k', ...
            'Linewidth', 1.1, ...
            'MarkerFaceColor', colList{c});
        hold on
    end
    
    legend(s, {'Size1','Size2','Size3','Size4','Size5','Size6'}, 'Location',...
        'SouthEast');
    
    xlabel('Experimental Session');
    ylabel('Percent Correct');
    title([subjects{sid} ' Percent Correct by Object Size']);
    
    ylim([0.4,1.025]);
    xlim([0.5,(maxruns(sid)+.5)]);
    set(gca, 'XTick', 1:1:maxruns(sid), 'YTick', 0.5:0.1:1, 'box','off','FontSize',12);
    axis square
    
end

%% plotting dPrime and percent correct across sessions
colList = {'r','g','b','m', 'y', 'c'};
figure(5)
clf
hold on
for sid=1:length(subjects)
    subplot(length(subjects), 2, sid)
    d(sid) = errorbar(1:length(dPrimeTraining{sid}),...
        dPrimeTraining{sid}, ...
        dPrimeTrainingSE{sid},...
        'Marker', 'o',...
        'Color', 'k',...
        'Linewidth', 1,...
        'MarkerFaceColor', colList{sid});
    
    xlabel('Experimental Session');
    ylabel('D-Prime');
    
    ylim([0,6]);
    xlim([0.5,(maxruns(sid)+.5)]);
    title([subjects{sid} ' Training Results']);
    set(gca, 'XTick', 1:1:maxruns(sid), 'YTick', 0:1:6);
    
    
    subplot(length(subjects), 2, sid+length(subjects))
    p(sid) = errorbar(1:length(pCorrectTraining{sid}),...
        pCorrectTraining{sid}, ...
        pCorrectTrainingSE{sid},...
        'Marker', 'o',...
        'Color', 'k',...
        'Linewidth', 1,...
        'MarkerFaceColor', colList{sid});
    
    xlabel('Experimental Session');
    ylabel('Percent Correct');
    title('Individual Subject Percent Correct ');
    
    ylim([0.5,1]);
    xlim([0.5,(maxruns(sid)+.5)]);
    title([subjects{sid} ' Training Results']);
    set(gca, 'XTick', 1:1:maxruns(sid), 'YTick', 0.5:0.1:1, 'FontSize',12);
    
end


%% Plotting for OLD FILTER OLD PARADIGM

colList = {'r','g','b'};

figure(1)
clf
hold on

% draw error bars for all subjects first
for sid=1:length(subjects)
    errorbar(1:length(dPrimeTraining{sid}), dPrimeTraining{sid}, dPrimeTrainingSE{sid},'k');
end

% plot data points next
for sid =1:length(subjects)
    h(sid) = plot(1:length(dPrimeTraining{sid}),dPrimeTraining{sid}, 'ko-', 'MarkerFaceColor', colList{sid}, 'MarkerSize',8);
end

% label shit
xlabel('Experimental Session');
ylabel('D-Prime');
ylim([0,4]);
xlim([0.5,(max(maxruns))+.5])
set(gca, 'XTick', 1:(max(maxruns)))
hold on
grid

legend(h,{'S1','S2','S3'},'Location','NorthWest');

set(gca,'FontSize',14);

figure(2)
clf
hold on
for sid=1:length(subjects)
    errorbar(1:length(pCorrectTraining{sid}), pCorrectTraining{sid}, pCorrectTrainingSE{sid},'k');
end

% plot data points next
for sid =1:length(subjects)
    h(sid) = plot(1:length(pCorrectTraining{sid}),pCorrectTraining{sid}, 'ko-', 'MarkerFaceColor', colList{sid}, 'MarkerSize',8);
end

% label shit
xlabel('Experimental Session');
ylabel('Percent Correct');
ylim([0.5,1]);
xlim([0.5,(max(maxruns))+.5])
set(gca, 'XTick', 1:(max(maxruns)))
hold on
grid

legend(h,{'S1','S2','S3'},'Location','NorthWest');

set(gca,'FontSize',16);