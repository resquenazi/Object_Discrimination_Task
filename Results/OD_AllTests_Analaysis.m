if exist('/home/viscog/GitHub/dichoptic_gaming', 'dir')
    homeDr = '/home/viscog/GitHub/dichoptic_gaming';
else
    homeDr = 'C:\Users\Rebecca Esquenazi\DichopticGaming\dichoptic_gaming';
end

mainresDr = fullfile(homeDr, 'Results');

OD_PreTest_Analysis_IndivRuns
cd(mainresDr)
OD_PreTest_Analysis_AllRuns
cd(mainresDr)
OD_Training_Analysis
cd(mainresDr)
% OD_PostTest_Analysis_AllRuns
% cd(mainresDr)
% OD_PostTest_Analysis_IndivRuns
%%

clearvars -except d* subjects *p

dPrimePreTestIndivRuns = dPrimePreTestIndivRuns(:,1,:);
dPrimePreTestSubjectsRows = squeeze(dPrimePreTestIndivRuns);
dPrimePreTestSubjectsRows = dPrimePreTestSubjectsRows';

% dPrimePostTestIndivRuns = dPrimePostTestIndivRuns(:,1,:);
% dPrimePostTestSubjectsRows = squeeze(dPrimePostTestIndivRuns);
% dPrimePostTestSubjectsRows = dPrimePostTestSubjectsRows';

dPrimePreTestAvgSE = std(dPrimePreTestSubjectsRows,0,1)/sqrt(length(subjects));
% dPrimePostTestAvgSE = std(dPrimePostTestSubjectsRows,0,1)/sqrt(length(subjects));

% cat everything
%dPrimeIndivALL = [dPrimePreTestSubjectsRows dPrimeSubjectsRows dPrimePostTestSubjectsRows];
dPrimeIndivALL = [dPrimePreTestSubjectsRows dPrimeSubjectsRows]; %for analysis without posttest
%dPrimeIndivALLSE = [dPrimePreTestAvgSE dPrimeTrainingAvgSE dPrimePostTestAvgSE];
dPrimeIndivALLSE = [dPrimePreTestAvgSE dPrimeTrainingAvgSE];
dPrimeAvgAll = mean(dPrimeIndivALL,1);

clearvars -except dPrimeIndivALL dPrimeIndivALLSE dPrimeAvgAll *p subjects
%% Plotting 

% individual subjects with average performance overlayed

numSessions = size(dPrimeIndivALL,2);
for i = 1:length(subjects)
    p = plot(1:numSessions, dPrimeIndivALL(i,:),...
        'Color', [.862 .862 .862],...
        'Marker', 'o',...
        'MarkerSize', 1.5,...
        'LineWidth', 1);
%     p.Color(4) = 0.8;
    hold on
end

hold on

errorbar(1:numSessions,dPrimeAvgAll, dPrimeIndivALLSE,...
    'Marker', 'o',...
    'Color', 'k',...
    'LineWidth', 1.5,...
    'MarkerFaceColor','k');
    
    title('Performance on Training Stimuli');

    ylabel('D-Prime');
    ylim([0,4.5]);
    xlim([0.5,(numSessions+.5)]);
    set(gca, 'XTick', 1:1:numSessions, 'YTick', 0:1:4, 'box', 'off',...
        'FontSize', 20);    
    axis square

%% Averaging training stimuli of first 3 pretest sessions and subsequent training sessions

dPrimeAvgPre = mean(dPrimeAvgAll(1:3));
dPrimeAvgPrePlusTrain = [dPrimeAvgPre dPrimeAvgAll(4:end)];
dPrimeAvgPreSE = mean(dPrimeIndivALLSE(1:3));
dPrimeAvgPrePlustTrainSE = [dPrimeAvgPreSE dPrimeIndivALLSE(4:end)];

dPrimeIndivPre = dPrimeIndivALL(:,1:3);
dPrimeIndivPre = mean(dPrimeIndivPre,2);
dPrimeIndivPreSE = dPrimeIndivALLSE(:,1:3);
dPrimeIndivPreSE = mean(dPrimeIndivPreSE,2);

dPrimeIndivPrePlusTrain = [dPrimeIndivPre dPrimeIndivALL(:,4:5)];


numSessions = size(dPrimeAvgPrePlusTrain,2);

for i = 1:length(subjects)
    p = plot(1:numSessions, dPrimeIndivPrePlusTrain(i,:),...
        'Color', [.862 .862 .862],...
        'Marker', 'o',...
        'MarkerSize', 1.5,...
        'LineWidth', 1.5);
%     p.Color(4) = 0.8;
    hold on
end

hold on

errorbar(1:numSessions,dPrimeAvgPrePlusTrain, dPrimeAvgPrePlustTrainSE,...
    'Marker', 'o',...
    'Color', 'k',...
    'LineWidth', 1.5,...
    'MarkerFaceColor','k');
    
    title('Performance on Training Stimuli');

    ylabel('D-Prime');
    ylim([0,4.5]);
    xlim([0.5,(numSessions+.5)]);
    xticklabels({'PreTest', 'Training 1', 'Training 2'})
    set(gca, 'XTick', 1:1:numSessions, 'YTick', 0:1:4, 'box', 'off',...
        'FontSize', 20);    
    axis square
