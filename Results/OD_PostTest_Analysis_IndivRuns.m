% becca trying to make code more efficient


if exist('/home/viscog/GitHub/dichoptic_gaming', 'dir')
    homeDr = '/home/viscog/GitHub/dichoptic_gaming';
else
    homeDr = 'C:\Users\Rebecca Esquenazi\DichopticGaming\dichoptic_gaming';
end
resDr = fullfile(homeDr, 'Results', 'PostTraining_Data');
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
    tmp = regexp({subjectFiles.name}, '.*[Pp]ostTest_(?<n>\d+)', 'names');
    order = cellfun(@(x) str2double(x.n), tmp);
    [~,orderIndx] = sort(order);
    savefiles{i} = subjectFiles(orderIndx);
    maxruns(i) = length(savefiles{i});
end

% initialize results arrays
% each subject ran 3 pretest sessions with 4 preTest conditions
% results will be stored in a {3,4,#subjects) matrix
numPostTestSessions = 3;
numPostTestConds = 4;

dPrimePostTest = zeros([numPostTestSessions, numPostTestConds, size(subjects,2)]);
dPrimePostTestSEIndivRuns = zeros([numPostTestSessions, numPostTestConds, size(subjects,2)]);
pCorrectPostTest = zeros([numPostTestSessions, numPostTestConds, size(subjects,2)]);
pCorrectPostTestSE = zeros([numPostTestSessions, numPostTestConds, size(subjects,2)]);
pFAPostTest = zeros([numPostTestSessions, numPostTestConds, size(subjects,2)]);

for sid = 1:length(subjects)
    % loop through runs for this subject
    
    for i = 1:length(savefiles{sid})
        load(savefiles{sid}(i).name, 'rObj');
        correct = cat(1,rObj(:).correct);
        condition = cat(1,rObj(:).condition);
        postTestCond = cat(1,rObj(:).preTestCond);
        postTestCondList = unique(postTestCond);
        
        for s = 1:length(postTestCondList)
            indx = postTestCond == postTestCondList(s);
            nCorrectPostTest(i,s,sid) = sum(correct(indx));
            % percent correct for each session & binomial dist SE
            pCorrectPostTest(i,s,sid) = mean(correct(indx));
            pCorrectPostTestSE(i,s,sid) = sqrt(length(correct))...
                * pCorrectPostTest(i,s,sid) * (1 - pCorrectPostTest(i,s,sid))...
                / length(correct);
            
            % hits and false alarms
            nHitTrials = sum(condition(indx)==1);
            pHit = sum(correct(condition == 1 & indx ==1))/nHitTrials;
            nFATrials = sum(condition(indx)==2);
            pFA = 1-sum(correct(condition == 2 & indx==1))/nFATrials;
            if pFA == 0
                pFA = 0.01;
            end
            if pHit ==1
                pHit = 0.99;
            end
            
            %record false alarm rate for plotting
            pFAPostTest(i,s,sid) = pFA;
            
            % z scores for hits and false alarms
            zHit = norminv(pHit);
            zFA = norminv(pFA);
            
            dPrimePostTestIndivRuns(i,s,sid) = zHit - zFA;
            
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
            dPrimePostTestSEIndivRuns(i,s,sid) = std(dPrimeSamp);
        end
    end
end


%% Averaging over all subjects

% pCorrectPostTestAvg = mean(pCorrectPostTest,3);
% pCorrectPostTestAvgSE = mean(pCorrectPostTestSE,3);
% dPrimePostTestAvg = mean(dPrimePostTest,3);
% dPrimePostTestAvgSE = mean(dPrimePostTestSE,3);
% pFAPostTestAvg = mean(pFAPostTest,3);


% %% Plotting Individual Subjects dPrime, percent correct, and proportion of FAs
% clrList = {'r', 'g', 'b', 'm'};
% 
% for sid = 1:length(subjects)
%     figure(1)
%     
%     %first row is dprime
%     subplot(2,length(subjects),sid)
%     
%     for c = 1:size(dPrimePostTest,2)
%         e(c) = errorbar(1:size(dPrimePostTest, 1), ...
%             dPrimePostTest(:,c,sid),...
%             dPrimePostTestSE(:,c,sid), ...
%             'Marker', 'o', ...
%             'Color', clrList{c}, ...
%             'Linewidth', 1.3, ...
%             'MarkerFaceColor', clrList{c});
%         hold on
%     end
%     % label shit
%     xlabel('Experimental Session');
%     ylabel('D-Prime');
%     ylim([0,6]);
%     xlim([0.5, (maxruns(sid)+.5)]);
%     title([subjects{sid} ' Post Test Results']);
%     axis square
%     set(gca, 'XTick', 1:maxruns(sid), 'box', 'off', 'FontSize',9)
%     legend(e, {'training', 'monocular', 'flipped', 'noise'} ,...
%         'Location','NorthWest');
%    
%     
%     % second row is percent correct
%     subplot(2,length(subjects),sid+length(subjects))
%     
%     for c = 1:size(pCorrectPostTest,2)
%         p(c) = errorbar(1:size(pCorrectPostTest,1),...
%             pCorrectPostTest(:,c,sid),...
%             pCorrectPostTestSE(:,c,sid),...
%             'Marker', 'o', ...
%             'Color', clrList{c}, ...
%             'Linewidth', 1.3, ...
%             'MarkerFaceColor', clrList{c});
%         hold on
%     end
%     
%     %label shit
%     xlabel('Experimental Session');
%     ylabel('Percent Correct');
%     ylim([.5,1]);
%     xlim([0.5, (maxruns(sid)+.5)]);
%     set(gca, 'XTick', 1:maxruns(sid), 'YTick', 0.5:0.1:1, 'FontSize', 12, 'box', 'off'); 
%     axis square
% end
% 
% %% Plotting dPrime, percent correct and proportion of FAs collapsed across participants
% max_runs = 3;
% figure(2)
% subplot(1,2,1)
% 
% for c = 1:size(pCorrectPostTestAvg,2)
%     p(c) = errorbar(1:size(pCorrectPostTestAvg,1),...
%         pCorrectPostTestAvg(:,c),...
%         pCorrectPostTestAvgSE(:,c),...
%         'Marker', 'o', ...
%         'Color', clrList{c}, ...
%         'Linewidth', 1.3, ...
%         'MarkerFaceColor', clrList{c});
%     hold on
% end
% 
% xlabel('Experimental Session');
% ylabel('Percent Correct');
% title('Average Post Test Percent Correct');
% ylim([.5,1]);
% xlim([0.5 max_runs+.5]);
% axis square
% set(gca, 'XTick', 1:max_runs, 'YTick', 0.5:.1:1,'FontSize', 12, 'box', 'off')
% 
% 
% legend(p, {'training', 'monocular', 'flipped', 'noise'} ,...
%     'Location','NorthWest');
% 
% 
% subplot(1,2,2)
% for c = 1:size(dPrimePostTestAvg,2)
%     d(c) = errorbar(1:size(dPrimePostTestAvg,1),...
%         dPrimePostTestAvg(:,c),...
%         dPrimePostTestAvgSE(:,c),...
%         'Marker', 'o', ...
%         'Color', clrList{c}, ...
%         'Linewidth', 1.3, ...
%         'MarkerFaceColor', clrList{c});
%     hold on
% end
% 
% xlabel('Experimental Session');
% ylabel('D-Prime');
% title('Average Post Test D Prime');
% ylim([0,6]);
% xlim([0.5 max_runs+.5]);
% set(gca, 'XTick', 1:max_runs, 'YTick', 0:1:6, 'FontSize', 12, 'box', 'off')
% axis square
% legend(d, {'training', 'monocular', 'flipped', 'noise'} ,...
%     'Location','NorthWest');
% 

