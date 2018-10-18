% STIMULUS MATRICES in arbitrary

function [stim] = setupStimuli(stim, display)
% Alters structure variable 'stim'

% Draw lines: [horz; vert];

% NS, Jan 2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % Fixation Cross 
% fixCross = [ 0, 0, -1, 1;
%                  -1, 1, 0 , 0];
% fixCross = fixCross * angle2pix(display, stim.fixSize); % pix
% stim.fixCross = [fixCross(1,:) + display.x;
%                  fixCross(2,:) + display.y];
%
% % % % Has to be a dot, to avoid confusion with feedback
% Circle Box for effects
stim.fixDiam = angle2pix(display, stim.fixSize); % pix
stim.fixDot = CenterRect([0 0 stim.fixDiam stim.fixDiam], display.rect);


% Error Cross                           
errorCross = [-0.7, 0.7, -0.7, 0.7;
                    -1,   1 ,   1,  -1 ];
errorCross = errorCross * angle2pix(display, stim.errorCrossSize); % pix
stim.errorCross = [errorCross(1,:) + display.x;
                   errorCross(2,:) + display.y];



% Arrows
arrowHor  = angle2pix(display, stim.arrowSize)/2; % pix
arrowVert = arrowHor;

rightArrow = [-arrowHor, arrowHor, -arrowHor, arrowHor;
              arrowVert, 0       , -arrowVert, 0 ];
stim.rightTarget   = [rightArrow(1,:) + display.x;
                      rightArrow(2,:) + display.y];

stim.freeTarget   = [stim.rightTarget, my_coordFlip_fn(stim.rightTarget, [1, 0], display.rect, 'lines') ];

                  
% Flankers - shift centered arrow to right or left
arrowHorShift = 2*arrowHor + angle2pix(display, stim.arrowSpacing);

stim.rightFlankers = [stim.rightTarget(1,:) - 2*arrowHorShift,...
    stim.rightTarget(1,:) - arrowHorShift,...
    stim.rightTarget(1,:) + arrowHorShift,...
    stim.rightTarget(1,:) + 2*arrowHorShift; % horizontal points
    stim.rightTarget(2,:), stim.rightTarget(2,:), stim.rightTarget(2,:), stim.rightTarget(2,:)]; % vertical points



