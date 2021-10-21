
if exist('/home/viscog/GitHub/dichoptic_gaming', 'dir')
    homeDr = '/home/viscog/GitHub/dichoptic_gaming';
else
    homeDr = 'C:\Users\Rebecca Esquenazi\DichopticGaming\dichoptic_gaming';
end

resDr = fullfile(homeDr, 'Results', 'PreTest_Data', 'SP_21');
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
    tmp = regexp({subjectFiles.name}, '.*[Pp]re[Tt]est_(?<n>\d+)', 'names');
    order = cellfun(@(x) str2double(x.n), tmp);
    [~,orderIndx] = sort(order);
    savefiles{i} = subjectFiles(orderIndx);
    maxruns(i) = length(savefiles{i});
end

numPreTestSessions = 3;
numEyeConds = 2;

dPrimeSuppressionIndivRuns = zeros([numPreTestSessions, numEyeConds, size(subjects,2)]);
dPrimeSuppressionSEIndivRuns = zeros([numPreTestSessions, numEyeConds, size(subjects,2)]);

for sid = 1:length(subjects)
    % loop through runs for this subject
    
    for i = 1:length(savefiles{sid})
        load(savefiles{sid}(i).name, 'rObj');
        
        correct = cat(1,rObj(:).correct);
        condition = cat(1,rObj(:).condition);
        preTestCond = cat(1,rObj(:).preTestCond);
        lrEye = cat(1,rObj(:).obLReye);
        preTestCondList = unique(preTestCond);
        
        indx = preTestCond == preTestCondList(5);
        
        for s = 1:numEyeConds
            %calculate ratio of hits and false alarms for trials where obejct
            %was present in either the left or right eye. s = 1 corresponds
            %to object present in left eye and s = 2 corresponds to object
            %present in right eye
            
            nHitTrials = sum(condition==1 & lrEye==(s) & indx==1); %object in left eye
            pHit = sum(correct(condition==1 & lrEye==(s) & indx==1))/nHitTrials;
            nFATrials = sum(condition==2 & lrEye==(s) & indx ==1);
            pFA = 1 - sum(correct(condition==2 & lrEye==(s) & indx==1))/nFATrials;
            
            if pFA == 0
                pFA = 0.001;
            end
            
            zHit = norminv(pHit);
            zFA = norminv(pFA);
            
            dPrimeSuppressionIndivRuns(i,s,sid) = zHit - zFA;
            
            %bootstrap to get error bars%
            
            % Generate nReps fake 'hit' data sets based on pHit
            respHit = floor(rand(nHitTrials,nReps))+ repmat(pHit, ...
                nHitTrials,nReps);
            
            % hack: allow for at least one hit or miss
            pHitSamp = min(max(mean(respHit),1/nHitTrials),1-1/nHitTrials);
            
            % Generate nReps fake 'FA' data sets based on pFA
            respFA = floor(rand(nFATrials,nReps)+repmat(pFA,...
                nFATrials,nReps));
            
            % hack: allow for at least one correct rejection or false alarm
            pFASamp = min(max(mean(respFA),1/nFATrials),1-1/nFATrials);
            
            % z scores and d-prime, as above
            zHitSamp = norminv(pHitSamp);
            zFASamp = norminv(pFASamp);
            dPrimeSamp = zHitSamp-zFASamp;
            
            % error bar is standard deviation of fake d-primes acros nReps
            dPrimeSuppressionSEIndivRuns(i,s,sid) = std(dPrimeSamp);
        end
    end
end

%% Plotting

%% Plotting Individual Subjects dPrime, percent correct, and proportion of FAs
clrList = {'r', 'b', 'g', 'm', 'k', 'o', 'c'};
maxruns = 3;
figure()
for sid = 1:length(subjects)
    
    %first row is dprime
    subplot(3,3,sid)
    
    for c = 1:size(dPrimeSuppressionIndivRuns,2)
        e(c) = errorbar(1:size(dPrimeSuppressionIndivRuns, 1), ...
            dPrimeSuppressionIndivRuns(:,c,sid),...
            dPrimeSuppressionSEIndivRuns(:,c,sid), ...
            'Marker', 'o', ...
            'Color', clrList{c}, ...
            'Linewidth', 1.3, ...
            'MarkerFaceColor', clrList{c});
        hold on
    end
    % label shit
    xlabel('Experimental Session');
    ylabel('D-Prime');
    ylim([-0.5,4]);
    xlim([0.5, (maxruns+.5)]);
    title([subjects{sid} ' Pre Test Results']);
    set(gca, 'XTick', 1:maxruns, 'box', 'off', 'FontSize',12)
    axis square
    if sid == 7
        legend(e, {'Left Eye', 'Right Eye'});
    end

end