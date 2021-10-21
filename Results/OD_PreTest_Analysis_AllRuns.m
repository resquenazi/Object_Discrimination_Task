% Object discrimination analysis code for pre test
% averages over all 3 pre-test runs for each subject and creates
% d'prime and percent correct for each subject in a called
% dPrimePreTest(or pCorrectPreTest) that has subjects on rows and
% each pretest condition in the columns

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
numPreTestConds = 5;

for sid = 1:length(subjects)
    % loop through runs for this subject
    
    AllCorrect = [];
    AllCondition = [];
    AllPreTestCond = [];
    
    for i = 1:length(savefiles{sid})
        load(savefiles{sid}(i).name, 'rObj');
        AllCorrect = [AllCorrect rObj(:).correct];
        AllCondition = [AllCondition rObj(:).condition];
        AllPreTestCond = [AllPreTestCond rObj(:).preTestCond];
    end
    
    AllCorrect = AllCorrect';
    AllCondition = AllCondition';
    AllPreTestCond = AllPreTestCond';
    preTestCondList = unique(AllPreTestCond);

    for s = 1:length(preTestCondList)
        indx = AllPreTestCond == preTestCondList(s);
        nCorrectPreTest(sid,s) = sum(AllCorrect(indx));
        
        % percent correct for each session & binomial dist SE
        pCorrectPreTest(sid,s) = mean(AllCorrect(indx));
        pCorrectPreTestSE(sid,s) = sqrt(length(AllCorrect))...
            * pCorrectPreTest(sid,s) * (1 - pCorrectPreTest(sid,s))...
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
        
        dPrimePreTestAllRuns(sid,s) = zHit(sid,s) - zFA(sid,s);
        
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
        dPrimePreTestSEAllRuns(sid,s) = std(dPrimeSamp);
        
    end
end

