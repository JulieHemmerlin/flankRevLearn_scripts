function [p, trialData, trialTimes] = runTrial_fun(trialInfo, p, stage)
% Run one Trial for flankRevLearn task

% input: trialInfo  table with info about this trial
%        p  structure with all stim and timing parameters
% output: data from trial

% NS, Jan 2017

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    

trialData  = table2struct(trialInfo);
trialTimes = [];

%% Define Flankers & Target stimuli

flankStim = my_coordFlip_fn(p.stim.rightFlankers, [abs(trialInfo.flankers - 2), 0], p.display.rect, 'lines');  % abs(trialInfo.target-2) because 1 means left, and 2 means right

if trialInfo.choice == 1
    targetStim = p.stim.freeTarget;    
else
    targetStim = my_coordFlip_fn(p.stim.rightTarget, [abs(trialInfo.target - 2), 0], p.display.rect, 'lines');  % abs(trialInfo.target-2) because 1 means left, and 2 means right    
end
% combine with Flankers
combinedStim = [flankStim, targetStim];
 
% Check whether to cue best direction!
if strcmp(stage, 'train1') &&...
    (trialInfo.choice == 1 || (trialInfo.choice == 2 && trialInfo.target == trialInfo.hiRewAct) )
    cueHiAct = 1;
    hiActStim = my_coordFlip_fn(p.stim.rightTarget, [abs(trialInfo.hiRewAct - 2), 0], p.display.rect, 'lines');
else
    cueHiAct = 0;
end

%% % % % % Start Trial

% Fixation Dot
Screen('FillOval', p.display.win, p.colour.stim, p.stim.fixDot, p.stim.fixDiam);
Screen('DrawingFinished', p.display.win);
start_vbl = Screen('Flip', p.display.win);

% Clear screen before presenting stim
fixOff_vbl = Screen('Flip', p.display.win, start_vbl + p.time.fixDur - p.display.slack);

%% % % % Response Window
KbQueueStart(p.keys.kbInd); % VERY IMPORTANT TO START QUEUE AND THEN FLUSH!!!
KbQueueFlush(p.keys.kbInd);

correct  = 0;
waitResp = 1;
getResp  = 1;

% % % Draw Stim
Screen('DrawLines', p.display.win, combinedStim, p.stim.arrowLnWd, p.colour.stim);
if cueHiAct
    Screen('DrawLines', p.display.win, hiActStim, p.stim.arrowLnWd, p.colour.hiAct);
end
Screen('DrawingFinished', p.display.win);
stimOn_vbl = Screen('Flip', p.display.win, fixOff_vbl + p.time.fix2StimInt - p.display.slack);

vbl = stimOn_vbl; % to have vbl for response loop
% Loop during response window
while waitResp && vbl < stimOn_vbl + p.time.respWin - p.display.rft - p.display.slack

    if vbl < stimOn_vbl + p.time.stimDur - p.display.rft - p.display.slack % if within duration of target, draw it

        Screen('DrawLines', p.display.win, combinedStim, p.stim.arrowLnWd, p.colour.stim);
        if cueHiAct
            Screen('DrawLines', p.display.win, hiActStim, p.stim.arrowLnWd, p.colour.hiAct);
        end
    end
    Screen('DrawingFinished', p.display.win);

    % between screen flips, loop to check responses
    while getResp && GetSecs < vbl + p.display.rft - p.display.slack
        [pressed, firstPressed]= KbQueueCheck(p.keys.kbInd);
        if pressed            
            getResp=0; % stop inner loop
            waitResp=0; % stop outer loop
        end
        WaitSecs(0.001);        
    end

    % after checking for response
    vbl = Screen('Flip', p.display.win, vbl + p.display.rft - p.display.slack);
end % while waitResp && vbl ...

% Which, if any, keys were pressed?
resp = find(firstPressed);

% Clear screen
Screen('Flip', p.display.win);

% Check for almost simultaneous pressing of multiple keys
WaitSecs(0.050);

extraResp = []; extraKeys = []; extraKeyTimes = [];
[pressed2, secondPressed]= KbQueueCheck(p.keys.kbInd);
if pressed2                                  
    extraResp = find(secondPressed); % get key id
end

%% % Handle responses

if length(resp)==1 && isempty(extraResp) && ... % only 1 key was pressed
    ismember(resp, p.keys.action) % is one of the response keys

    if resp == p.keys.action(1) % then left key
        thisAction = 1;
    elseif resp == p.keys.action(2) % right
        thisAction = 2;
    end
    respTime = firstPressed(p.keys.action(thisAction));
    rt       = (respTime - stimOn_vbl)*1000;             
    
elseif ismember(p.keys.pause, resp) % PAUSE SCRIPT Until Enter is pressed
	p.keys.STOP = pauseFun(p.keys.STOP, p.keys.kbInd);

elseif ismember(p.keys.escape, resp)                
    p.keys.STOP = 1;
    return

elseif length(resp) > 1 || ~isempty(extraResp) % if other keys are pressed
    thisAction  = 5; % multiple keys
    if ~isempty(resp)
        respTime  = firstPressed(resp(1)); % only consider first keys as > 1 is possible
        rt        = (respTime - stimOn_vbl)*1000;   
    else
        respTime  = NaN;
        rt        = NaN;
    end
    extraKeys     = find(firstPressed);
    extraKeyTimes = firstPressed(resp); % Save times
    extraKeys     = [extraKeys, find(secondPressed)]; 
    extraKeyTimes = [extraKeyTimes, secondPressed(extraResp)];  % Save times
end % if length(resp)==1 && ...

    
%% % % Check whether correct?
if exist('thisAction', 'var') && ...    
    ismember(thisAction, 1:2) % i.e. not another key, otherwise error
    if trialInfo.choice == 1 % if free
      correct = 1;
      if thisAction == trialInfo.flankers
          thisCong = 1; % cong
      else
          thisCong = 2; % incong
      end
    else % forced trial
        if thisAction == trialInfo.target
            correct=1;
        end           
        thisCong = trialInfo.cong;
    end
end

%% % % % % If Correct

if correct

    %% Present Outcome

    if trialInfo.hiRewAct == thisAction
        thisOutcome = trialInfo.out_hiRewAct;
    else
        thisOutcome = trialInfo.out_loRewAct;
    end        
    
    Screen('TextSize', p.display.win, p.stim.outcomeSize);
    if thisOutcome > 0
        DrawFormattedText(p.display.win, ['+' num2str(thisOutcome)], 'center', 'center', p.colour.stim);
    else
        DrawFormattedText(p.display.win, num2str(thisOutcome), 'center', 'center', p.colour.stim);
    end

    Screen('DrawingFinished', p.display.win);
    effectOn_vbl = Screen('Flip', p.display.win, respTime + p.time.aoi - p.display.slack);

else % if error
    
    Screen('DrawLines', p.display.win, p.stim.errorCross, p.stim.arrowLnWd+1, p.colour.stim);
    Screen('DrawingFinished', p.display.win);
    effectOn_vbl = Screen('Flip', p.display.win);

    thisOutcome = NaN;
    if trialInfo.choice == 1 % if free
        thisCong = NaN;
    else
        thisCong = trialInfo.cong;
    end
    if ~exist('thisAction','var');  thisAction = NaN;   end              
    if ~exist('rt','var');          rt = NaN;           end       
    if ~exist('respTime','var');    respTime = NaN;     end    
end % if correct


%% Clear to fixation
Screen('FillOval', p.display.win, p.colour.stim, p.stim.fixDot, p.stim.fixDiam);
Screen('DrawingFinished', p.display.win);
effectOff_vbl = Screen('Flip', p.display.win, effectOn_vbl + p.time.outcomeDur - p.display.slack);

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    


%% % % % Record all trial info and responses

trialData.action  = thisAction;
trialData.realCong= thisCong;    
trialData.rt      = rt;
trialData.outcome = thisOutcome;
trialData.correct = correct;
trialData.extraKeys = extraKeys;


% % Timing record    
trialTimes.start = start_vbl;
trialTimes.fixOff = fixOff_vbl;
trialTimes.stimOn = stimOn_vbl;
trialTimes.respTime = respTime;
trialTimes.effectOn = effectOn_vbl;
trialTimes.effectOff = effectOff_vbl;
trialTimes.extraKeyTimes = extraKeyTimes;
