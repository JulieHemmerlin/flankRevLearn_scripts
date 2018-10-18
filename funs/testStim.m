  
Screen('CloseAll');
clear all;
clc;
  
  

% PsychJavaTrouble;
KbName('UnifyKeyNames');


%%  Initialise Global variables
% To make critical data info available to all functions
    
p = setParams;


%% 
 
try  

% p.display.screenNum = 0; % onscreen small rectangle instead of external full screen
p.display.skipChecks = 1;

p.display = openWin(p.display);          


% Start keyboard recording capacity
KbQueueCreate(p.keys.kbInd);
KbQueueStart(p.keys.kbInd);
KbQueueFlush(p.keys.kbInd);


% Text settings
Screen('TextFont', p.display.win, 'Arial');
Screen('TextSize', p.display.win, 26);
Screen('TextStyle', p.display.win, 1);


[p.stim] = setupStimuli(p.stim, p.display);


%%      

thisStim = [p.stim.freeTarget,...
  my_coordFlip_fn(p.stim.rightFlankers, [0, 0], p.display.rect, 'lines')];

Screen('DrawLines', p.display.win, thisStim, p.stim.arrowLnWd, p.colour.stim);
Screen('Flip', p.display.win);

wait4Key;  


% 
% thisStim = [p.stim.rightTarget,...
%   my_coordFlip_fn(p.stim.rightFlankers, [1, 0], p.display.rect, 'lines')];
%                   
% 
% Screen('DrawLines', p.display.win, thisStim, p.stim.arrowLnWd, p.colour.stim);
% Screen('Flip', p.display.win);
% 
% wait4Key;
%    

p.colour.hiAct = [0, 255, 0];
hiActStim = my_coordFlip_fn(p.stim.rightTarget, [abs(1 - 2), 0], p.display.rect, 'lines');

thisStim = [p.stim.freeTarget,...
  my_coordFlip_fn(p.stim.rightFlankers, [1, 0], p.display.rect, 'lines')];


Screen('DrawLines', p.display.win, thisStim, p.stim.arrowLnWd, p.colour.stim);

Screen('DrawLines', p.display.win, hiActStim, p.stim.arrowLnWd, p.colour.hiAct);

Screen('Flip', p.display.win);

wait4Key;


Screen('DrawLines', p.display.win, thisStim, p.stim.arrowLnWd, p.colour.stim);

Screen('DrawLines', p.display.win, hiActStim, p.stim.arrowLnWd + 1, p.colour.hiAct);

Screen('Flip', p.display.win);

wait4Key;


% 
% outcome = -1;
%   
% Screen('TextSize', p.display.win, p.stim.outcomeSize)
% if outcome > 0
%     DrawFormattedText(p.display.win, ['+' num2str(outcome)], 'center', 'center', p.colour.stim);
% else
%     DrawFormattedText(p.display.win, num2str(outcome)  , 'center', 'center', p.colour.stim);
% end
% 
% Screen('Flip', p.display.win);
% wait4Key; 
%    

% thisStim = [p.stim.freeTarget,...
%   my_coordFlip_fn(p.stim.rightFlankers, [0, 0], p.display.rect, 'lines')];
% 
% Screen('DrawLines', p.display.win, thisStim, p.stim.arrowLnWd, p.colour.stim);
% Screen('Flip', p.display.win);
% 
% wait4Key;  
% 


p.colour.hiAct = [255, 100, 255];
hiActStim = my_coordFlip_fn(p.stim.rightTarget, [abs(1 - 2), 0], p.display.rect, 'lines');

thisStim = [p.stim.freeTarget,...
  my_coordFlip_fn(p.stim.rightFlankers, [1, 0], p.display.rect, 'lines')];


Screen('DrawLines', p.display.win, thisStim, p.stim.arrowLnWd, p.colour.stim);

Screen('DrawLines', p.display.win, hiActStim, p.stim.arrowLnWd, p.colour.hiAct);

Screen('Flip', p.display.win);

wait4Key;


Screen('DrawLines', p.display.win, thisStim, p.stim.arrowLnWd, p.colour.stim);

Screen('DrawLines', p.display.win, hiActStim, p.stim.arrowLnWd + 1, p.colour.hiAct);
Screen('Flip', p.display.win);

wait4Key;



KbQueueRelease(p.keys.kbInd); 
Screen('CloseAll'); % Close PTB screen  

    
catch err
    fprintf('\n\n ********************************************\n\n Error @ testStim: \n')
    KbQueueRelease(p.keys.kbInd); 
    Screen('CloseAll'); % Close PTB screen  
    disp(err.message);
    
end

