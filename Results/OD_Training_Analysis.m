% Object Recognition Training _Analysis plots the dprime score of each
% participant in each session of the training phase of the
% dichoptic gaming experiment

% cd('/home/viscog/GitHub/dichoptic_gaming/Results');

if exist('/home/viscog/GitHub/dichoptic_gaming', 'dir')
    homeDr = '/home/viscog/GitHub/dichoptic_gaming';
else
    homeDr = 'C:\Users\Rebecca Esquenazi\DichopticGaming\dichoptic_gaming';
end
resDr = fullfile(homeDr, 'Results', 'Training_Data', 'SP_21');
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
    tmp = regexp({subjectFiles.name}, '.*[Tt]raining_(?<n>\d+)', 'names');
    order = cellfun(@(x) str2double(x.n), tmp);
    [~,orderIndx] = sort(order);
    savefiles{i} = subjectFiles(orderIndx);
    maxruns(i) = length(savefiles{i});
end


numTrainingSessions = max(maxruns);

dPrimeTraining = zeros([numTrainingSessions, size(subjects,2)]);
dPrimeTrainingSE = zeros([numTrainingSessions, size(subjects,2)]);
pCorrectTraining = zeros([numTrainingSessions, size(subjects,2)]);
pCorrectTrainingSE = zeros([numTrainingSessions, size(subjects,2)]);
pFATraining = zeros([numTrainingSessions, size(subjects,2)]);


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
            pCorrectObSize(i,s,sid) = mean(correct(indx));
            pCorrectObSizeSE(i,s,sid) = sqrt(sum(indx) * pCorrectObSize(i,s,sid)...
                * (1-pCorrectObSize(i,s,sid))) / sum(indx);
        end
        
        pCorrectTraining(i,sid) = mean(correct);
        pCorrectTrainingSE(i,sid) = sqrt(length(correct)...
            * pCorrectTraining(i,sid) * (1 - pCorrectTraining(i,sid)))...
            / length(correct);
        
        % hits and false alarms
        nHitTrials = sum(condition==1);
        pHit = sum(correct(condition==1))/nHitTrials;
        nFATrials = sum(condition==2);
        pFA = 1-sum(correct(condition==2))/nFATrials;
        
        % fals alarm rate (for plotting)
        pFATraining(i,sid) = pFA;
        
        % z scores for hits and false alarms
        zHit = norminv(pHit);
        zFA = norminv(pFA);
        
        % d-prime is difference between z-scores
        dPrimeTraining(i,sid) = zHit-zFA;
        
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
        dPrimeTrainingSE(i,sid) = std(dPrimeSamp);
    end
end

dPrimeTraining(dPrimeTraining==0)=NaN;
dPrimeTrainingSE(dPrimeTrainingSE==0)=NaN;
pCorrectTraining(pCorrectTraining==0)=NaN;
pCorrectTrainingSE(pCorrectTrainingSE==0)=NaN;

%% Average over all subjects

pCorrectTrainingAvg = mean(pCorrectTraining,2);

dPrimeTrainingAvg = mean(dPrimeTraining,2);

pFATrainingAvg = mean(pFATraining,2);

%% get standard errors for averages

dPrimeSubjectsRows = dPrimeTraining';
dPrimeSubjectsRowsAvg = mean(dPrimeSubjectsRows,1);
dPrimeTrainingAvgSE = std(dPrimeSubjectsRows)/sqrt(length(subjects));


% %% Plotting
% 
% % individual subjects with average performance overlayed
% 
% for i = 1:length(subjects)
%     p = plot(1:numTrainingSessions, dPrimeSubjectsRows(i,:),...
%         'Color', [.862 .862 .862],...
%         'Marker', 'o',...
%         'MarkerSize', 1.5,...
%         'LineWidth', 1);
% %     p.Color(4) = 0.8;
%     hold on
% end
% 
% hold on
% 
% errorbar(1:numTrainingSessions,dPrimeSubjectsRowsAvg, dPrimeTrainingAvgSE,...
%     'Marker', 'o',...
%     'Color', 'k',...
%     'LineWidth', 1.5,...
%     'MarkerFaceColor','k');
%     
%     title('Performance During Training Phase');
%     xlabel('Training Session');
%     ylabel('D-Prime');
%     ylim([0,4.5]);
%     xlim([0.5,(numTrainingSessions+.5)]);
%     set(gca, 'XTick', 1:1:numTrainingSessions, 'YTick', 0:1:4, 'box', 'off',...
%         'FontSize', 18);    
%     axis square
% 
% 
% 
% %% average percent correct by scale factor across sessions
% 
% colList = {'r','g','b','m', 'y', 'c'};
% 
% for c = 1:size(pCorrectObSizeAvg,2)
%     p(c) = errorbar(1:size(pCorrectObSizeAvg,1),...
%         pCorrectObSizeAvg(:,c),...
%         pCorrectObSizeAvgSE(:,c),...
%         'Marker', 'o', ...
%         'Color', colList{c}, ...
%         'Linewidth', 1.3, ...
%         'MarkerFaceColor', colList{c});
%     hold on
% end
% 
% lgd = legend(p, {'22%','28%','34%','43%','53%','67%'}, 'Location',...
%         'NorthWest');
% title(lgd, 'Percent Original Size');   
% 
%     xlabel('Experimental Session');
%     ylabel('Percent Correct');
%     title('Percent Correct by Object Size');
%     
%     ylim([0.5,1]);
%     xlim([0.5,(numTrainingSessions+.5)]);
%     set(gca, 'XTick', 1:1:numTrainingSessions, 'YTick', 0.5:0.1:1);
%     grid
%  
% 
% %% percent correct by scale factor for indiv. participants
% 
% for sid = 1:length(subjects)
%     figure(sid)
%     
%     hold on
%     for c = 1:size(pCorrectObSize,2)
%         s(c) = errorbar(1:size(pCorrectObSize,1),...
%             pCorrectObSize(:,c,sid),...
%             pCorrectObSizeSE(:,c,sid),...
%             'Marker', 'o',...
%             'Color', colList{c},...
%             'Linewidth', 1,...
%             'MarkerFaceColor', colList{c});
%         hold on
%     end
%     
% lgd = legend(s, {'22%','28%','34%','43%','53%','67%'}, 'Location',...
%         'NorthWest');
% title(lgd, 'Percent Original Size');   
%     
%     xlabel('Experimental Session');
%     ylabel('Percent Correct');
%     title([subjects{sid} ' Percent Correct by Object Size']);
%     
%     ylim([0.5,1]);
%     xlim([0.5,(numTrainingSessions+.5)]);
%     set(gca, 'XTick', 1:1:numTrainingSessions, 'YTick', 0.5:0.1:1);
%     grid
%     
% end
% 
% %% percent correct & dPrime for indiv. participants 
% 
% figure(1)
% subplot(1,2,1)
% 
% colList = {'r','g','b','m', 'y', 'c', 'k'};
% 
% for sid=1:length(subjects)
%     h(sid) = errorbar(1:size(dPrimeTraining,1),...
%         dPrimeTraining(:,sid),...
%         dPrimeTrainingSE(:,sid),...
%         'k', 'Color', [.8 .8 .8], 'MarkerFaceColor', colList{sid});
%     hold on
% end
% hold on
% for sid = 1:length(subjects)
%     h(sid) = plot(1:size(dPrimeTraining,1),...
%         dPrimeTraining(:,sid),...
%         'Marker', 'o', ...
%         'MarkerSize', 8,...
%         'Color', 'k', ...
%         'Linewidth', 1.1, ...
%         'MarkerFaceColor', colList{sid});
%     hold on
% end
% 
% % label shit
% xlabel('Experimental Session');
% ylabel('D-Prime');
% title('Individual Subject D-Prime');
% ylim([0,4]);
% xlim([.25,(max(maxruns))+.5])
% set(gca, 'XTick', 1:(max(maxruns)), 'box', 'off');
% set(gca,'FontSize',12);
% axis square
% legend(h,{'S1','S2','S3','S4', 'S5', 'S6', 'S7'},'Location','NorthWest');
% 
% subplot(1,2,2)
% 
% for sid=1:length(subjects)
%     h(sid) = errorbar(1:size(pCorrectTraining,1),...
%         pCorrectTraining(:,sid),...
%         pCorrectTrainingSE(:,sid),...
%         'k', 'Color', [.8 .8 .8], 'MarkerFaceColor', colList{sid});
%     hold on
% end
% hold on
% for sid = 1:length(subjects)
%     h(sid) = plot(1:size(pCorrectTraining,1),...
%         pCorrectTraining(:,sid),...
%         'Marker', 'o', ...
%         'MarkerSize', 8,...
%         'Color', 'k', ...
%         'Linewidth', 1.1, ...
%         'MarkerFaceColor', colList{sid});
%     hold on
% end
% 
% % label shit
% xlabel('Experimental Session');
% ylabel('Percent Correct');
% title('Individual Subject Percent Correct');
% ylim([0.5,1]);
% xlim([.25,(max(maxruns))+.5])
% set(gca, 'XTick', 1:(max(maxruns)), 'YTick', 0.5:0.1:1, 'box', 'off')
% set(gca,'FontSize',12);
% axis square
% legend(h,{'S1','S2','S3','S4'},'Location','NorthWest');
