

%% run pre & post Test Analysis
if exist('/home/viscog/GitHub/dichoptic_gaming', 'dir')
    homeDr = '/home/viscog/GitHub/dichoptic_gaming';
else
    homeDr = 'C:\Users\Rebecca Esquenazi\DichopticGaming\dichoptic_gaming';
end
resDr = fullfile(homeDr, 'Results', 'PostTraining_Data');

OD_PreTest_Analysis_AllRuns
cd(resDr)
OD_PostTest_Analysis_AllRuns


%% Set up matrices

% create matrix of Pre Post dprime scores where subjects are on rows and 
% pre(1) and post(2) are on columns, and pretest condition is in third 
% dimension.

% Pretest conditions:
% 1. regular stimulus conditions
% 2. monocular viewing (switches eyes randomly)
% 3. flipping eyes. (Right eye image now in left eye and left eye img
% in right eye)
% 4. 1/f noise stimuli

for i = 1:numPreTestConds
    dPrimePrePost(:,:,i) = [dPrimePreTestAllRuns(:,i) dPrimePostTestAllRuns(:,i)];
    dPrimePrePostSE(:,:,i) = [dPrimePreTestSEAllRuns(:,i) dPrimePostTestSEAllRuns(:,i)];
end

%% Plotting individual subjects

colList = [0 0.4470 0.7410; 0.6350 0.0780 0.1840; 0.9290 0.6940 0.14; 0.4660 0.6740 0.1880];
preTestCondOrder = {'Training','Monocular','Switching Filter Eye of Origin','Noise Mask'};
SubjectsList = {'S1', 'S2', 'S3','S4','S5'};

for s = 1:numPreTestConds
    figure(s)
    sgtitle([preTestCondOrder{s}])
    for i = 1:length(subjects)
        subplot(1,length(subjects),i)
        e(s) = errorbar(1:size(dPrimePrePost,2), [dPrimePrePost(i,1,s) dPrimePrePost(i,2,s)] ,...
            [dPrimePrePostSE(i,1,s) dPrimePrePostSE(i,2,s)],...
            'Marker', 'o',...
            'MarkerFaceColor', colList(s,:),...
            'LineWidth', 1.5,...
            'Color', colList(s,:));
                
        ylabel('D-Prime');
        ylim([0,4.5]);
        xlim([0.5,2.5]);
        xticks([1 2]);
        xticklabels({'Pre', 'Post'});
        title([SubjectsList{i}]);
        axis square
        set(gca, 'box', 'off', 'FontSize',16, 'YTick', 0:1:4);
        
        hold on
        f = errorbar(1:size(dPrimePrePost,2), [dPrimePrePost(i,1,1) dPrimePrePost(i,2,1)],...
            [dPrimePrePostSE(i,1,1) dPrimePrePostSE(i,2,1)],...
            'Marker','o',...
            'MarkerFaceColor', 'k',...
            'LineWidth', 1.5,...
            'Color', 'k');
    end
end


%% Plotting Averages

% get correct averages and standard errors
dPrimePrePostAvg = squeeze(mean(dPrimePrePost,1)); dPrimePrePostAvg = dPrimePrePostAvg';
dPrimePrePostAvgSE = squeeze(std(dPrimePrePost,1)/sqrt(length(subjects))); dPrimePrePostAvgSE = dPrimePrePostAvgSE';

for s = 1:numPreTestConds
    figure(s)
    
    e(s) = errorbar(1:size(dPrimePrePostAvg,2), [dPrimePrePostAvg(s,1) dPrimePrePostAvg(s,2)],...
        [dPrimePrePostAvgSE(s,1) dPrimePrePostAvgSE(s,2)],...
        'Marker','o',...
        'MarkerFaceColor', colList(s,:),...
        'LineWidth', 1.5,...
        'Color', colList(s,:));
    
    ylabel('D-Prime');
    ylim([0,4.5]);
    xlim([0.5, 2.5]);
    xticks([1 2]);
    xticklabels({'Pre-Test', 'Post-Test'});    
    title([preTestCondOrder{s} ': Averaged Results']);
    axis square
    set(gca, 'box', 'off', 'FontSize',18, 'YTick', 0:1:4);
    
    hold on
    f = errorbar(1:size(dPrimePrePostAvg,2), [dPrimePrePostAvg(1,1) dPrimePrePostAvg(1,2)],...
        [dPrimePrePostAvgSE(1,1) dPrimePrePostAvgSE(1,2)],...
        'Marker','o',...
        'MarkerFaceColor', 'k',...
        'LineWidth', 1.5,...
        'Color', 'k');
    
    legend({preTestCondOrder{s}, 'Training'},  'Location', 'NorthWest')
    legend boxoff
end

%%
% overlaying indiv. averages in training pre post with average training
% pre/post

for i = 1:length(subjects)
    plot(1:size(dPrimePrePost,2),[dPrimePrePost(i,1,1) dPrimePrePost(i,2,1)],...
        'Marker', 'o',...
        'MarkerSize',2.5,...
        'Color', [0.862 0.862 0.862],...
        'LineWidth', 1,...
        'MarkerFaceColor', [0.862 0.862 0.862]);
    
    ylabel('D-Prime');
    ylim([0,4.5]);
    xlim([0.5, 2.5]);
    xticks([1 2]);
    xticklabels({'Pre-Test', 'Post-Test'});    
    title('Training Stimuli Performance During Pre/Post Test');
    axis square
    set(gca, 'box', 'off', 'FontSize',18, 'YTick', 0:1:4);
    hold on
end

hold on
e = errorbar(1:size(dPrimePrePost,2),[dPrimePrePostAvg(1,1) dPrimePrePostAvg(1,2)],...
    [dPrimePrePostAvgSE(1,1) dPrimePrePostAvgSE(1,2)],...
    'Marker','o',...
    'Color','k',...
    'LineWidth',1.5,...
    'MarkerFaceColor','k');
