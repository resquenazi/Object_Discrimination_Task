%ObjectRecognitionFourier;

clc; % clear command window
close all;
sca; % screen close all


while 1
    participantname = input('Participant ID:   ', 's');
    if ~(isempty(participantname))
        break;
    end
end


try
    cd('/home/viscog/GitHub/dichoptic_gaming/'); homeDr = pwd;
catch
    homeDr = pwd;
end

% condition = 1 is objects present

imageDir1{1} = fullfile(homeDr, 'filtered_scenes_objects_present_newPar');
imageDir1{2} = fullfile(homeDr, 'filtered_scenes_objects_absent_newPar');

imageDir2{1} = fullfile(homeDr, 'filtered_scenes_objects_present_pinkNoise');
imageDir2{2} = fullfile(homeDr,  'filtered_scenes_objects_absent_pinkNoise');

savefilename = [participantname, '_', datestr(now, 'hh_MMPM_mmm_dd_yy')];
fileName = datestr(now, 'yyyy-mm-dd-HH-MM-SS');
addpath('/home/viscog/GitHub/Nonius');
cd(homeDr);

%% Keys

KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE');
presentKey = KbName('f');
absentKey = KbName('j');

%% trial variables
blocklength = 40; % number of trials per block 
nblocks = 10;
ntrials = blocklength*nblocks; % THIS MUST BE IN MULTIPLES OF 4 BECAUSE THERE ARE 4 PRETEST CONDITIONS!!!
stimDur = 2; % how long each image is up for (sec)
RefreshRate = 60;
pauseDur = 0.5; % interimage gap of 0.5s
endoftrialpauseDur = 0.5;
fixSize = 50;
driftSpeed = [.3 .75] ; % drifts at a max speed of 1 pix per frame
magSpeed = [-.5 .5] ; % expansion or contraction at a max speed of 1 pix per frame
numPreTests = 4; % 1. one eye, 2. flip eye of orig 3. 1/f noise 4. regular filter condition
rng('shuffle');% sets different seed for condition randomization
%% sort out the beeps
Fs = 8192;
beepLengthSecs = .3;
correctBeep = MakeBeep(700, beepLengthSecs, Fs);
wrongBeep = MakeBeep(300, beepLengthSecs, Fs);
sound(1); % open the mex file, avoids delay first time sound is called in the program

%% Image variables

fname = [];
% isolate 'L' images
for indx = 1:2
    files = dir([imageDir1{indx} filesep '*L.png']);
    ct=1;
    % separate object present and absent LEFT images
    for fl=1:length(files)
        fname{indx, ct} = files(fl).name;
        ct = ct+1;
    end
end

fnameNoise = [];
for indx = 1:2
    filesNoise = dir([imageDir2{indx} filesep '*L.png']);
    ct=1;
    % separate object present and absent LEFT images
    for fl=1:length(filesNoise)
        fnameNoise{indx, ct} = filesNoise(fl).name;
        ct = ct+1;
    end
end


if isempty(fname)
    error('Size values are probably defined wrong');
else
    disp(['found ', num2str(length(fname)), ' files '])
end



%% Eliminate unwanted objects w/in scenes
% edit object list in get_objectlist.m

objectsList = get_objectlist();

%% Calculate image drifts

for fl = 1:size(fname,2)
    
    % extract the scene , scFac, loc, and rotation numbers of each image
    tmp = regexp(files(fl).name,'\d*','Match'); 
    
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

for fl = 1:size(fnameNoise,2)
    
    % extract the scene , scFac, loc, and rotation numbers of each image
    tmp = regexp(files(fl).name,'\d*','Match'); 
    
    % create structure with the following fields:sceneNum, scFac, xLoc,
    % yLoc, Rot, driftAng, driftSpeed, magSpeed, driftLoc, and magFac  
    fObjNoise(fl).sceneNum = str2num(tmp{1});
    fObjNoise(fl).scFac = 1/(str2num(tmp{2})/10);
    fObjNoise(fl).xLoc = str2num(tmp{3});
    fObjNoise(fl).yLoc = str2num(tmp{4});
    fObjNoise(fl).Rot = str2num(tmp{5});
    fObjNoise(fl).driftAng = randi(360, 1);
    fObjNoise(fl).driftSpeed = driftSpeed(1) + (driftSpeed(2)-driftSpeed(1)).*rand(1);
    fObjNoise(fl).magSpeed = magSpeed(1) + (magSpeed(2)-magSpeed(1)).*rand(1);
    fObjNoise(fl).driftLoc(:,1) = [floor(-stimDur*RefreshRate/2):ceil(stimDur *...
        RefreshRate/2)].* fObjNoise(fl).driftSpeed * cos(fObjNoise(fl).driftAng *pi/180);
    fObjNoise(fl).driftLoc(:,2) = [floor(-stimDur*RefreshRate/2):ceil(stimDur *...
        RefreshRate/2)].*fObjNoise(fl).driftSpeed * sin(fObjNoise(fl).driftAng *pi/180);
    fObjNoise(fl).magFac = [floor(-stimDur*RefreshRate/2):ceil(stimDur * ...
        RefreshRate/2)].*fObjNoise(fl).magSpeed;
end



%% Alignment Task

[offsetL, offsetR] = alignment_task('cornermatch', participantname);


%% Setting up PsychToolBox & open the window

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

%% Make trial textures

% make one and one green red fixation spot
tmp = ones(fixSize, fixSize, 3); tmp(:,:, 1) = 255;
fixTexRed = Screen('MakeTexture', window, tmp);

tmp = ones(fixSize, fixSize, 3); tmp(:,:, 2) = 255;
fixTexGreen = Screen('MakeTexture', window, tmp);

% make gray background
grayTex = Screen('MakeTexture', window, grey.*ones(windowRect(4)/2, windowRect(3)/2));

% make gray image (for monocular viewing conditions)
grayImg = grey.*ones(800,800);
imwrite(uint8(grayImg), 'grayImg.png');


if ntrials>length(files)
    error('not enough files for the requested number of trials');
end
%% Trial Instructions

ListenChar(-1); HideCursor;

% randomize trial order
tmp = randperm(numPreTests);
testCond = repelem(tmp,(nblocks*blocklength)/4);
cdt = PseudoRandom(ntrials, 2, size(fname,2));
cdt = [cdt (testCond')];

% show trial instructions
Screen('SelectStereoDrawBuffer', window, 0);
DrawFormattedText(window, 'Please decide whether the prompted\n object is present within the scene.\nPress "f" for "YES" \nor\n "j" for "NO"\n\nPress any key to start',...
    windowRect(3)/2 + offsetL(1), windowRect(4)/2 + offsetL(2), black, [], 1);

Screen('SelectStereoDrawBuffer', window, 1);
DrawFormattedText(window, 'Please decide whether the prompted\n object is present within the scene.\nPress "f" for "YES"\n or\n "j" for "NO\n\nPress any key to start"',...
    windowRect(3)/2 + offsetR(1), windowRect(4)/2 + offsetR(2), black, [], 1)
Screen('Flip', window)
KbStrokeWait;

%% Beginning of Trials


for trl = 1:ntrials

    
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
    
    switch cdt(trl, 3)
        case 1
            % Regular stimulus conditions           
            imageDir1{1} = [homeDr  filesep 'filtered_scenes_objects_present_newPar'];
            imageDir1{2} = [homeDr  filesep 'filtered_scenes_objects_absent_newPar'];
            
            A1 = imread([imageDir1{cdt(trl,1)} filesep fname{cdt(trl,1), cdt(trl,2)}]);
            A2 = imread([imageDir1{cdt(trl,1)} filesep fname{cdt(trl,1), cdt(trl,2)}(1:end-5), 'R.png']);
            
            
        case 2
            % Monocular viewing
            imageDir1{1} = [homeDr  filesep 'filtered_scenes_objects_present_newPar'];
            imageDir1{2} = [homeDr  filesep 'filtered_scenes_objects_absent_newPar'];
            
            index = randi(2,1,(nblocks*blocklength)/4);
            for i = 1:length(index)
                if index(i) == 1
                    A1 = imread([imageDir1{cdt(trl,1)} filesep fname{cdt(trl,1), cdt(trl,2)}]);
                    A2 = imread('grayImg.png');
                else
                    A1 = imread('grayImg.png');
                    A2 = imread([imageDir1{cdt(trl,1)} filesep fname{cdt(trl,1), cdt(trl,2)}(1:end-5), 'R.png']);
                end
            end
            
            
        case 3
            % Flipping L & R eyes
            imageDir1{1} = [homeDr  filesep 'filtered_scenes_objects_present_newPar'];
            imageDir1{2} = [homeDr  filesep 'filtered_scenes_objects_absent_newPar'];
            A1 = imread([imageDir1{cdt(trl,1)} filesep fname{cdt(trl,1), cdt(trl,2)}(1:end-5), 'R.png']);
            A2 = imread([imageDir1{cdt(trl,1)} filesep fname{cdt(trl,1), cdt(trl,2)}]);
            
            
        case 4
            % 1/f noise
            
            imageDir2{1} = [homeDr filesep 'filtered_scenes_objects_present_pinkNoise'];
            imageDir2{2} = [homeDr filesep 'filtered_scenes_objects_absent_pinkNoise'];
            
            A1 = imread([imageDir2{cdt(trl,1)} filesep fnameNoise{cdt(trl,1), cdt(trl,2)}]);
            A2 = imread([imageDir2{cdt(trl,1)} filesep fnameNoise{cdt(trl,1), cdt(trl,2)}(1:end-5), 'R.png']);
            
    end


    
    %% find out what image the subject should be looking for and display it
    
    %cd(imageDir{cdt(trl,1)}) % change directory to objects present or absent imageDir
    
    % put different scenes and objects together
    indx = [];
    for o=1:length(objectsList)
        if ~isempty(regexpi(fname{1, cdt(trl,2)}, objectsList{o}))
            indx = o;
        end
    end
    
    % identify the name of obejct being put into scene. If it isn't 2 word
    % object, then store it in different matrix
    objectName = objectsList{indx};
    tmp = regexp(objectName, '_');
    objectName_nounderscore = objectName;
    if ~isempty(tmp)
        objectName_nounderscore(tmp) = ' ';
    end
    
%%  Display name of prompting object

    % selecting stereobuffer 0 fills the left eye (for stereomode 4)
    Screen('SelectStereoDrawBuffer', window, 0);
    DrawFormattedText(window, objectName_nounderscore, windowRect(3)/2-(20* length(objectName_nounderscore)) + offsetL(1), ...
        windowRect(4)/2 + offsetL(2),  [0 0 0], [], 1);
    Screen('FrameRect', window, black, [screenCtr(1)-boxSize/2, screenCtr(2)-boxSize/2, screenCtr(1)+boxSize/2, screenCtr(2)+boxSize/2] + [offsetL offsetL], penWidth);
    
    % selecting stereobuffer 1 fills the right eye (for stereomode 4)
    Screen('SelectStereoDrawBuffer', window, 1);
    DrawFormattedText(window, objectName_nounderscore, windowRect(3)/2-(20* length(objectName_nounderscore)) + offsetR(1), ...
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
    
    %% Read in image and generate texture
    
    startTime = GetSecs;
    % Wait for participant to press either f (present)/ j(absent) key
    keypressed = 0; 
    stimstillon = 1; 
    frm = 1; 
    
    while keypressed == 0
        if stimstillon ==1
            if frm>length(fObj(cdt(trl,2)).magFac)
                Screen('CloseAll'); ListenChar;
                error('Run out of frames');
            end
                       
            [rect] = CenterRect([1 1 512 512],[1 1 size(A1)]);
            
            % offset the image location by shifting it to the ending drift
            % location
            [rect] = OffsetRect(rect,fObj(cdt(trl,2)).driftLoc(frm, 1), fObj(cdt(trl,2)).driftLoc(frm, 2));
            
            % push the image to the left, right, up, or down by using
            % magFac coords 
            rect = round(InsetRect(rect, fObj(cdt(trl,2)).magFac(frm), fObj(cdt(trl,2)).magFac(frm)));
            frm = frm+1;
            
            while min(rect(:))<1
                rect = rect+1;
            end
            while max(rect(:))>length(A1)
                rect = rect -1;
            end            
           
            imgTex1 = Screen('MakeTexture', window, A1(rect(1):rect(3), rect(2):rect(4)));
            imgTex2 = Screen('MakeTexture', window, A2(rect(1):rect(3), rect(2):rect(4)));
            
            %% Show participants image

            Screen('SelectStereoDrawBuffer', window, 0);
            Screen('DrawTexture', window, imgTex1,[], [screenCtr(1)-boxSize/2, screenCtr(2)-boxSize/2, screenCtr(1)+boxSize/2, screenCtr(2)+boxSize/2] + [offsetL offsetL]);
            Screen('FrameRect', window, black, [screenCtr(1)-boxSize/2, screenCtr(2)-boxSize/2, screenCtr(1)+boxSize/2, screenCtr(2)+boxSize/2] + [offsetL offsetL], penWidth);
            
            Screen('SelectStereoDrawBuffer', window, 1);
            Screen('DrawTexture', window, imgTex2, [], [screenCtr(1)-boxSize/2, screenCtr(2)-boxSize/2, screenCtr(1)+boxSize/2, screenCtr(2)+boxSize/2] + [offsetR offsetR]);
            Screen('FrameRect', window, black, [screenCtr(1)-boxSize/2, screenCtr(2)-boxSize/2, screenCtr(1)+boxSize/2, screenCtr(2)+boxSize/2]+ [offsetR offsetR], penWidth);
            
            Screen('Flip', window);
        end
        
        [keyIsDown, keysecs, keyCode] = KbCheck;
        if keyIsDown
            if keyCode(presentKey) == 1 % if the object is present (aka condition 1)
                KB_hit_key = presentKey; 
                keypressed = 1;
                time_stamp_KBhit = keysecs;
                if cdt(trl,1) == 2 % make incorrect feedback beep if participant says object absent
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
                if cdt(trl,1) == 1 % make incorrect feedback beep if participant says object present
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
                savefilepath = fullfile(homeDr, 'Results', 'PostTraining_Data', [savefilename '.mat']);
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
    
    % save all participant data in rObj
    rObj(trl).trl = trl;
    rObj(trl).rt = time_stamp_KBhit-startTime;
    rObj(trl).resp = KB_hit_key;
    rObj(trl).correct = correct;
    rObj(trl).preTestCond = cdt(trl,3);
    rObj(trl).condition = cdt(trl,1); % object present or absent
    rObj(trl).filename = fname{cdt(trl,1), cdt(trl,2)};
    rObj(trl).object = objectName;
    rObj(trl).sceneNum = fObj(cdt(trl,2)).sceneNum;
    rObj(trl).scFac =  fObj(cdt(trl,2)).scFac;
    rObj(trl).xLoc = fObj(cdt(trl,2)).xLoc;
    rObj(trl).yLoc = fObj(cdt(trl,2)).yLoc;
    fObj(trl).Rot = fObj(cdt(trl,2)).Rot;
    rObj(trl).driftAng = fObj(cdt(trl,2)).driftAng;
    rObj(trl).driftSpeed = fObj(cdt(trl,2)).driftSpeed;
    rObj(trl).magSpeed = fObj(cdt(trl,2)).magSpeed;
    
    save(savefilename, 'rObj', 'fObj')
    %% End of block 
    
    % If the remainder of the trial number and length of block =0 and there 
    % have been more than 10 trials, then calculate and display percent
    % correct. After percent correct is displayed, pause for a break (wait
    % for participant to press a key to start next block).
    
    if mod(trl, blocklength) == 0 
        %% calculate percent correct
        if trl>10
            scFac = [cat(1,rObj(:).scFac)];
            correct = [cat(1,rObj(:).correct)];
            scFacList = unique(scFac);
            for s = 1:length(scFacList)
                indx = find(scFac ==scFacList(s));
                perCorrect(s) = round( 100* sum(correct(indx))/length(indx), 1);
            end
         %% display percent correct
            
            for h = 1:length(scFacList)
                Screen('SelectStereoDrawBuffer', window, 0);
                DrawFormattedText(window, ['Size = ', num2str(round(scFacList(h), 2)), ' % correct = ', num2str(round(perCorrect(h), 1)), '%'], ...
                    windowRect(3)/2 + offsetL(1) - (20*length(objectName)), windowRect(4)/2 + offsetL(2) + (h*50),  black, [], 1);

                Screen('SelectStereoDrawBuffer', window, 1);
                DrawFormattedText(window,  ['Size = ', num2str(round(scFacList(h), 2)), ' % correct = ', num2str(round(perCorrect(h), 1)), '%'], ...
                    windowRect(3)/2 + offsetR(1) - (20*length(objectName)), windowRect(4)/2 + offsetR(2) + (h*50), black, [], 1);
            end
        end
        %% Allow participant to pause for a break
        
        Screen('SelectStereoDrawBuffer', window, 0);
        DrawFormattedText(window,'\n\nPause for a break!\n Press any key to continue ....\n\n', ...
            windowRect(3)/2 + offsetL(1)-(20*length(objectName)), windowRect(4)/2 + offsetL(2) + (h*50),...
            black, [], 1);
        
        Screen('SelectStereoDrawBuffer', window, 1);
        DrawFormattedText(window,  '\n\nPause for a break!\n Press any key to continue ....\n\n', ...
            windowRect(3)/2 + offsetR(1)- (20* length(objectName)), windowRect(4)/2 + offsetR(2)+ (h*50),  black, [], 1);
        Screen('Flip', window);
        FlushEvents;
        GetChar;
    end
end

cd(homeDr);
ListenChar; ShowCursor;
savefilepath = fullfile(homeDr, 'Results', 'PostTraining_Data', [savefilename '.mat']);
save(savefilepath, '-v7.3'); % save everything

Screen('CloseAll'); clear mex
cd(homeDr)