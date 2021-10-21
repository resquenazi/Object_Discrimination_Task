homeDr = 'C:\Users\Rebecca Esquenazi\GitHub\dichoptic_gaming';
resDr = fullfile(homeDr, 'Results', 'FollowUpTest_NewTask');
cd(resDr)
list = dir('*.mat');

nReps = 10000;

% Kelly's regexp magic to get subjet names
subjectList = regexprep({list.name}, '_.*', '');
subjects = unique(subjectList);

for i = 1:length(subjects)
    indx = strcmp(subjects{i}, subjectList);
    subjectFiles = list(indx);
    tmp = regexp({subjectFiles.name}, '.*(?<n>\d+)', 'names');
    order = cellfun(@(x) str2double(x.n), tmp);
    [~,orderIndx] = sort(order);
    savefiles{i} = subjectFiles(orderIndx);
    maxruns(i) = length(savefiles{i});
end


% Follow up test condition 1 = new filter; condition 2 = old filter

numFollowUpTests = 2;

for sid = 1:length(subjects)
    % loop through runs for this subject
    
    AllCorrect = [];
    AllCondition = [];
    AllFollowUpTestCond = [];
    
    for i = 1:length(savefiles{sid})
        load(savefiles{sid}(i).name, 'rObj');
        AllCorrect = [AllCorrect rObj(:).correct];
        AllCondition = [AllCondition rObj(:).condition]; % present absent
        AllFollowUpTestCond = [AllFollowUpTestCond rObj(:).followUpTestCond];
    end
    
    AllCorrect = AllCorrect';
    AllCondition = AllCondition';
    AllFollowUpTestCond = AllFollowUpTestCond';
    followUpTestCondList = unique(AllFollowUpTestCond);
    
    for s = 1:length(followUpTestCondList)
        indx = AllFollowUpTestCond == followUpTestCondList(s);
        nCorrectFollowUpTest(sid,s) = sum(AllCorrect(indx));
        
        % percent correct for each session & binomial dist SE
        pCorrectFollowUpTest(sid,s) = mean(AllCorrect(indx));
        pCorrectFollowUpTestSE(sid,s) = sqrt(length(AllCorrect))...
            * pCorrectFollowUpTest(sid,s) * (1 - pCorrectFollowUpTest(sid,s))...
            / length(AllCorrect);
        
        % hits and false alarms
        nHitTrials(sid,s) = sum(AllCondition(indx)==1);
        
        pHit(sid,s) = sum(AllCorrect(AllCondition == 1 & indx ==1))/nHitTrials(sid,s);
        
        nFATrials(sid,s) = sum(AllCondition(indx)==2);
        
        pFA(sid,s) = 1-sum(AllCorrect(AllCondition == 2 & indx==1))/nFATrials(sid,s);
        if pFA(sid,s) == 0
            pFA(sid,s) = 0.001;
        end
        
        % z scores for hits and false alarms
        zHit(sid,s) = norminv(pHit(sid,s));
        zFA(sid,s) = norminv(pFA(sid,s));
        
        dPrimeFollowUpTestNewTask(sid,s) = zHit(sid,s) - zFA(sid,s);
        
         %bootstrap to get error bars
        
        % Generate nReps fake 'hit' data sets based on pHit
        
        respHit = floor(rand(nHitTrials(sid,s),nReps))+ repmat(pHit(sid,s),...
            nHitTrials(sid,s),nReps);
        
        % hack: allow for at least one hit or miss
        pHitSamp = min(max(mean(respHit),1/nHitTrials(sid,s)),1-1/nHitTrials(sid,s));
        
        % Generate nReps fake 'FA' data sets based on pFA
        respFA = floor(rand(nFATrials(sid,s),nReps)+repmat(pFA(sid,s),...
            nFATrials(sid,s),nReps));
        
        % hack: allow for at least one correct rejection or false alarm
        pFASamp = min(max(mean(respFA),1/nFATrials(sid,s)),1-1/nFATrials(sid,s));
        
        % z scores and d-prime, as above
        zHitSamp = norminv(pHitSamp);
        zFASamp = norminv(pFASamp);
        dPrimeSamp = zHitSamp-zFASamp;
        
        % error bar is standard deviation of fake d-primes acros nReps
        dPrimeFollowUpTestNewTaskSE(sid,s) = std(dPrimeSamp);
    end
end
        

%% 
clearvars -except dPrimeFollowUpTestNewTask dPrimeFollowUpTestNewTaskSE

homeDr = 'C:\Users\Rebecca Esquenazi\GitHub\dichoptic_gaming';
resDr = fullfile(homeDr, 'Results', 'FollowUpTest_OldTask');
cd(resDr)
list = dir('*.mat');

nReps = 10000;

% Kelly's regexp magic to get subjet names
subjectList = regexprep({list.name}, '_.*', '');
subjects = unique(subjectList);

for i = 1:length(subjects)
    indx = strcmp(subjects{i}, subjectList);
    subjectFiles = list(indx);
    tmp = regexp({subjectFiles.name}, '.*(?<n>\d+)', 'names');
    order = cellfun(@(x) str2double(x.n), tmp);
    [~,orderIndx] = sort(order);
    savefiles{i} = subjectFiles(orderIndx);
    maxruns(i) = length(savefiles{i});
end


% Follow up test condition 1 = new filter; condition 2 = old filter

numFollowUpTests = 2;

for sid = 1:length(subjects)
    % loop through runs for this subject
    
    AllCorrect = [];
    AllCondition = [];
    AllFollowUpTestCond = [];
    
    for i = 1:length(savefiles{sid})
        load(savefiles{sid}(i).name, 'rObj');
        AllCorrect = [AllCorrect rObj(:).correct];
        AllCondition = [AllCondition rObj(:).condition]; % present absent
        AllFollowUpTestCond = [AllFollowUpTestCond rObj(:).followUpTestCond];
    end
    
    AllCorrect = AllCorrect';
    AllCondition = AllCondition';
    AllFollowUpTestCond = AllFollowUpTestCond';
    followUpTestCondList = unique(AllFollowUpTestCond);
    
    for s = 1:length(followUpTestCondList)
        indx = AllFollowUpTestCond == followUpTestCondList(s);
        nCorrectFollowUpTest(sid,s) = sum(AllCorrect(indx));
        
        % percent correct for each session & binomial dist SE
        pCorrectFollowUpTest(sid,s) = mean(AllCorrect(indx));
        pCorrectFollowUpTestSE(sid,s) = sqrt(length(AllCorrect))...
            * pCorrectFollowUpTest(sid,s) * (1 - pCorrectFollowUpTest(sid,s))...
            / length(AllCorrect);
        
        % hits and false alarms
        nHitTrials(sid,s) = sum(AllCondition(indx)==1);
        
        pHit(sid,s) = sum(AllCorrect(AllCondition == 1 & indx ==1))/nHitTrials(sid,s);
        
        nFATrials(sid,s) = sum(AllCondition(indx)==2);
        
        pFA(sid,s) = 1-sum(AllCorrect(AllCondition == 2 & indx==1))/nFATrials(sid,s);
        if pFA(sid,s) == 0
            pFA(sid,s) = 0.001;
        end
        
        % z scores for hits and false alarms
        zHit(sid,s) = norminv(pHit(sid,s));
        zFA(sid,s) = norminv(pFA(sid,s));
        
        dPrimeFollowUpTestOldTask(sid,s) = zHit(sid,s) - zFA(sid,s);
        
         %bootstrap to get error bars
        
        % Generate nReps fake 'hit' data sets based on pHit
        
        respHit = floor(rand(nHitTrials(sid,s),nReps))+ repmat(pHit(sid,s),...
            nHitTrials(sid,s),nReps);
        
        % hack: allow for at least one hit or miss
        pHitSamp = min(max(mean(respHit),1/nHitTrials(sid,s)),1-1/nHitTrials(sid,s));
        
        % Generate nReps fake 'FA' data sets based on pFA
        respFA = floor(rand(nFATrials(sid,s),nReps)+repmat(pFA(sid,s),...
            nFATrials(sid,s),nReps));
        
        % hack: allow for at least one correct rejection or false alarm
        pFASamp = min(max(mean(respFA),1/nFATrials(sid,s)),1-1/nFATrials(sid,s));
        
        % z scores and d-prime, as above
        zHitSamp = norminv(pHitSamp);
        zFASamp = norminv(pFASamp);
        dPrimeSamp = zHitSamp-zFASamp;
        
        % error bar is standard deviation of fake d-primes acros nReps
        dPrimeFollowUpTestOldTaskSE(sid,s) = std(dPrimeSamp);
    end
end
