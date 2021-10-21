%% Object Recognition Experiment
% Part of Dichoptic Gaming Project
% Participant is prompted with the name of an object to look for within
% a distorted scene. They decide whether object is present or absent. In
% condition 1, the prompted object and the object within the scene match.
% In condition 2, the prompted object and the object within the scene do
% not match.

%% Clear everything

clear all;
close all;
sca;

%% Directories & Input

try
    cd('/home/viscog/GitHub/dichoptic_gaming/');  homeDr = pwd;
catch
    homeDr = pwd;
end

imageDir{1} = fullfile(homeDr,'filtered_scenes_objects_present_newPar');
imageDir{2} = fullfile(homeDr, 'filtered_scenes_objects_present_pinkNoise');
imageDir{3} = fullfile(homeDr,'filtered_scenes_objects_absent_newPar');

%get participant input
while 1
    participantname = input('Participant ID:   ', 's');
    if ~(isempty(participantname))
        break;
    end
end
    
savefilename = [participantname, '_', datestr(now, 'hh_MMPM_mmm_dd_yy')];
addpath('/home/viscog/GitHub/Nonius');
addpath('/home/viscog/GitHub/dichoptic_gaming/Functions');
cd(homeDr);

%% Keyboard
KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE');
presentKey = KbName('f');
absentKey = KbName('j');

%% Trial Variables
nTrials = 500; % number of trials
nBlocks = 10;
nConds = 2; % number of conditions (1 = correct obj, 2 = incorrect obj)
nTrialPerCond = nTrials / nConds;
numPreTests = 5;
RefreshRate = 60;
stimDur = 2;
pauseDur = 0.5; % interimage gap of 0.5s
endoftrialpauseDur = 0.5;
fixSize = 50;
driftSpeed = [.3 .75] ; % drifts at a max speed of 1 pix per frame
magSpeed = [-.5 .5] ; % expansion or contraction at a max speed of 1 pix per frame
rng('shuffle'); % sets different seed for condition randomization

%% Trial Sounds
InitializePsychSound;
pahandle = PsychPortAudio('Open', [], [], [], [], 1);

Fs = 10000;
beepLengthSecs = .4;
correctBeep = MakeBeep(400, beepLengthSecs, Fs);
wrongBeep = MakeBeep(150, beepLengthSecs, Fs);
sound(1); % open the mex file, avoids delay first time sound is called in the program
%% Determine PreTest Condition Order

tmp = randperm(numPreTests);
preTestCond = repelem(tmp,(nTrials)/5); % must be a multiple of 5 because there are 5 preTests

%% Scene Files

objectsList = get_objectlist();

for i = 1:length(imageDir)
    files(i).dir = dir(fullfile(imageDir{i}, '*.png'));
    templateLR(i).files = unique(regexprep({files(i).dir.name}, '[LR].png', ''));
    fileNames{1,i}= cell(length(templateLR(i).files), 2);
    fileNames{1,i}(:,1) = cellfun(@(x) [x 'L.png'], templateLR(i).files, 'UniformOutput', false);
    fileNames{1,i}(:,2) = cellfun(@(x) [x 'R.png'], templateLR(i).files, 'UniformOutput', false);
end

order = repmat(1:nConds, 1, nTrialPerCond);
order = order(randperm(length(order)));

suppressionCondOrder = order(randperm(length(order)));

%% Fill Paradigm Structure

fileObject = cellfun(@(x) regexprep(x(:,1), '_Scene.*', ''), fileNames, 'UniformOutput', false);

paradigm = cell(nTrials, 6);
paradigm(:,1) = num2cell(order(:));
paradigm(:,2) = num2cell(suppressionCondOrder(:));
paradigm(:,3) = num2cell(preTestCond);
paradigm(:,4) = objectsList(randsample(1:length(objectsList), nTrials, true));


for i = 1:nTrials
    prompt = paradigm{i,4};
    
    if paradigm{i,3} == 4 % for pinkNoise preTest condition
        nImgDir = 2;
    elseif paradigm{i,3} == 5  % for suppression preTest condition    
       imgDrP = 1; %objects present
       imgDrA = 3; %objects absent
       
       findObj = strcmp(fileObject{imgDrP}, prompt);
       
       if paradigm{i,2} ==1 % if 1 in column 2 of paradigm, object present in left eye & absent in right
           
           if paradigm{i,1} == 1 %correct condition
               leftEye = {fileNames{imgDrP}{findObj,1}}';
               rightEye = {fileNames{imgDrA}{findObj,2}}';
           else %incorrect condition
               leftEye = {fileNames{imgDrP}{~findObj,1}}';
               rightEye = {fileNames{imgDrA}{~findObj,2}}';
           end

       else 
           if paradigm{i,1} == 1 %correct condition
               leftEye = {fileNames{imgDrA}{findObj,1}}'; % if 2, object absent in left eye and present in right
               rightEye = {fileNames{imgDrP}{findObj,2}}';
           else %incorrect condition
               leftEye = {fileNames{imgDrA}{~findObj,1}}'; % if 2, object absent in left eye and present in right
               rightEye = {fileNames{imgDrP}{~findObj,2}}';
           end
       end
       
       matchImages = [leftEye rightEye];
       
       paradigm(i,5:6) = matchImages(randsample(size(matchImages,1),1),:);
           
    else 
        nImgDir = 1; 
    end
    

    if paradigm{i,3} ~= 5
        
        imageMatch = strcmp(fileObject{nImgDir}, prompt);
        
        if paradigm{i,1} == 1 % correct condition
            matchImages = fileNames{nImgDir}(imageMatch,:);
        else % incorrect condition (2)
            matchImages = fileNames{nImgDir}(~imageMatch,:);
        end
        
        paradigm(i,5:6) = matchImages(randsample(size(matchImages,1),1),:);
    end
    % Remove underscore from object name
    objectName = paradigm{i,4};
    tmp = regexp(objectName, '_');
    if ~isempty(tmp)
        objectName(tmp) = ' ';
        paradigm{i,4} = objectName;
    end
end

%% Calculate Image Drifts

for fl = 1:size(paradigm,1)
    % extract the scene , scFac, loc, and rotation numbers of each image
    tmp = regexp(paradigm{fl,5},'\d*','Match');
    
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

[offsetL, offsetR] = alignment_task('cornermatch', participantname);

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

[window, windowRect] = Screen('OpenWindow', scrn, grey, [], [], [], stereomode);
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

if nTrials>length(files(1).dir)
    error('not enough files for the requested number of trials');
end

%% Trial Instructions

instructionsText = ['Instructions! \n\nPlease decide whether the prompted\n object is present within the scene.',...
    '\n\nPress "f" for "YES" \nor\n "j" for "NO".',...
    '\n\nAt the end of each trial you will hear a tone: \n A high pitch tone means your answer was correct.\nLow pitch is incorrect.'...
    '\n\nPress any key to start'];

ListenChar(-1); HideCursor;

% show trial instructions
Screen('SelectStereoDrawBuffer', window, 0);
DrawFormattedText(window, instructionsText,...
    windowRect(3)/4 + offsetL(1), windowRect(4)/4 + offsetL(2), black, [], 1);

Screen('SelectStereoDrawBuffer', window, 1);
DrawFormattedText(window, instructionsText,...
    windowRect(3)/4 + offsetR(1), windowRect(4)/4 + offsetR(2), black, [], 1)
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
    
    %% Make PreTest Conditions
    
    % A1 reads in the L eye image corresponding to the correct condition and
    % image number. A2 reads in the corresponding R eye image to A1.
    
    % Pretest conditions:
    % 1. regular stimulus conditions
    % 2. monocular viewing (switches eyes randomly)
    % 3. flipping eyes. (Right eye image now in left eye and left eye img
    % in right eye)
    % 4. 1/f noise stimuli
    % 5. switching which eye object is present or absent in
    
    switch paradigm{trl,3}
        case 1 % Regular stimulus conditions

            % read in left eye image
            A1 = imread(fullfile(imageDir{1}, paradigm{trl,5}));
            
            % read in right eye image
            A2 = imread(fullfile(imageDir{1}, paradigm{trl,6}));
            
        case 2
            % Monocular viewing
            index = randi(2,1,(nTrials/5));
            for mon = 1:length(index)
                if index(mon) == 1
                    A1 = imread(fullfile(imageDir{1}, paradigm{trl,5})); %left eye
                    A2 = uint8(grey.*ones(800,800)); %right eye
                else
                    A1 = uint8(grey.*ones(800,800)); %left eye
                    A2 = imread(fullfile(imageDir{1}, paradigm{trl,6})); %right eye
                end
            end
            
        case 3
            % Flipping L & R eyes
            A1 = imread(fullfile(imageDir{1}, paradigm{trl,6})); %left eye
            A2 = imread(fullfile(imageDir{1}, paradigm{trl,5}));%right eye
            
        case 4
            % 1/f Noise
            A1 = imread(fullfile(imageDir{2}, paradigm{trl,5})); %left eye
            A2 = imread(fullfile(imageDir{2}, paradigm{trl,6})); %right eye
            
        case 5
            %switchng which eye object is present or absent in
            % imageDir{1} = objects present & imageDir{3} = objects absent
            
           if paradigm{trl,2} == 1 %object present in left eye and absent in right
               A1 = imread(fullfile(imageDir{1}, paradigm{trl,5})); %left eye
               A2 = imread(fullfile(imageDir{3}, paradigm{trl,6})); %right eye
               
           else % object absent in the left eye and present in the right
               A1 = imread(fullfile(imageDir{3}, paradigm{trl,5})); %left eye
               A2 = imread(fullfile(imageDir{1}, paradigm{trl,6}));% right eye
           end
    end
    
    
    %% Display name of prompting object
    
    % selecting stereobuffer 0 fills the left eye (for stereomode 4)
    Screen('SelectStereoDrawBuffer', window, 0);
    DrawFormattedText(window, paradigm{trl,4}, windowRect(3)/2-(20* length(paradigm{trl,4})) + offsetL(1), ...
        windowRect(4)/2 + offsetL(2),  [0 0 0], [], 1);
    Screen('FrameRect', window, black, [screenCtr(1)-boxSize/2, screenCtr(2)-boxSize/2, screenCtr(1)+boxSize/2, screenCtr(2)+boxSize/2] + [offsetL offsetL], penWidth);
    
    % selecting stereobuffer 1 fills the right eye (for stereomode 4)
    Screen('SelectStereoDrawBuffer', window, 1);
    DrawFormattedText(window, paradigm{trl,4}, windowRect(3)/2-(20* length(paradigm{trl,4})) + offsetR(1), ...
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
            if keyCode(presentKey) == 1 % if the object is correct (aka condition 1)
                KB_hit_key = presentKey;
                keypressed = 1;
                time_stamp_KBhit = keysecs;
                if paradigm{trl,1} == 2 % make incorrect feedback beep if participant says object absent
                    %sound(wrongBeep, Fs);
                    
                    % load and play wrongBeep
                    PsychPortAudio('FillBuffer', pahandle, wrongBeep);
                    t1 = PsychPortAudio('Start', pahandle);
                    
                    correct = 0;
                else
                    %sound(correctBeep, Fs); % make correct feedback beep if participant says object present
                    % load and play correctBeep
                    PsychPortAudio('FillBuffer', pahandle, correctBeep);
                    t1 = PsychPortAudio('Start', pahandle);
                    
                    correct = 1;
                end
            elseif keyCode(absentKey) == 1 % if the object is incorrect (aka condition 2)
                KB_hit_key = absentKey;
                keypressed = 1;
                time_stamp_KBhit = keysecs;
                if paradigm{trl,1} == 1 % make incorrect feedback beep if participant says object present
                    %sound(wrongBeep, Fs);
                    % load and play wrongBeep
                    PsychPortAudio('FillBuffer', pahandle, wrongBeep);
                    t1 = PsychPortAudio('Start', pahandle);
                    correct = 0;
                else
                    %sound(correctBeep, Fs); % make correct feedback beep if participant says object absent
                    % load and play correctBeep
                    PsychPortAudio('FillBuffer', pahandle, correctBeep);
                    t1 = PsychPortAudio('Start', pahandle);
                    correct = 1;
                end
                
                % if participant wants presses escapeKey, close screen and
                % save all data from trials they have done so far
            elseif keyCode(escapeKey) == 1
                ListenChar; Screen('CloseAll');ShowCursor; clear mex;
                savefilepath = fullfile(homeDr, 'Results', 'PreTest_Data','SP_21', [savefilename '.mat']);
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
    rObj(trl).condition = paradigm{trl,1}; % object correct (1) or incorrect (2)
    rObj(trl).obLReye = paradigm{trl,2}; %object in left eye and absent in right (1), or in right eye and absent in left (2) 
    rObj(trl).preTestCond = paradigm{trl,3}; % corresponds to regular training condition
    rObj(trl).filename = paradigm{trl,5};
    rObj(trl).object = paradigm{trl,4};
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
    
    if mod(trl,nTrials/nBlocks) == 0
        % Calculate percent correct
        if trl >= 10
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
        if trl==nTrials
            Screen('SelectStereoDrawBuffer', window, 0);
            DrawFormattedText(window,'\n\nCongrats, youre finished!\n Press any key to exit\n\n', ...
                windowRect(3)/2 + offsetL(1)-(20*length(paradigm{trl,3})), windowRect(4)/2 + offsetL(2) + (h*50),...
                black, [], 1);
            
            Screen('SelectStereoDrawBuffer', window, 1);
            DrawFormattedText(window,'\n\nCongrats, youre finished!\n Press any key to exit\n\n', ...
                windowRect(3)/2 + offsetR(1)- (20* length(paradigm{trl,3})), windowRect(4)/2 + offsetR(2)+ (h*50),  black, [], 1);
            Screen('Flip', window);
            FlushEvents;
            GetChar;
        else
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
end


cd(homeDr);
ListenChar; ShowCursor;
savefilepath = fullfile(homeDr, 'Results', 'PreTest_Data', 'SP_21', [savefilename '.mat']);
save(savefilepath, '-v7.3'); % save everything
PsychPortAudio('Close', pahandle);
Screen('CloseAll'); clear mex
cd(homeDr)