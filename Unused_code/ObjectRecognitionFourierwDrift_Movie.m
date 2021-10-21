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
goodSizeList = {'15';'50'};



try
    cd('/home/viscog/GitHub/dichoptic_gaming/');  homeDr = pwd;
catch
    homeDr = pwd;
end

% condition = 1 is objects present
imageDir{1} = [homeDr  filesep 'filtered_scenes_objects_present'];
imageDir{2} = [homeDr  filesep 'filtered_scenes_objects_absent'];
savefilename = [participantname, '_', datestr(now, 'hh_MMPM_mmm_dd_yy')];
fileName = datestr(now, 'yyyy-mm-dd-HH-MM-SS');
%addpath(genpath('C:\ProgramFiles\PsychToolbox'))
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
ntrials = blocklength*nblocks;
stimDur = 2; % how long each image is up for (sec)
RefreshRate = 60;
pauseDur = 0.5; % interimage gap of 0.5s
endoftrialpauseDur = 0.5;
fixSize = 50;
driftSpeed = [.3 .75] ; % drifts at a max speed of 1 pix per frame
magSpeed = [-.5 .5] ; % expansion or contraction at a max speed of 1 pix per frame

%% sort out the beeps
Fs = 8192;
beepLengthSecs = .3;
correctBeep = MakeBeep(700, beepLengthSecs, Fs);
wrongBeep = MakeBeep(300, beepLengthSecs, Fs);
sound(1); % open the mex file, avoids delay first time sound is called in the program

%% For capturing animation
imageArray = {};

%% Image variables
boxSize = 800;
penWidth = 10;
fname = [];
for indx = 1:2
    files = dir([imageDir{indx} filesep '*L.png']);
    ct=1;
    for fl=1:length(files)
        %if ~isempty(regexp(files(fl).name, goodSizeList))
        fname{indx, ct} = files(fl).name;
        ct = ct+1;
    end
end


if isempty(fname)
    error('Size values are probably defined wrong');
else
    disp(['found ', num2str(length(fname)), ' files '])
end


%% find the names of the files

objectsList = get_objectlist();

%% calculate the drifts

cdt = PseudoRandom(ntrials, 2, size(fname,2));

for fl = 1:size(fname,2)
    tmp = regexp(files(fl).name,'\d*','Match');
    fObj(fl).sceneNum = str2num(tmp{1});
    fObj(fl).scFac = 1/(str2num(tmp{2})/10);
    fObj(fl).xLoc = str2num(tmp{3});
    fObj(fl).yLoc = str2num(tmp{4});
    fObj(fl).Rot = str2num(tmp{5});
    fObj(fl).driftAng = randi(360, 1);
    fObj(fl).driftSpeed = driftSpeed(1) + (driftSpeed(2)-driftSpeed(1)).*rand(1);
    fObj(fl).magSpeed = magSpeed(1) + (magSpeed(2)-magSpeed(1)).*rand(1);
    fObj(fl).driftLoc(:,1) = [floor(-stimDur*RefreshRate/2):ceil(stimDur * RefreshRate/2)].* ...
        fObj(fl).driftSpeed * cos(fObj(fl).driftAng *pi/180);
    fObj(fl).driftLoc(:,2) = [floor(-stimDur*RefreshRate/2):ceil(stimDur * RefreshRate/2)].*fObj(fl).driftSpeed * ...
        sin(fObj(fl).driftAng *pi/180);
    fObj(fl).magFac = [floor(-stimDur*RefreshRate/2):ceil(stimDur * RefreshRate/2)].*fObj(fl).magSpeed;
end


offsetL = [0 0];
offsetR = [0 0];
%% Setting up PsychToolBox & open the window
stereomode = 7;
screens = Screen('Screens');
scrn = max(screens);
halfscrn = [0 0 1280 1440];

Screen('Preference', 'Verbosity',0);
Screen('Preference','SkipSyncTests', 1);
Screen('Preference','VisualDebugLevel', 0);
Screen('Preference','SuppressAllWarnings', 1);
white = WhiteIndex(scrn);
black = BlackIndex(scrn);
grey = white / 2;

[window, windowRect] = Screen('OpenWindow', scrn, grey, halfscrn, [], [], stereomode);
Screen('ScreenCloseAll');
if RefreshRate~=Screen('NominalFrameRate', window)
    error('wrong refresh rate specified')
end
screenCtr = windowRect(3:4)/2;
Screen('Flip', window);
Screen('TextSize', window, 50);


%% make some useful textures

tmp = ones(fixSize, fixSize, 3); tmp(:,:, 1) = 255;
fixTexRed = Screen('MakeTexture', window, tmp);
tmp = ones(fixSize, fixSize, 3); tmp(:,:, 2) = 255;
fixTexGreen = Screen('MakeTexture', window, tmp);
grayTex = Screen('MakeTexture', window, grey.*ones(windowRect(4)/2, windowRect(3)/2));

if ntrials>length(files)
    error('not enough files for the requested number of trials');
end
%% Trials
% beginning of the trials
ListenChar(-1); HideCursor;
Screen('SelectStereoDrawBuffer', window, 0);
DrawFormattedText(window, 'Please decide whether the prompted\n object is present within the scene.\nPress "f" for "YES" \nor\n "j" for "NO"\n\nPress any key to start',...
    windowRect(3)/2 + offsetL(1), windowRect(4)/2 + offsetL(2), black, [], 1);

Screen('SelectStereoDrawBuffer', window, 1);
DrawFormattedText(window, 'Please decide whether the prompted\n object is present within the scene.\nPress "f" for "YES"\n or\n "j" for "NO\n\nPress any key to start"',...
    windowRect(3)/2 + offsetR(1), windowRect(4)/2 + offsetR(2), black, [], 1)
Screen('Flip', window)
KbStrokeWait;

for trl = 1:4
    
    Screen('SelectStereoDrawBuffer', window, 0);
    Screen('DrawTexture', window, fixTexRed, [], CenterRect([0 0 fixSize fixSize], windowRect) + [offsetL offsetL]);
    Screen('FrameRect', window, black, [screenCtr(1)-boxSize/2, screenCtr(2)-boxSize/2, screenCtr(1)+boxSize/2, screenCtr(2)+boxSize/2] + [offsetL offsetL], penWidth);
    
    Screen('SelectStereoDrawBuffer', window, 1);
    Screen('DrawTexture', window, fixTexGreen, [], CenterRect([0 0 fixSize fixSize], windowRect) + [offsetR offsetR]);
    Screen('FrameRect', window, black, [screenCtr(1)-boxSize/2, screenCtr(2)-boxSize/2, screenCtr(1)+boxSize/2, screenCtr(2)+boxSize/2]  + [offsetR offsetR], penWidth);
    Screen('Flip', window);
    pause(pauseDur);
    
    for im = 1:30
    imageArray = [imageArray; {Screen('GetImage', window)}];
    end
    %% find out what image the subject should be looking for and display it
    cd(imageDir{cdt(trl,1)})
    indx = [];
    for o=1:length(objectsList)
        if ~isempty(regexpi(fname{1, cdt(trl,2)}, objectsList{o}))
            indx = o;
        end
    end
    
    objectName = objectsList{indx};
    tmp = regexp(objectName, '_');
    objectName_nounderscore = objectName;
    if ~isempty(tmp)
        objectName_nounderscore(tmp) = ' ';
    end
    
    % selecting stereobuffer 0 fills the left eye (for stereomode 4)
    Screen('SelectStereoDrawBuffer', window, 0);
    DrawFormattedText(window, objectName_nounderscore, windowRect(3)/2-(20* length(objectName_nounderscore)) + offsetL(1), ...
        windowRect(4)/2 + offsetL(2),  [0 0 0], []);
    Screen('FrameRect', window, black, [screenCtr(1)-boxSize/2, screenCtr(2)-boxSize/2, screenCtr(1)+boxSize/2, screenCtr(2)+boxSize/2] + [offsetL offsetL], penWidth);
    
    % selecting stereobuffer 1 fills the right eye (for stereomode 4)
    Screen('SelectStereoDrawBuffer', window, 1);
    DrawFormattedText(window, objectName_nounderscore, windowRect(3)/2-(20* length(objectName_nounderscore)) + offsetR(1), ...
        windowRect(4)/2 + offsetR(2),  [0 0 0], []);
    Screen('FrameRect', window, black, [screenCtr(1)-boxSize/2, screenCtr(2)-boxSize/2, screenCtr(1)+boxSize/2, screenCtr(2)+boxSize/2] + [offsetR offsetR], penWidth);
    
    Screen('Flip', window);
    

    for im = 1:30
    imageArray = [imageArray; {Screen('GetImage', window)}];
    end
    
    pause(pauseDur);
    
    %% go to a blank screen
    Screen('SelectStereoDrawBuffer', window, 0);
    Screen('DrawTexture', window, grayTex);
    Screen('FrameRect', window, black, [screenCtr(1)-boxSize/2, screenCtr(2)-boxSize/2, screenCtr(1)+boxSize/2, screenCtr(2)+boxSize/2] + [offsetL offsetL], penWidth);
    
    Screen('SelectStereoDrawBuffer', window, 1);
    Screen('DrawTexture', window, grayTex);
    Screen('FrameRect', window, black, [screenCtr(1)-boxSize/2, screenCtr(2)-boxSize/2, screenCtr(1)+boxSize/2, screenCtr(2)+boxSize/2] + [offsetR offsetR], penWidth);
    Screen('Flip', window);

    for im = 1:30
    imageArray = [imageArray; {Screen('GetImage', window)}];
    end
    %% read in image and generate texture
    
    A1 = imread(fname{cdt(trl,1), cdt(trl,2)});
    
    % instead of cd'ing into a directory before doing the above A1 thing,
    % something like this should work instead of changing directories:
    % A1 = imread([imageDir{cdt(trl,1)} filesep fname{cdt(trl,1), cdt(trl,2)}]);
    
    A2 = imread([fname{cdt(trl,1), cdt(trl,2)}(1:end-5), 'R.png']);
    startTime = GetSecs;
    
    keypressed = 0; stimstillon = 1; frm = 1; % Wait for participantname to press either f (present)/ j(absent) key
    while keypressed == 0
        if stimstillon ==1
            if frm>length(fObj(cdt(trl,2)).magFac)
                Screen('CloseAll'); ListenChar;
                error('Run out of frames');
            end
            
            [rect] = CenterRect([1 1 512 512],[1 1 size(A1)]);
            [rect] = OffsetRect(rect,fObj(cdt(trl,2)).driftLoc(frm, 1), fObj(cdt(trl,2)).driftLoc(frm, 2));
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
            
                imageArray = [imageArray; {Screen('GetImage', window)}];

        end
        
        [keyIsDown, keysecs, keyCode] = KbCheck;
        if keyIsDown
            if keyCode(presentKey) == 1
                KB_hit_key = presentKey; keypressed = 1;
                time_stamp_KBhit = keysecs;
                if cdt(trl,1) == 2 % if incorrect
                    sound(wrongBeep, Fs);
                    correct = 0;
                else
                    sound(correctBeep, Fs);
                    correct = 1;
                end
            elseif keyCode(absentKey) == 1
                KB_hit_key = absentKey; keypressed = 1;
                time_stamp_KBhit = keysecs;
                if cdt(trl,1) == 1 % if incorrect
                    sound(wrongBeep, Fs);
                    correct = 0;
                else
                    sound(correctBeep, Fs);
                    correct = 1;
                end
            elseif keyCode(escapeKey) == 1
                ListenChar; Screen('CloseAll');ShowCursor; clear mex;
                savefilepath = fullfile(homeDr, 'Results', [savefilename '.mat']);
                save(savefilepath, '-v7.3'); % save everything
                return
            end
            KbReleaseWait;
            keyIsDown = 0;
        end
        
        if (GetSecs-startTime)>stimDur && stimstillon == 1
            Screen('SelectStereoDrawBuffer', window, 0);
            Screen('DrawTexture', window, grayTex);
            Screen('FrameRect', window, black, [screenCtr(1)-boxSize/2, screenCtr(2)-boxSize/2, screenCtr(1)+boxSize/2, screenCtr(2)+boxSize/2]+ [offsetL offsetL], penWidth);
            
            Screen('SelectStereoDrawBuffer', window, 1);
            Screen('DrawTexture', window, grayTex);
            Screen('FrameRect', window, black, [screenCtr(1)-boxSize/2, screenCtr(2)-boxSize/2, screenCtr(1)+boxSize/2, screenCtr(2)+boxSize/2]+ [offsetR offsetR], penWidth);
            
            Screen('Flip', window);
            

    for im = 1:30
    imageArray = [imageArray; {Screen('GetImage', window)}];
    end
            stimstillon = 0;
        end
    end
    
    pause(pauseDur);
    rObj(trl).trl = trl;
    rObj(trl).rt = time_stamp_KBhit-startTime;
    rObj(trl).resp = KB_hit_key;
    rObj(trl).correct = correct;
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
    
    if mod(trl, blocklength) == 0
        if trl>10
            scFac = [cat(1,rObj(:).scFac)];
            correct = [cat(1,rObj(:).correct)];
            scFacList = unique(scFac);
            for s = 1:length(scFacList)
                indx = find(scFac ==scFacList(s));
                perCorrect(s) = round( 100* sum(correct(indx))/length(indx), 1);
            end
            
            %% put up percent correct
            % selecting stereobuffer 0 fills the left eye (for stereomode 4)
            
            for h = 1:length(scFacList)
                Screen('SelectStereoDrawBuffer', window, 0);
                DrawFormattedText(window, ['Size = ', num2str(round(scFacList(h), 2)), ' % correct = ', num2str(round(perCorrect(h), 1)), '%'], ...
                    windowRect(3)/2 + offsetL(1) - (20*length(objectName)), windowRect(4)/2 + offsetL(2) + (h*50),  black, [], 1);
                
                % selecting stereobuffer 1 fills the right eye (for stereomode 4)
                Screen('SelectStereoDrawBuffer', window, 1);
                DrawFormattedText(window,  ['Size = ', num2str(round(scFacList(h), 2)), ' % correct = ', num2str(round(perCorrect(h), 1)), '%'], ...
                    windowRect(3)/2 + offsetR(1) - (20*length(objectName)), windowRect(4)/2 + offsetR(2) + (h*50), black, [], 1);
            end
        end
        
        Screen('SelectStereoDrawBuffer', window, 0);
        DrawFormattedText(window,'\n\nPause for a break!\n Press any key to continue ....\n\n', ...
            windowRect(3)/2 + offsetL(1)-(20*length(objectName)), windowRect(4)/2 + offsetL(2) + (h*50),...
            black, [], 1);
        
        % selecting stereobuffer 1 fills the right eye (for stereomode 4)
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
savefilepath = fullfile(homeDr, 'Results', [savefilename '.mat']);
save(savefilepath, '-v7.3'); % save everything

Screen('CloseAll'); clear mex
cd(homeDr)


for i = 1:length(imageArray)
    disp(['Writing frame ' num2str(i) ' of ' num2str(length(imageArray))])
[y newmap] = cmunique(imageArray{i});
if i == 1
    imwrite(y, newmap, 'RG-movie.gif')
else
    imwrite(y, newmap, 'RG-movie.gif', 'DelayTime', 1/30, 'WriteMode', 'append')
end
end
