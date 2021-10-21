%% Combining dichoptic gaming follow up tests into one script

% DG_FollowUpTestsNewTask.m combines both old (unclipped & more spokes)
% filters with the New Task. This is to determine whether the task aids
% learning (or lack thereof) or the filter aids learning.
% DG_FollowUpTestsOldTask.m is the same as DG_FollowUpTestsNewTask.m,
% except the old task (i.e. objects present or absent) is tested. 

% written by BE Sept '19

clear all;
close all;
sca;

rng('Shuffle');
numFollowUpTests = [1 2];
testOrder = randperm(length(numFollowUpTests));

%% Participant Input
while 1
    participantname = input('Participant ID:   ', 's');
    if ~(isempty(participantname))
        break;
    end
end

%% Run each script in random order 

for i = 1:length(testOrder)
    
    if testOrder(i) == 1
        try
            DG_FollowUpTestsOldTask
        catch ME
            Screen('CloseAll')
            disp('Something went wrong with the DG_FollowUpTestsOldTaskScript')
            rethrow ME
        end
        clc
    else
        try
            DG_FollowUpTestsNewTask
        catch ME
            Screen('CloseAll')
            disp('Something went wrong with the DG_FollowUpTestsNewTaskScript')
            rethrow ME
        end
        clc
    end
end

%% End Experiment

disp('Experiment complete! Please Close Matlab');


