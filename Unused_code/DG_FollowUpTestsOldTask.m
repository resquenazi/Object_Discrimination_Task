%% Directories & Input

try
    cd('/home/viscog/GitHub/dichoptic_gaming/');  homeDr = pwd;
catch
    homeDr = pwd;
end

imageDir{1} = fullfile(homeDr,'filtered_scenes_objects_present_newPar'); % image directory for new filter (2), P = object present
imageDir{2} = fullfile(homeDr,'filtered_scenes_objects_absent_newPar'); % image directory for new filter (2), A = object absent
imageDir{3} = fullfile(homeDr,'filtered_scenes_objects_present_oldPar'); % image directory for old filter (1)
imageDir{4}= fullfile(homeDr,'filtered_scenes_objects_absent_oldPar'); %image directory for old filter (1)


savefilename = [participantname, '_', datestr(now, 'hh_MMPM_mmm_dd_yy')];
addpath('/home/viscog/GitHub/Nonius');
cd(homeDr);
%% Keyboard
KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE');
presentKey = KbName('f');
absentKey = KbName('j');

%% Trial Variables
nTrials = 200; % number of trials
nBlocks =5; 
nConds = 2; % number of conditions (1 = obj present, 2 = obj absent)
nTrialPerCond = nTrials/nConds;
numFollowUpTests = 2;% 1: new filt, 2: old filt
RefreshRate = 60;
stimDur = 2;
pauseDur = 0.5; % interimage gap of 0.5s
endoftrialpauseDur = 0.5;
fixSize = 50;
driftSpeed = [.3 .75] ; % drifts at a max speed of 1 pix per frame
magSpeed = [-.5 .5] ; % expansion or contraction at a max speed of 1 pix per frame
rng('shuffle'); % sets different seed for condition randomization

%% Trial Sounds
Fs = 8192;
beepLengthSecs = .3;
correctBeep = MakeBeep(700, beepLengthSecs, Fs);
wrongBeep = MakeBeep(300, beepLengthSecs, Fs);
sound(1); % open the mex file, avoids delay first time sound is called in the program

%% Determine PreTest Condition Order

tmp = randperm(numFollowUpTests);
followUpTestCond = repelem(tmp,(nTrials)/2); % must be a multiple of 2 because there are 2 follow up tests
% FollowUpTestCond 1 : New Filter. FollowUpTestCond 2: Old Filter

%% Scene Files

objectsList = get_objectlist();

for i = 1:size(imageDir,2)
    files{i} = dir(fullfile(imageDir{i}, '*.png'));
    templateLR{i} = unique(regexprep({files{i}.name}, '[LR].png', ''));
    fileNames{i} = cell(length(templateLR{i}), 2);
    fileNames{i}(:,1) = cellfun(@(x) [x 'L.png'], templateLR{i}, 'UniformOutput', false);
    fileNames{i}(:,2) = cellfun(@(x) [x 'R.png'], templateLR{i}, 'UniformOutput', false);
end

order = repmat(1:nConds, 1, nTrialPerCond);
order = order(randperm(length(order)));

%% Fill Paradigm Structure

fileObject = cellfun(@(x) regexprep(x(:,1), '_Scene.*', ''), fileNames, 'UniformOutput', false);

paradigm = cell(nTrials, 6);
paradigm(:,1) = num2cell(order(:));
paradigm(:,2) = num2cell(followUpTestCond);
paradigm(:,3) = objectsList(randsample(1:length(objectsList), nTrials, true));

for i = 1:nTrials
    prompt = paradigm{i,3};
    
    if paradigm{i,1}==1 && paradigm{i,2}==1
        paradigm{i,6} = imageDir{1};
    elseif paradigm{i,1} ==2 && paradigm{i,2}==1
        paradigm{i,6} = imageDir{2};
    elseif paradigm{i,1}==1 && paradigm{i,2}==2
        paradigm{i,6} = imageDir{3};
    elseif paradigm{i,1}==2 && paradigm{i,2}==2
        paradigm{i,6} = imageDir{4};
    end
           
    switch paradigm{i,2}
        case 1
            if paradigm{i,1} ==1 % objects present condition for new filt
                nImgDir = 1;
            else % objects absent condition for new filt
                nImgDir = 2;
            end
            
            imageMatch = strcmp(fileObject{nImgDir}, prompt);
            matchImages = fileNames{nImgDir}(imageMatch,:);
            paradigm(i,4:5) = matchImages(randsample(size(matchImages,1),1),:);
            
        case 2
            if paradigm{i,1} ==1 %objects present condition for old filt
                nImgDir = 3;
            else %objects absent condition for old filt
                nImgDir = 4;
            end
            
            imageMatch = strcmp(fileObject{nImgDir}, prompt);
            matchImages = fileNames{nImgDir}(imageMatch,:);
            paradigm(i,4:5) = matchImages(randsample(size(matchImages,1),1),:);
            
            % Remove underscore from object name
            objectName = paradigm{i,3};
            tmp = regexp(objectName, '_');
            if ~isempty(tmp)
                objectName(tmp) = ' ';
                paradigm{i,3} = objectName;
            end
    end
end

%% Calculate Image Drifts

for fl = 1:size(paradigm,1)
    % extract the scene , scFac, loc, and rotation numbers of each image
    tmp = regexp(paradigm{fl,4},'\d*','Match');
    
    % create structure with the following fields:sceneNum, scFac, xLoc,
    % yLoc, Rot, driftAng, driftSpeed, magSpeed, driftLoc, and magFac
    
    fObj(fl).sceneNum = str2num(tmp{1});
    fObj(fl).scFac = 1/(str2num(tmp{2})/10);
    fObj(fl).xLoc = str2num(tmp{3});
    fObj(fl).yLoc = str2num(tmp{4});
    fObj(fl).Rot = str2num(tmp{5});
    fObj(fl).driftAng = randi(360, 1);
    fObj(fl).driftSpeed = driftSpeed(1) + (driftSpeed(2)-driftSpeed(1)).*rand(1);
    fObj(fl).magSpeed = magSpeed(1) + (magSpeed(2)-magSpeed(1)).*rand(1);
    fObj(fl).driftLoc(:,1) = [floor(-stimDur*RefreshRate/2):ceil(stimDur *...
        RefreshRate/2)].* fObj(fl).driftSpeed * cos(fObj(fl).driftAng *pi/180);
    fObj(fl).driftLoc(:,2) = [floor(-stimDur*RefreshRate/2):ceil(stimDur *...
        RefreshRate/2)].*fObj(fl).driftSpeed * sin(fObj(fl).driftAng *pi/180);
    fObj(fl).magFac = [floor(-stimDur*RefreshRate/2):ceil(stimDur * ...
        RefreshRate/2)].*fObj(fl).magSpeed;
end

%% Alignment Task

if ~exist('offsetL','var') && ~exist('offsetR','var')
    [offsetL, offsetR] = alignment_task('cornermatch', participantname);
else
end
%% Initialize Screen
stereomode = 4;
screens = Screen('Screens');
scrn = max(screens);

Screen('Preference', 'Verbosity',0);
Screen('Preference','SkipSyncTests', 1);
Screen('Preference','VisualDebugLevel', 0);
Screen('Preference','SuppressAllWarnings', 1);
white = WhiteIndex(scrn);
black = BlackIndex(scrn);
grey = white / 2;


[window, windowRect] = Screen('OpenWindow', scrn, grey, [0 0 5120 1460], [], [], stereomode);
if RefreshRate~=Screen('NominalFrameRate', window)
    error('wrong refresh rate specified')
end
screenCtr = windowRect(3:4)/2;
Screen('Flip', window);
Screen('TextSize', window, 50);

boxSize = 800;
penWidth = 10;

%% Trial Background and Fixation Spot

% make one and one green red fixation spot
tmp = ones(fixSize, fixSize, 3); tmp(:,:, 1) = 255;
fixTexRed = Screen('MakeTexture', window, tmp);

tmp = ones(fixSize, fixSize, 3); tmp(:,:, 2) = 255;
fixTexGreen = Screen('MakeTexture', window, tmp);

% make gray background
grayTex = Screen('MakeTexture', window, grey.*ones(windowRect(4)/2, windowRect(3)/2));

if nTrials>size(files{1},1)
    error('not enough files for the requested number of trials');
end

%% Trial Instructions

ListenChar(-1); HideCursor;

% show trial instructions
Screen('SelectStereoDrawBuffer', window, 0);
DrawFormattedText(window, 'TRIAL INSTRUCTIONS\n\nIn each trial, you will be prompted with an object\n to look for within a scene.\nPlease decide whether that object is present within the scene.\nPress "f" for "YES" \nor\n "j" for "NO"\n\nPress any key to begin',...
    windowRect(3)/2 + offsetL(1)-600, windowRect(4)/2 + offsetL(2)-350, black, [], 1);

Screen('SelectStereoDrawBuffer', window, 1);
DrawFormattedText(window, 'TRIAL INSTRUCTIONS\n\nIn each trial, you will be prompted with an object\n to look for within a scene.\nPlease decide whether that object is present within the scene.\nPress "f" for "YES" \nor\n "j" for "NO"\n\nPress any key to begin',...
    windowRect(3)/2 + offsetR(1)-600, windowRect(4)/2 + offsetR(2)-350, black, [], 1)
Screen('Flip', window)
KbStrokeWait;

%% Beginning of Trials

for trl = 1:nTrials
    %% Display fixation spot
    
    Screen('SelectStereoDrawBuffer', window, 0);
    Screen('DrawTexture', window, fixTexRed, [], CenterRect([0 0 fixSize fixSize], windowRect) + [offsetL offsetL]);
    Screen('FrameRect', window, black, [screenCtr(1)-boxSize/2, screenCtr(2)-boxSize/2, screenCtr(1)+boxSize/2, screenCtr(2)+boxSize/2] + [offsetL offsetL], penWidth);
    
    Screen('SelectStereoDrawBuffer', window, 1);
    Screen('DrawTexture', window, fixTexGreen, [], CenterRect([0 0 fixSize fixSize], windowRect) + [offsetR offsetR]);
    Screen('FrameRect', window, black, [screenCtr(1)-boxSize/2, screenCtr(2)-boxSize/2, screenCtr(1)+boxSize/2, screenCtr(2)+boxSize/2]  + [offsetR offsetR], penWidth);
    Screen('Flip', window);
    pause(pauseDur);
    
    %% Read in Correct Image Corresponding to FollowUp Condition
    
    % A1 reads in the L eye image corresponding to the correct condition and
    % image number. A2 reads in the corresponding R eye image to A1.
    
    % Follow Up Test Conditions
    % 1. New filter, old task (i.e. objects present (Cond 1) or objects
    % absent (cond 2)
    % 2. Old fitler, old task
    
    % read in left eye image
    A1 = imread(fullfile(paradigm{trl,6}, paradigm{trl,4}));
    
    %read in right eye image 
    A2 = imread(fullfile(paradigm{trl,6}, paradigm{trl,5}));
    
    %% Display name of prompting object
    
    % selecting stereobuffer 0 fills the left eye (for stereomode 4)
    Screen('SelectStereoDrawBuffer', window, 0);
    DrawFormattedText(window, paradigm{trl,3}, windowRect(3)/2-(20* length(paradigm{trl,3})) + offsetL(1), ...
        windowRect(4)/2 + offsetL(2),  [0 0 0], [], 1);
    Screen('FrameRect', window, black, [screenCtr(1)-boxSize/2, screenCtr(2)-boxSize/2, screenCtr(1)+boxSize/2, screenCtr(2)+boxSize/2] + [offsetL offsetL], penWidth);
    
    % selecting stereobuffer 1 fills the right eye (for stereomode 4)
    Screen('SelectStereoDrawBuffer', window, 1);
    DrawFormattedText(window, paradigm{trl,3}, windowRect(3)/2-(20* length(paradigm{trl,3})) + offsetR(1), ...
        windowRect(4)/2 + offsetR(2),  [0 0 0], [], 1);
    Screen('FrameRect', window, black, [screenCtr(1)-boxSize/2, screenCtr(2)-boxSize/2, screenCtr(1)+boxSize/2, screenCtr(2)+boxSize/2] + [offsetR offsetR], penWidth);
    
    Screen('Flip', window);
    pause(pauseDur);
    
    %% Go to a blank screen
    Screen('SelectStereoDrawBuffer', window, 0);
    Screen('DrawTexture', window, grayTex);
    Screen('FrameRect', window, black, [screenCtr(1)-boxSize/2, screenCtr(2)-boxSize/2, screenCtr(1)+boxSize/2, screenCtr(2)+boxSize/2] + [offsetL offsetL], penWidth);
    
    Screen('SelectStereoDrawBuffer', window, 1);
    Screen('DrawTexture', window, grayTex);
    Screen('FrameRect', window, black, [screenCtr(1)-boxSize/2, screenCtr(2)-boxSize/2, screenCtr(1)+boxSize/2, screenCtr(2)+boxSize/2] + [offsetR offsetR], penWidth);
    Screen('Flip', window);
    
    %% Incorporate drift/magFac to trial
    
    startTime = GetSecs;
    keypressed = 0;
    stimstillon = 1;
    frm = 1;
    
     while keypressed == 0
        if stimstillon ==1
            if frm>length(fObj(trl).magFac)
                Screen('CloseAll'); ListenChar;
                error('Run out of frames');
            end
            
            [rect] = CenterRect([1 1 512 512],[1 1 size(A1)]);
            
            % offset the image location by shifting it to the ending drift
            % location
            [rect] = OffsetRect(rect,fObj(trl).driftLoc(frm, 1), fObj(trl).driftLoc(frm, 2));
            
            % push the image to the left, right, up, or down by using
            % magFac coords
            rect = round(InsetRect(rect, fObj(trl).magFac(frm), fObj(trl).magFac(frm)));
            frm = frm+1;
            
            while min(rect(:))<1
                rect = rect+1;
            end
            while max(rect(:))>length(A1)
                rect = rect -1;
            end
            
            imgTex1 = Screen('MakeTexture', window, A1(rect(1):rect(3), rect(2):rect(4)));
            imgTex2 = Screen('MakeTexture', window, A2(rect(1):rect(3), rect(2):rect(4)));
            
            %% Show participant image
            
            Screen('SelectStereoDrawBuffer', window, 0);
            Screen('DrawTexture', window, imgTex1,[], [screenCtr(1)-boxSize/2, screenCtr(2)-boxSize/2, screenCtr(1)+boxSize/2, screenCtr(2)+boxSize/2] + [offsetL offsetL]);
            Screen('FrameRect', window, black, [screenCtr(1)-boxSize/2, screenCtr(2)-boxSize/2, screenCtr(1)+boxSize/2, screenCtr(2)+boxSize/2] + [offsetL offsetL], penWidth);
            
            Screen('SelectStereoDrawBuffer', window, 1);
            Screen('DrawTexture', window, imgTex2, [], [screenCtr(1)-boxSize/2, screenCtr(2)-boxSize/2, screenCtr(1)+boxSize/2, screenCtr(2)+boxSize/2] + [offsetR offsetR]);
            Screen('FrameRect', window, black, [screenCtr(1)-boxSize/2, screenCtr(2)-boxSize/2, screenCtr(1)+boxSize/2, screenCtr(2)+boxSize/2]+ [offsetR offsetR], penWidth);
            
            Screen('Flip', window);
        end
   
        %% Record participant response
        
        [keyIsDown, keysecs, keyCode] = KbCheck;
        if keyIsDown
            if keyCode(presentKey) == 1 % if the object is present (aka condition 1)
                KB_hit_key = presentKey;
                keypressed = 1;
                time_stamp_KBhit = keysecs;
                if paradigm{trl,1} == 2 % make incorrect feedback beep if participant says object absent
                    sound(wrongBeep, Fs);
                    correct = 0;
                else
                    sound(correctBeep, Fs); % make correct feedback beep if participant says object present
                    correct = 1;
                end
            elseif keyCode(absentKey) == 1 % if the object is absent (aka condition 2)
                KB_hit_key = absentKey;
                keypressed = 1;
                time_stamp_KBhit = keysecs;
                if paradigm{trl,1} == 1 % make incorrect feedback beep if participant says object present
                    sound(wrongBeep, Fs);
                    correct = 0;
                else
                    sound(correctBeep, Fs); % make correct feedback beep if participant says object absent
                    correct = 1;
                end
                
                % if participant wants presses escapeKey, close screen and
                % save all data from trials they have done so far
            elseif keyCode(escapeKey) == 1
                ListenChar; Screen('CloseAll');ShowCursor; clear mex;
                savefilepath = fullfile(homeDr, 'Results', 'FollowUpTest_Data_OldTask',[savefilename '.mat']);
                save(savefilepath, '-v7.3'); % save everything
                return
            end
            KbReleaseWait; % wait until all keys on keyboard are released
            
            % if participant doesn't press key, don't do
            %anything (will go to next trial)
            keyIsDown = 0;
        end
        
        % if participant hasn't made a keyPress and the stimDur time has
        % ended, go to a blank gray screen and start next trial
        if (GetSecs-startTime)>stimDur && stimstillon == 1
            Screen('SelectStereoDrawBuffer', window, 0);
            Screen('DrawTexture', window, grayTex);
            Screen('FrameRect', window, black, [screenCtr(1)-boxSize/2, screenCtr(2)-boxSize/2, screenCtr(1)+boxSize/2, screenCtr(2)+boxSize/2]+ [offsetL offsetL], penWidth);
            
            Screen('SelectStereoDrawBuffer', window, 1);
            Screen('DrawTexture', window, grayTex);
            Screen('FrameRect', window, black, [screenCtr(1)-boxSize/2, screenCtr(2)-boxSize/2, screenCtr(1)+boxSize/2, screenCtr(2)+boxSize/2]+ [offsetR offsetR], penWidth);
            
            Screen('Flip', window);
            stimstillon = 0;
        end
    end
    
    pause(pauseDur);

    %% Record all trial data in rObj
    
    rObj(trl).trl = trl;
    rObj(trl).rt = time_stamp_KBhit-startTime;
    rObj(trl).resp = KB_hit_key;
    rObj(trl).correct = correct;
    rObj(trl).condition = paradigm{trl,1}; % object present or absent
    rObj(trl).followUpTestCond = paradigm{trl,2};
    rObj(trl).filename = fullfile(paradigm{trl,6}, paradigm{trl,4});
    rObj(trl).object = paradigm{trl,3};
    rObj(trl).sceneNum = fObj(trl).sceneNum;
    rObj(trl).scFac =  fObj(trl).scFac;
    rObj(trl).xLoc = fObj(trl).xLoc;
    rObj(trl).yLoc = fObj(trl).yLoc;
    fObj(trl).Rot = fObj(trl).Rot;
    rObj(trl).driftAng = fObj(trl).driftAng;
    rObj(trl).driftSpeed = fObj(trl).driftSpeed;
    rObj(trl).magSpeed = fObj(trl).magSpeed;
    save(savefilename, 'rObj', 'fObj')
   
    %% Display partcipant accuracy
    
    if mod(trl, nTrials/nBlocks) == 0
        % Calculate percent correct
        if trl>10
            scFac = [cat(1,rObj(:).scFac)];
            correct = [cat(1,rObj(:).correct)];
            scFacList = unique(scFac);
            for s = 1:length(scFacList)
                indx = find(scFac ==scFacList(s));
                perCorrect(s) = round( 100* sum(correct(indx))/length(indx), 1);
            end
            % display percent correct
            
            for h = 1:length(scFacList)
                Screen('SelectStereoDrawBuffer', window, 0);
                DrawFormattedText(window, ['Size = ', num2str(round(scFacList(h), 2)), ' % correct = ', num2str(round(perCorrect(h), 1)), '%'], ...
                    windowRect(3)/2 + offsetL(1) - (20*length(paradigm{trl,3})), windowRect(4)/2 + offsetL(2) + (h*50),  black, [], 1);
                
                Screen('SelectStereoDrawBuffer', window, 1);
                DrawFormattedText(window,  ['Size = ', num2str(round(scFacList(h), 2)), ' % correct = ', num2str(round(perCorrect(h), 1)), '%'], ...
                    windowRect(3)/2 + offsetR(1) - (20*length(paradigm{trl,3})), windowRect(4)/2 + offsetR(2) + (h*50), black, [], 1);
            end
        end

        %% Allow participant to pause for a break
        
        Screen('SelectStereoDrawBuffer', window, 0);
        DrawFormattedText(window,'\n\nPause for a break!\n Press any key to continue ....\n\n', ...
            windowRect(3)/2 + offsetL(1)-(20*length(paradigm{trl,3})), windowRect(4)/2 + offsetL(2) + (h*50),...
            black, [], 1);
        
        Screen('SelectStereoDrawBuffer', window, 1);
        DrawFormattedText(window,  '\n\nPause for a break!\n Press any key to continue ....\n\n', ...
            windowRect(3)/2 + offsetR(1)- (20* length(paradigm{trl,3})), windowRect(4)/2 + offsetR(2)+ (h*50),  black, [], 1);
        Screen('Flip', window);
        FlushEvents;
        GetChar;
    end
end
%% End the Experiment

clear A1 A2 absentKey ans beepLengthSecs boxSize correct correctBeep...
    driftSpeed endoftrialpauseDur fileNames fileObject files fixSize...
    fixTexGreen fixTexRed fl followUpTestCond frm Fs h imageDir...
    imageMatch imageTex1 imageTex2 indx KB_hit_key keyIsDown keypressed...
    keysecs magSpeed matchImages nBlocks nConds nImgDir nTrialPerCond...
    nTrials nTrialPerCond order pauseDur penWidth...
    perCorrect presentKey prompt s scFac scFacList startTime stimDur...
    stimstillon templateLR time_stamp_KBhit tmp trl wrongBeep



cd(homeDr);
ListenChar; ShowCursor;
savefilepath = fullfile(homeDr, 'Results', 'FollowUpTest_Data_OldTask', [savefilename '.mat']);
save(savefilepath, '-v7.3'); % save everything

Screen('CloseAll')

cd(homeDr)




