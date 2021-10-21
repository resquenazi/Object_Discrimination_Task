% Object discrimination analysis code for pre test
% creates d'prime and percent correct for each subject in a called
% dPrimePreTest(or pCorrectPreTest) that has runs on rows and
% each pretest condition in the columns, and subjects in 3rd dimension.
% This script would be useful for looking at performance over time in 
% pre-test conditions. For code that averages over each session, see
% OD_PreTest_Analysis_AllRuns.m 

% % Pretest conditions (columns in results matrices):
% 1. regular stimulus conditions
% 2. monocular viewing (switches eyes randomly)
% 3. flipping eyes. (Right eye image now in left eye and left eye img
% in right eye)
% 4. 1/f noise stimuli

if exist('/home/viscog/GitHub/dichoptic_gaming', 'dir')
    homeDr = '/home/viscog/GitHub/dichoptic_gaming';
else
    homeDr = 'C:\Users\Rebecca Esquenazi\DichopticGaming\dichoptic_gaming';
end

resDr = fullfile(homeDr, 'Results', 'PreTest_Data','SP_21');
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

% initialize results arrays
% each subject ran 3 pretest sessions with 4 preTest conditions
% results will be stored in a {3,4,#subjects) matrix
numPreTestSessions = 3;
numPreTestConds = 5;

dPrimePreTestIndivRuns = zeros([numPreTestSessions, numPreTestConds, size(subjects,2)]);
dPrimePreTestSEIndivRuns = zeros([numPreTestSessions, numPreTestConds, size(subjects,2)]);
pCorrectPreTest = zeros([numPreTestSessions, numPreTestConds, size(subjects,2)]);
pCorrectPreTestSE = zeros([numPreTestSessions, numPreTestConds, size(subjects,2)]);
pFAPreTest = zeros([numPreTestSessions, numPreTestConds, size(subjects,2)]);

for sid = 1:length(subjects)
    % loop through runs for this subject
    
    for i = 1:length(savefiles{sid})
        load(savefiles{sid}(i).name, 'rObj');
        correct = cat(1,rObj(:).correct);
        condition = cat(1,rObj(:).condition);
        preTestCond = cat(1,rObj(:).preTestCond);
        preTestCondList = unique(preTestCond);
        
        for s = 1:length(preTestCondList)
            indx = preTestCond == preTestCondList(s);
            nCorrectPreTest(i,s,sid) = sum(correct(indx));
            
            % percent correct for each session & binomial dist SE
            pCorrectPreTest(i,s,sid) = mean(correct(indx));
            pCorrectPreTestSE(i,s,sid) = sqrt(length(correct))...
                * pCorrectPreTest(i,s,sid) * (1 - pCorrectPreTest(i,s,sid))...
                / length(correct);
            
            % hits and false alarms
            nHitTrials = sum(condition(indx)==1);
            pHit = sum(correct(condition == 1 & indx ==1))/nHitTrials;
            nFATrials = sum(condition(indx)==2);
            pFA = 1-sum(correct(condition == 2 & indx==1))/nFATrials;
            if pFA == 0
                pFA = 0.001;
            end
            
            %record false alarm rate for plotting
            pFAPreTest(i,s,sid) = pFA;
            
            % z scores for hits and false alarms
            zHit = norminv(pHit);
            zFA = norminv(pFA);
            
            dPrimePreTestIndivRuns(i,s,sid) = zHit - zFA;
            
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
            dPrimePreTestSEIndivRuns(i,s,sid) = std(dPrimeSamp);
        end
    end
end
%%
%% Plotting Individual Subjects dPrime, percent correct, and proportion of FAs
clrList = {'r', 'g', 'b', 'm', 'k'};

for sid = 1:length(subjects)
    
    %first row is dprime
    subplot(3,3,sid)
    
    for c = 1:size(dPrimePreTestIndivRuns,2)
        e(c) = errorbar(1:size(dPrimePreTestIndivRuns, 1), ...
            dPrimePreTestIndivRuns(:,c,sid),...
            dPrimePreTestSEIndivRuns(:,c,sid), ...
            'Marker', 'o', ...
            'Color', clrList{c}, ...
            'Linewidth', 1.3, ...
            'MarkerFaceColor', clrList{c});
        hold on
    end
    % label shit
    xlabel('Experimental Session');
    ylabel('D-Prime');
    ylim([0,6]);
    xlim([0.5, (maxruns(sid)+.5)]);
    title([subjects{sid} ' Pre Test Results']);
    axis square
    set(gca, 'XTick', 1:maxruns(sid), 'box', 'off', 'FontSize',12)
    if sid == 7
    legend(e, {'training', 'monocular', 'flipped', 'noise','suppression'} ,...
        'Location','NorthWest');
    end
end
%% Plotting dPrime, percent correct and proportion of FAs collapsed across participants
max_runs = 3;
figure(2)
subplot(1,2,1)
clrList = {'r', 'g', 'b', 'm', 'k'};


pCorrPreTestAvg = mean(pCorrectPreTest,3);
pCorrPreTestAvgSE = mean(pCorrectPreTestSE,3);

for c = 1:size(pCorrPreTestAvg,2)
    p(c) = errorbar(1:size(pCorrPreTestAvg,1),...
        pCorrPreTestAvg(:,c),...
        pCorrectPreTestSE(:,c),...
        'Marker', 'o', ...
        'Color', clrList{c}, ...
        'Linewidth', 1.3, ...
        'MarkerFaceColor', clrList{c});
    hold on
end

xlabel('Experimental Session');
ylabel('Percent Correct');
title('Average Pre Test Percent Correct');
ylim([.5,1]);
xlim([0.5 max_runs+.5]);
axis square
grid
set(gca, 'XTick', 1:max_runs, 'YTick', 0.5:.1:1,'FontSize', 12, 'box', 'off')


legend(p, {'training', 'monocular', 'flipped', '1/f noise','object P/A'} ,...
    'Location','NorthWest');

dPrimePreTestAvg = mean(dPrimePreTestIndivRuns,3);
dPrimePreTestAvgSE = mean(dPrimePreTestSEIndivRuns,3);

subplot(1,2,2)
for c = 1:size(dPrimePreTestAvg,2)
    d(c) = errorbar(1:size(dPrimePreTestAvg,1),...
        dPrimePreTestAvg(:,c),...
        dPrimePreTestAvgSE(:,c),...
        'Marker', 'o', ...
        'Color', clrList{c}, ...
        'Linewidth', 1.3, ...
        'MarkerFaceColor', clrList{c});
    hold on
end

xlabel('Experimental Session');
ylabel('D-Prime');
title('Average Pre Test D Prime');
ylim([0,4.5]);
xlim([0.5 max_runs+.5]);
set(gca, 'XTick', 1:max_runs, 'YTick', 0:1:6, 'FontSize', 12, 'box', 'off')
axis square
grid
legend(d, {'training', 'monocular', 'flipped', '1/f noise','object P/A'} ,...
    'Location','NorthWest');


