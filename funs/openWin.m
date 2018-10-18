function display = openWin(display)
%display = OpenWindow([display])
%
%Calls the psychtoolbox command "Screen('OpenWindow') using the 'display'
%structure convention.
%
%Inputs:
%   display             A structure containing display information with fields:
%       screenNum       Screen Number (default is 0)
%       bkColor         Background color (default is black: [0,0,0])
%       skipChecks      Flag for skpping screen synchronization (default is 0, or don't check)
%                       When set to 1, vbl sync check will be skipped,
%                       along with the text and annoying visual (!) warning
%
%Outputs:
%   display             Same structure, but with additional fields filled in:
%       win       Pointer to window, as returned by 'Screen'
%       frameRate       Frame rate in Hz, as determined by Screen('GetFlipInterval')
%       resolution      [width,height] of screen in pixels
%
%Note: for full functionality, the additional fields of 'display' should be
%filled in:
%
%       dist             distance of viewer from screen (cm)
%       width            width of screen (cm)

% Written 11/13/07 by gmb
% Adapted by NS, Aug 2016

extScreenNum = max(Screen('Screens')); %gets screen with the highest number, i.e. external screen
if ~exist('disp','var')
    display.screenNum = 0; %Use for default of primary screen
end

if ~isfield(display,'screenNum')
    display.screenNum = extScreenNum; %Use for external screen
end

if ~isfield(display,'bkColor')    
    display.bkColor = [0,0,0]; %black
end

if ~isfield(display,'skipChecks')
    display.skipChecks = 0;
end

if display.skipChecks
    Screen('Preference', 'Verbosity', 0);
    Screen('Preference', 'SkipSyncTests',1);
    Screen('Preference', 'VisualDebugLevel',0);
end

%Open the window
if isfield(display,'rect') % if exists, sets window size
    [display.win, display.rect]=Screen('OpenWindow', display.screenNum, display.bkColor, display.rect);
    
else % fullsize window
    [display.win, display.rect]=Screen('OpenWindow', display.screenNum, display.bkColor);
%     HideCursor;
end

%Set the display parameters 'frameRate' and 'resolution'
display.Hz        = Screen('NominalFrameRate', display.win); % Actual refresh rate, in Hz 
display.rft       = Screen('GetFlipInterval', display.win); % duration of 1 screen
display.frameRate = 1/display.rft;
display.slack     = display.rft/3;

if ~isfield(display,'resolution')
    display.resolution = [display.rect(RectRight), display.rect(RectBottom)];
end

% centre coordinates
[display.x, display.y] = RectCenter(display.rect);
