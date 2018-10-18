function [cfg] = setupTrials(cfg) 
% Setup trials for flankRevLearn experiment

% Define Trial Types - choice x flankers x action
% Define Episode Types - (1st trial type in the episode)
% Define a distribution of Episode Lengths
% Pseudo-randomise Episode Lengths and Types, such that
% % % all Lengths and all Types get randomised, before repeating
% Randomise trial order within Episodes
% Combine outcome information, based on probabilities

% NS, Jan 2017

%% 

% check input arguments
if nargin < 1
    error('No cfg input to setupTrials!');
end

nCond       = cfg.nCond; % free vs forced choice
nFlankers   = cfg.nFlankers; % left vs right
nAction     = cfg.nAction; % left vs right % will actually dictate target direction
minTrialN   = cfg.minTrialN;
probs       = cfg.prob;
epLengths   = cfg.epLengths;


%% Define Trial Types

% % To maintain all conditions balanced, must repeat these basic trial sets
% columns: Choice, Flankers, Target (& Action, for forced), Congruency
freeBasic   = [ones(nFlankers*nAction,1), repmat([1:nFlankers]', nAction, 1), 3*ones(nFlankers*nAction,1), NaN(nFlankers*nAction,1)]; % Neutral target is 3
forcedBasic = [2*ones(nFlankers*nAction,1), fullfact([nFlankers nAction]), NaN(nFlankers*nAction,1)];
cong = forcedBasic(:, 2) == forcedBasic(:, 3);
forcedBasic(cong, end) = 1;
forcedBasic(~cong, end) = 2;

clear cong

%% Define Eposide Types 

% This range should be repeated for each episodeType
% % Function of whether the episodes start with Free/Forced,
% % % within free, whether left vs. right flankers
% % % within forced, whether cong vs. incong trials

epTypes = [];
epTypes = [ones(nFlankers*nAction,1), fullfact([nFlankers nAction]), NaN(nFlankers*nAction,1);
           2*ones(nAction*nAction,1), fullfact([nFlankers nAction]), NaN(nFlankers*nAction,1)];
epTypes = [[1:size(epTypes,1)]', epTypes];
varNames= {'epType', 'choice', 'flankers', 'hiRewAct', 'cong'};
epTypes = array2table(epTypes, 'VariableNames', varNames);
% Reorder variables
epTypes = epTypes(:, {'epType', 'hiRewAct', 'choice', 'flankers', 'cong'});
nEpTypes = size(epTypes, 1);

% Set congruency for forced trials
forced  = epTypes.choice == 2;
epTypes.cong(forced) = epTypes.flankers(forced);
epTypes.flankers(forced) = NaN;

%% Pseudo-Randomise Episode Lengths
% Vector with sequence of episode lengths, pseudo-randomised, such that
% each sequence of 10 episodes has a randomisation of the full distribution
% Avoid more than 3 sequential episodes with same length

epLenRandFlag = 0;  % Flag if randomisation can't avoid same Ep Length sequences
if cfg.epLenXType
    tryAgain = 1;
    maxTries = 200;
    tryN     = 0;
    while tryAgain && tryN < maxTries
        tryN = tryN+1;

        epLengthsAll  = [];
        for et=1:nEpTypes
            epLengthsAll = [epLengthsAll, Shuffle(epLengths)];
        end

        % Avoid Ep Length repetitions
        maxRep = 3; % max allowed
        if ~HasConsecutiveValues(epLengthsAll, maxRep+1)
            tryAgain = 0;
        end
        if tryAgain == 1 && tryN == maxTries
           epLenRandFlag = 1;
        end
    end
else % for training
    epLengthsAll = Shuffle(epLengths);
end

%% Combine Pseudo-Random Episode Lengths & Ep Types
% Full list crossing epTypes with all the EpLengths
% Episode change must lead to change in high reward action
% Avoid long sequences of episodes starting with free or forced choices


epRandFlag = 0; % Flag if randomisation can't avoid sequences of choice/flankers
tryAgain = 1;
maxTries = 200;
tryN     = 0;
while tryAgain && tryN < maxTries
    tryN = tryN+1;
    epList = [];
    hiStart = randi(2); % which rewarded action to start with
    
    % Split the types epTypes
    hi    = [];
    hi{1} = Shuffle(epTypes{epTypes.hiRewAct == 1, :}, 2);
    hi{2} = Shuffle(epTypes{epTypes.hiRewAct == 2, :}, 2);
    hi1 = 0; hi2 = 0;

    % mod(x, 2) = 1 -> odd number; = 0 -> even
    for l = 1:length(epLengthsAll)
        
        % check whether to reshuffle
        if hi1 >= size(hi{1}, 1)
            hi{1} = Shuffle(epTypes{epTypes.hiRewAct == 1, :}, 2);
            hi1 = 0;
        end
        if hi2 >= size(hi{2}, 1)
            hi{2} = Shuffle(epTypes{epTypes.hiRewAct == 2, :}, 2);
            hi2 = 0;
        end
        
        
        % while ensuring that the high reward action will always switch        
        if hiStart == 1
            if mod(l,2)
                hi1 = hi1+1;
                epList = [epList;
                    epLengthsAll(l), hi{1}(hi1, :)];        
            else
                hi2 = hi2+1;
                epList = [epList;
                    epLengthsAll(l), hi{2}(hi2, :)];                
            end            
        else
            if mod(l,2)
                hi2 = hi2+1;
                epList = [epList;
                    epLengthsAll(l), hi{2}(hi2, :)];                
            else
                hi1 = hi1+1;
                epList = [epList;
                    epLengthsAll(l), hi{1}(hi1, :)];                
            end
        end        
    end 
   
    epList   = [[1:size(epList,1)]', epList];       
    varNames = {'epN', 'epLength', 'epType', 'hiRewAct', 'choice', 'flankers', 'cong'};
    epList   = array2table(epList, 'VariableNames', varNames);
    
    % Avoid Choice Type repetitions
    maxRep = 4; % max allowed
    if ~HasConsecutiveValues(epList.choice, maxRep+1)
        tryAgain = 0;
    end        
    if tryAgain == 1 && tryN == maxTries
       epRandFlag = 1;
    end
end


%% Randomise trials within Episodes

trialList = [];
tRandFlagEp = []; % Flag if randomisation can't avoid sequences of choice/flankers, by saving ep indices

for ep = 1:size(epList,1)
   
    tryAgain = 1;
    maxTries = 200;
    tryN     = 0;
    while tryAgain && tryN < maxTries
        tryN = tryN+1;        
        epTrialList = [];               
        
        nTrials = epList.epLength(ep);
        % columns: Choice, Flankers, Target (& Action, for forced), Congruency
        tempList  = repmat([freeBasic;forcedBasic], nTrials/minTrialN, 1);

        % draw a random trial matching requirements from epList
        if epList.choice(ep) == 1 % free
                            
            % check choice & flankers
            mList = tempList(:,1) == epList.choice(ep) &...
                    tempList(:,2) == epList.flankers(ep);
        else
            % check choice & congruency
            mList = tempList(:,1) == epList.choice(ep) &...
                    tempList(:,4) == epList.cong(ep);
        end
        ind = datasample(find(mList), 1);
        
        trialRest = Shuffle(tempList(1:nTrials~=ind,:), 2); % Shuffle by rows        
        epTrialList = [tempList(ind,:); trialRest];  

        % Avoid Choice type repetitions
        maxRep = 4; % max allowed
        if ~HasConsecutiveValues(epTrialList(:, 1), maxRep+1)
            tryAgain = 0;
        end            
        if tryAgain == 1 && tryN == maxTries
            tRandFlagEp = [tRandFlagEp, ep];
        end
    end 
        
    % add column with hiRewAct info
    epTrialList = [ repmat([ep, epList.epLength(ep),epList.epType(ep), epList.hiRewAct(ep)], nTrials, 1),...               
                   [1:nTrials]',...
                   epTrialList];             
	varNames  = {'epN', 'epLength','epType', 'hiRewAct', 'epTrialN', 'choice', 'flankers', 'target', 'cong'};                 
    epTrialList = array2table(epTrialList, 'VariableNames', varNames);             
           
    
    %% Define Outcomes, based on probabilities
    % Forced choice - Ensure outcome probabilities are held across congruency conditions

    outcomes = NaN(nTrials, length(probs));   
    for p=1:length(probs)        
        
        freeInd = epTrialList.choice == 1;        
        outcomes(freeInd, p) = Shuffle( getOutcomeDist(freeInd, probs(p)) );
        
        % Forced - subdivide also by congruency - probabilities will be average
        forcedCong = epTrialList.choice == 2 & epTrialList.cong == 1;
        outcomes(forcedCong, p) = Shuffle( getOutcomeDist(forcedCong, probs(p)) );        
        forcedIncong = epTrialList.choice == 2 & epTrialList.cong == 2;
        outcomes(forcedIncong, p) = Shuffle( getOutcomeDist(forcedIncong, probs(p)) );
    end            
    outcomes  = array2table(outcomes, 'VariableNames', {'out_hiRewAct', 'out_loRewAct'});
    epTrialList = [epTrialList, outcomes];    
    
    % save
    trialList = [trialList; epTrialList];
end

%% Record info
cfg.trialList      = trialList;
cfg.tRandFlagEp   = tRandFlagEp;
cfg.epList        = epList;
cfg.epRandFlag    = epRandFlag;
cfg.epLengthsAll  = epLengthsAll;
cfg.epLenRandFlag = epLenRandFlag;

