%% Response Conflict and Reversal Learning 

% Manipulate action selection: Flankers and Free vs. Forced Choice
% Assess effect on reinforcement learning: reversal learning task

 
% % % % Design:
% Choice: Free vs. Forced
% Flankers - Action Congruency: Congruent vs. Incongruent
% Outcomes: +1  vs. -1 points
%           75% vs. 25% reward probability for left vs. right hand action

% Episode Lengths: multiples of choice x flankers x action
% Episode Transition Types: also 8:
% % % nChoice x nFlankers/congruency x nAction-high vs low reward

% Add Breaks after set number of trials - thus likely falling within episodes
%%%%% Note that "break trials" (marked w 1) will be followed by a break (i.e. t before the break)
% Errors - Show Error Cross, move on (no replacement)
% Fixation Dot


% Training starts by cueing the best action
% Second part of training is as main experiment


% NS, Jan 2017

% % NS, Feb, 2017
% % Pilot revealed people made too many errors, so new version:
% % % v 2.0:
% % % Alter Instructions to emphasise errors reduce change of getting bonus
% % % Stimuli (T & F) on until Response (or end of response window)

% % % % v 2.0 solved error problem
% % % % But, as people learn quite fast, best to have shorter Ep Lengths
% % % % % v 3.0:
% % % % % Ep Lengths: 8 - 32


% % % % % % v 3.0 helped, but task is still too easy
% % % % % % % v 4.0 reduced probability difference

% % % % % % % % v 5.0 has reduced probability difference, but longer
% % % % % % % % % EpLenghts: 16 - 40


%%%%%% To do?
%%%%%%%%% Ensure 2nd session doesn't start with same Ep Type?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Clear window and workspace

Screen('CloseAll');
clear all;

% PsychJavaTrouble;
KbName('UnifyKeyNames');
AssertOpenGL;

savePath = '../data';
if ~exist(savePath, 'dir')
    mkdir(savePath);
end

%%% Add extra scripts folder to path
oldpath = addpath('./funs'); % with oldpath restore path def. file at the end

% % % % % % % % % To run on test mode
test  = 2; % if test == 1, use small window, if test == 2, use big window, but don't check Hz
train = 0; % run training blocks?
mainExp = 1;
expSessions = 1; % how many sessions for main exp? just one, or more?

%%  Initialise Global variables
% To make critical data info available to all functions

% global display param stim colour keys

p = setParams;


%% Subj

% get participant information
if ~test
    argindlg = inputdlg({'Participant number (two-digit)','Session number (one-digit)'});
    if isempty(argindlg)
        error('Experiment Cancelled!');
    end
else
    argindlg = {'99';'1'};
end

hdr         = [];
hdr.subj    = str2num(argindlg{1});  
hdr.session = str2num(argindlg{2});

hdr.subjPath = [savePath filesep sprintf('S%02d', hdr.subj)];
if ~exist(hdr.subjPath, 'dir')
    mkdir(hdr.subjPath);
end

hdr.fnameBase = 'flankRevLearn';
hdr.version = '3.0';
% hdr.version = '5.0';
hdr.rng = rng('shuffle'); % save/set random number generator


%% Number of trials and blocks

nCond       = 2; % free vs forced choice
nFlankers   = 2; % left vs right
nAction     = 2; % left vs right % will actually dictate target direction
minTrialN   = nCond*nFlankers*nAction;

if train            
    % Best Option Cued, to highlight reversals
    train1Cfg            = [];
    train1Cfg.stage      = 'train1';
    train1Cfg.nCond      = nCond;        % free vs forced choice
    train1Cfg.nFlankers  = nFlankers;    % left vs right
    train1Cfg.nAction    = nAction;      % left vs right % will actually dictate target direction
    train1Cfg.minTrialN  = minTrialN;
%     train1Cfg.epLengths  = [2*minTrialN 2*minTrialN 3*minTrialN]; % possible episode lengths %%% v1 - 2
    train1Cfg.epLengths  = [1*minTrialN 2*minTrialN 3*minTrialN]; % possible episode lengths  %%% v3 onwards, from Subj 10
    train1Cfg.epLenXType = 0;            % Don't cross Episode Lengths with Types, just randomly pick episode types to start with
    train1Cfg.prob       = [.875, .125]; % Probabilities for Good and Bad option  %%% v1 - 3
%     train1Cfg.prob       = [.75, .25]; % Probabilities for Good and Bad option  %%% v4 - 5
    train1Cfg.nBreaks    = 0;            % breaks within the session
    train1Cfg = setupTrials(train1Cfg); 
    
    % No cueing, as main exp.
    train2Cfg            = [];
    train2Cfg.stage      = 'train2';
    train2Cfg.nCond      = nCond;        % free vs forced choice
    train2Cfg.nFlankers  = nFlankers;    % left vs right
    train2Cfg.nAction    = nAction;      % left vs right % will actually dictate target direction
    train2Cfg.minTrialN  = minTrialN;
%     train2Cfg.epLengths  = [3*minTrialN 4*minTrialN 5*minTrialN 3*minTrialN]; % possible episode lengths %%% v1-2
%     train2Cfg.epLengths  = [1*minTrialN 2*minTrialN 3*minTrialN 4*minTrialN]; % possible episode lengths %%% v3
    train2Cfg.epLengths  = [1*minTrialN 2*minTrialN 3*minTrialN 1*minTrialN]; % possible episode lengths %%% v3, from Subj 10
%     train2Cfg.epLengths  = [2*minTrialN 2*minTrialN 3*minTrialN 4*minTrialN]; % possible episode lengths %%% v 5.0
    train2Cfg.epLenXType = 0;            % Don't cross Episode Lengths with Types, just randomly pick episode types to start with
    train2Cfg.prob       = [.875, .125]; % Probabilities for Good and Bad option %%% v1 - 3
%     train2Cfg.prob       = [.75, .25]; % Probabilities for Good and Bad option %%% v4 - 5
    train2Cfg.nBreaks    = 1;            % breaks within the session
    train2Cfg = setupTrials(train2Cfg);     
end


% Check whether episodes need to be divided into separate sessions
if mainExp
    expCfgFname = [hdr.subjPath filesep  sprintf('S%02d_expCfg.mat', hdr.subj)];
    if ~exist(expCfgFname,'file')
        if expSessions == 1  ||  hdr.session == 1 % First time: set up all episodes and save

            expCfg              = [];
            expCfg.stage        = 'mainExp';
            expCfg.nCond        = nCond;        % free vs forced choice
            expCfg.nFlankers    = nFlankers;    % left vs right
            expCfg.nAction      = nAction;      % left vs right % will actually dictate target direction
            expCfg.minTrialN    = minTrialN;    % Ep Lenghts must be multiple of this
            % Make a gaussian distribution of Episode Lengths
%             expCfg.epLengths    = [2*minTrialN 3*minTrialN 3*minTrialN 4*minTrialN 4*minTrialN 4*minTrialN 4*minTrialN 5*minTrialN 5*minTrialN 6*minTrialN]; % possible episode lengths % v1 - 2
            expCfg.epLengths    = [1*minTrialN 1*minTrialN 2*minTrialN 2*minTrialN 2*minTrialN 3*minTrialN 3*minTrialN 3*minTrialN 4*minTrialN 4*minTrialN]; % possible episode lengths % v3 - 4
%             expCfg.epLengths    = [2*minTrialN 2*minTrialN 3*minTrialN 3*minTrialN 3*minTrialN 4*minTrialN 4*minTrialN 4*minTrialN 5*minTrialN 5*minTrialN]; % possible episode lengths % v5
            expCfg.epLenXType   = 1;            % Cross Episode Lengths with Types, just randomly pick episode types to start with
            expCfg.prob         = [.75, .25];   % Probabilities for Good and Bad option %%% v1 - 3
%             expCfg.prob         = [.625, .375];   % Probabilities for Good and Bad option %%% v4 - 5
            expCfg.nBreaks      = 6;            % breaks within the session 
            expCfg = setupTrials(expCfg);

            % episodes to run per session
            epsPerSess = size(expCfg.epList,1)/expSessions;
            expCfg.sessionEps = NaN(epsPerSess, expSessions);
            for s = 1:expSessions
                expCfg.sessionEps(:,s) = 1+(s-1)*epsPerSess : epsPerSess+(s-1)*epsPerSess;
            end

            save(expCfgFname, 'expCfg');
        else
            error('No expCfg file!');
        end            
    else
        load(expCfgFname, 'expCfg');
    end
end
% clear nCond nFlankers nAction minTrialN



%% Startup Psychtoolbox
    
try

if ~test 
    p.display.skipChecks = 1;
    p.display = openWin(p.display);    
    Priority(MaxPriority(p.display.win));
    HideCursor;

%     if p.display.Hz ~= p.display.aimHz
%         Priority(0);  %Reset priority 
%         Screen('CloseAll'); % Close PTB screen  
%         error('----  CHECK REFRESH RATE!!  ----');
%     end                  
elseif test == 1
    p.display.screenNum = 0; % onscreen small rectangle instead of external full screen
    p.display.rect = [0, 0, 600, 500];
    p.display.skipChecks = 1;
    p.display = openWin(p.display);
    
elseif test > 1
    p.display.skipChecks = 1;
    p.display = openWin(p.display);          
    HideCursor;
end


% Start keyboard recording capacity
% % to limit permissible keys:
% % keyList = zeros(1,256);
% % keyList(p.keys.all) = 1;
% % KbQueueCreate(p.keys.kbInd, keyList);
KbQueueCreate(p.keys.kbInd);
KbQueueStart(p.keys.kbInd);
KbQueueFlush(p.keys.kbInd);

% Prevent spilling of keystrokes into console:
ListenChar(-1);

% Text settings
Screen('TextFont', p.display.win, 'Arial');
Screen('TextSize', p.display.win, 26);
Screen('TextStyle', p.display.win, 1);

% Setup Stimuli
p.stim = setupStimuli(p.stim, p.display);


%% -----------------------  Training session  ----------------------- %%

if train
        
    % Cued training
    p.keys.STOP = checkKeys(p.keys.STOP, p.keys.kbInd);
    if ~p.keys.STOP % if stop keys has not been pressed    

        p = runEpisodes_fun(train1Cfg, hdr, p);        
    else
        fprintf('\n\n  ------------Experiment stopped by user!!------------\n')
    end
    
    % Uncued training
    p.keys.STOP = checkKeys(p.keys.STOP, p.keys.kbInd);
    if ~p.keys.STOP % if stop keys has not been pressed    

        p = runEpisodes_fun(train2Cfg, hdr, p);        
    else
        fprintf('\n\n  ------------Experiment stopped by user!!------------\n')
    end
    
    
    % % % Check whether happy to continue, or whether to repeat training
    p.keys.STOP = checkKeys(p.keys.STOP, p.keys.kbInd);
    if ~p.keys.STOP % if stop keys has not been pressed    

        Line1 = 'Etes-vous preparer pour commencer l''experience principale ?\n\n';
        Line2 = 'Veuillez appeler l''experimentateur.';
        
        Screen('TextSize', p.display.win, 26);                       
        DrawFormattedText(p.display.win, [Line1, Line2], 'center', 'center', p.colour.text, 80);
        Screen('Flip', p.display.win);           

        [p.keys.STOP, key] = wait4Key([KbName('o'), KbName('n')], p.keys.STOP, p.keys.kbInd);    
        if ~p.keys.STOP
            if key == KbName('o') % oui, so continue
                Screen('Flip', p.display.win);
                WaitSecs(.5);

            elseif key == KbName('n') % run another block of training
                % No cueing, as main exp.
                train2Cfg            = [];
                train2Cfg.stage      = 'train2';
                train2Cfg.nCond      = nCond;        % free vs forced choice
                train2Cfg.nFlankers  = nFlankers;    % left vs right
                train2Cfg.nAction    = nAction;      % left vs right % will actually dictate target direction
                train2Cfg.minTrialN  = minTrialN;
                train2Cfg.epLengths  = [3*minTrialN 4*minTrialN 5*minTrialN 3*minTrialN]; % possible episode lengths
                train2Cfg.epLenXType = 0;            % Don't cross Episode Lengths with Types, just randomly pick episode types to start with
                train2Cfg.prob       = [.875, .125]; % Probabilities for Good and Bad option
                train2Cfg.nBreaks    = 1;            % breaks within the session
                train2Cfg = setupTrials(train2Cfg);     
                p = runEpisodes_fun(train2Cfg, hdr, p);        
            end
        end
    end
end


%% -----------------------  Main Experiment session ----------------------- %%

if mainExp
    p.keys.STOP = checkKeys(p.keys.STOP, p.keys.kbInd);
    if ~p.keys.STOP % if stop keys has not been pressed    
        
        p = runEpisodes_fun(expCfg, hdr, p);
    else
        fprintf('\n\n  ------------Experiment stopped by user!!------------\n')
    end
end

%% End

p.keys.STOP = checkKeys(p.keys.STOP, p.keys.kbInd);
if ~p.keys.STOP % if stop keys has not been pressed    

    Line1 = 'Fin de l''experience.\n\nFelicitations, vous avez gagne le bonus !\n\n\n';
    Line2 = 'Veuillez appeler l''experimentateur.';
    Screen('TextSize', p.display.win, 26);                       
    DrawFormattedText(p.display.win, [Line1, Line2], 'center', 'center', p.colour.text, 80);
    Screen('Flip', p.display.win);           

    [p.keys.STOP] = wait4Key([], p.keys.STOP, p.keys.kbInd);
end


ListenChar(0);
sca;            % Close PTB screen  
Priority(0);    % Reset priority 
KbQueueRelease(p.keys.kbInd); 

  
catch err

ListenChar(0);
sca;            % Close PTB screen  
Priority(0);    % Reset priority 
KbQueueRelease(p.keys.kbInd); 
    
rethrow(err);
end

   
path(oldpath);




