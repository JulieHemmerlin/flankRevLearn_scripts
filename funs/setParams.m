function [p] = setParams
%% Experiment parameters

%%% Colours
p.colour.black      = [0 0 0];
p.colour.white      = [255, 255, 255];
p.colour.bkgd       = [128, 128, 128];
p.colour.stim       = p.colour.black;
p.colour.text       = p.colour.black;
p.colour.hiAct      = [0, 200, 50]; % highlight best option


%%% Display parameters
% p.display.dist      = 60;           % cm - for external monitor
% p.display.width     = 48;           % cm - for external monitor
p.display.dist      = 50;           % cm - for laptop
p.display.width     = 33;           % cm - for laptop
p.display.skipChecks= 0;            % if 1, avoid Screen's timing checks and verbosity, but set to 0 before testing
p.display.bkColor   = p.colour.bkgd;  % background colour
p.display.aimHz     = 60;           % during testing proper, use that

%%% Timing, in secs 
p.time.fixDur       = .400;
p.time.fix2StimInt  = .100;
p.time.stimDur      = inf;
p.time.respWin      = 1.2;
p.time.aoi          = .300;
p.time.outcomeDur   = .7;
p.time.ITI          = [.8 1.2];
p.time.breakDur     = 10;     % break between blocks

%%% Input
% If uncertain, or for macs:
% [keyboardIndices, productNames, allInfos] = GetKeyboardIndices;
% p.keys.kbInd = min(keyboardIndices); % this is the device that will be called by the KbQueue Functions, check with GetKeyboardIndices which number to use
p.keys.kbInd        = [];
p.keys.escape       = KbName('Escape');
p.keys.pause        = KbName('p');
p.keys.space        = KbName('Space');
p.keys.enter        = KbName('Return');
p.keys.action       = KbName({'F','J'});
% p.keys.all          = [p.keys.action, p.keys.enter, p.keys.space, p.keys.pause, p.keys.escape]; % only keys that will be read and recorded by KbQueueCheck    
p.keys.STOP         = 0;  % To abort running scripts, logical


%%% Stimuli
p.stim.fixSize      = .26;   % vis angle
p.stim.arrowSize    = .6;   % vis angle
p.stim.arrowSpacing = .1;   % vis angle
p.stim.arrowLnWd    = 5;    % line width, pix
p.stim.outcomeSize  = 54;   % font points
p.stim.errorCrossSize = 1;  % vis angle


