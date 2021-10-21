% Object Rec Results Calculation
% plots the probability correct for each object size - results in
% pCorrectScFac
% also plots probability correct for each session in total - results in
% pCorrectSession
cd('/home/viscog/GitHub/dichoptic_gaming/Results');
resDr = pwd;
list = dir('*.mat');
max_runs = 7;

subjects = {};
for i = 1:length(list)
    subjects{i} = list(i).name(1:2);
end

subjects = unique(subjects);

for i = 1:length(subjects)
    savefiles{i} = dir([subjects{i} '*.mat']);
end

% for each subject..
for sid = 1:length(subjects)
    pName = subjects{sid};
    pCorrectSession = zeros(1, length(savefiles{sid}));
    pCorrectSessionErr = zeros(1, length(savefiles{sid}));
    for i=1:length(savefiles{sid}) % the number of saved runs each subject has
        load(savefiles{sid}(i).name, 'rObj');
        scFac = cat(1,rObj(:).scFac);
        correct = cat(1,rObj(:).correct);
        scFacList = unique(scFac);
        pCorrectScFac = zeros(1, length(scFacList));
        pCorrectScFacErr = zeros(1, length(scFacList));
        % average for each scale factor
        for s = 1:length(scFacList)
            indx = scFac == scFacList(s);
            pCorrectScFac(s) = mean(correct(indx));
            pCorrectScFacErr(s) = sqrt(sum(indx) * pCorrectScFac(s) * (1-pCorrectScFac(s))) / sum(indx);
        end
        % average for each session
        pCorrectSession(i) = mean(correct);
        pCorrectSessionErr(i) = sqrt(length(correct) * pCorrectSession(i) * (1 - pCorrectSession(i))) / length(correct);
        
        figure(sid); hold on;
        subplot(1,length(savefiles{sid}),i);
        errorbar(scFacList, pCorrectScFac, pCorrectScFacErr, 'ko-', 'MarkerSize', 15);
        xlabel('object size');
        ylabel('probability correct');
        ylim([0.4 1]);
        title([pName ', run ' num2str(i)]);
    end
    
    figure(length(subjects)+1); hold on;
    subplot(1, length(subjects), sid);
    plot(1:length(pCorrectSession),pCorrectSession, 'ko-', 'MarkerFaceColor', 'k', 'MarkerSize',10); 
    errorbar(1:length(savefiles{sid}), pCorrectSession, pCorrectSessionErr, 'ko-', 'MarkerSize', 10);
    title(pName);
    xlabel('Experimental Session');
    ylabel('Probability Correct');
    ylim([0.4 1]);
    xlim([0.5 max_runs+.5])
    set(gca, 'XTick', 1:max_runs)
    hold on
    %saving scFac averages and overall averages
    savefilepath = [resDr filesep 'SessionStats' filesep pName num2str(length(savefiles{sid})) 'sessions.mat'];
    save(savefilepath,'pCorrectScFac','pCorrectSession'); 
end
