function [p] = runEpisodes_fun(cfg, hdr, p)
% Run Episodes for flankRevLearn task

% input: cfg    structure with Episode and Trial info
%        hdr    structure with Participant info
%        p      structure with all stim and timing parameters
% output: results from trial

% NS, Jan 2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


p.keys.STOP = checkKeys(p.keys.STOP, p.keys.kbInd);
if ~p.keys.STOP   
    
    hdr.date  = datestr(now,'yyyymmdd-HHMM');
    hdr.fname = sprintf('%s_S%02d_d%d_%s_%s', hdr.fnameBase, hdr.subj, hdr.session, cfg.stage, hdr.date);

    switch cfg.stage
        case 'train1'
            Line1 = ['Premiere partie de l''entrainement.\n\n\n',...
                     'Pendant cette partie, la bonne touche (qui rapporte plus d''argent) sera indiquee par une fleche verte.\n',...
                     'Essayez de reperer quand la bonne touche change.'];
        case 'train2'
            Line1 = ['Deuxieme partie de l''entrainement.\n\n\n',...
                     'Cette partie se deroule comme l''experience principale. A vous de trouver la bonne touche, et de vous adapter aux changements de regles.' ];
        case 'mainExp'
            Line1 = 'Experience principale.';
    end  
    Line2 = 'Appuyer sur la barre d''espace pour continuer.';
    Screen('TextSize', p.display.win, 26);                       
    DrawFormattedText(p.display.win, [Line1 '\n\n\n' Line2], 'center', 'center', p.colour.text, 80);
    Screen('Flip', p.display.win);           

    p.keys.STOP = wait4Key([], p.keys.STOP, p.keys.kbInd);

    Screen('Flip', p.display.win);
    WaitSecs(.5);

    
    
    if ~p.keys.STOP
    %% Loop through Trials within relevant Episodes
        switch cfg.stage
            case {'train1', 'train2'}  % run all in same session
                trialList = cfg.trialList;
            case 'mainExp' % sessions may be split
                epInds = cfg.sessionEps(:, hdr.session);
                trialList = cfg.trialList(ismember(cfg.trialList.epN, epInds), :);
        end  
        cfg.trialList = trialList;

        nTrials = size(trialList, 1);
        if cfg.nBreaks > 0
            breakFreq = round(nTrials/(cfg.nBreaks+1)); % +1, to divide session into equal parts
            breakTrials = [];
            for b = 1:cfg.nBreaks
                breakTrials = [breakTrials, breakFreq+(b-1)*breakFreq];
            end
        else
            breakTrials = [];        
        end
        cfg.breakTrials = breakTrials;


        for t = 1:nTrials

            trialInfo = trialList(t, :);

            [p, trialData, trialTimes] = runTrial_fun(trialInfo, p, cfg.stage);

            %% end of trial

            if ~p.keys.STOP

                trialData.breakTrial = ismember(t, breakTrials);

                data(t)  = trialData;
                times(t) = trialTimes;                    

                % break, stop, or continue
                if ismember(t, breakTrials)
                    message = 'Pause.';
                    Screen('TextSize', p.display.win, 26);                       
                    DrawFormattedText(p.display.win, message, 'center', 'center', p.colour.text, 80);
                    Screen('Flip', p.display.win);           

                    WaitSecs(p.time.breakDur);

                    message = 'Appuyer sur la barre d''espace pour continuer.';
                    DrawFormattedText(p.display.win, message, 'center', 'center', p.colour.text, 80);
                    Screen('Flip', p.display.win);           

                    p.keys.STOP = wait4Key(p.keys.space, p.keys.STOP, p.keys.kbInd);

                    Screen('Flip', p.display.win);
                    WaitSecs(.5);                

                elseif  t >= nTrials % Stop, if last trial
                    break
                else % ITI
                    WaitSecs( p.time.ITI(1) + (p.time.ITI(2)-p.time.ITI(1))*rand(1) );
                end                   

                % % % % % % % % %   SAVE!!
                save([hdr.subjPath filesep hdr.fname], 'hdr', 'data', 'times', 'p', 'cfg');
                fprintf('\n ****************** DATA SAVED!! ****************** \n')

            else % if ~p.keys.STOP
                if exist('data','var') % % % % SAVE
                    save([hdr.subjPath filesep hdr.fname], 'hdr', 'data', 'times', 'p', 'cfg');
                    fprintf('\n ****************** DATA SAVED!! ****************** \n')
                end

                fprintf('\n\n  ------------Experiment stopped by user!!------------\n')        
                return
            end 
        end % t = 1:nTrials

        % create table, as easier to handle later
        nTrials = length(data);
        subjInfo = array2table([hdr.subj*ones(nTrials,1), hdr.session*ones(nTrials,1)], 'VariableNames', {'subj','session'});
        dataTbl = [subjInfo, struct2table(data)];
        writetable(dataTbl, [hdr.subjPath, filesep, hdr.fname, '_dataTbl']);

        % % % % % % % % %   SAVE!!
        save([hdr.subjPath, filesep, hdr.fname], 'hdr', 'dataTbl', 'data', 'times', 'p', 'cfg');
        fprintf('\n ****************** DATA SAVED!! ****************** \n')

    else % if ~p.keys.STOP
        fprintf('\n\n  ------------Experiment stopped by user!!------------\n')        
        return
    end 
else % if ~p.keys.STOP
    fprintf('\n\n  ------------Experiment stopped by user!!------------\n')        
    return
end 
