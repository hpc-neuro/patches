% SoS is the main function for the speed of sight experiment.  
% Call this function to begin the experiment. 

function patchExp()
    
    global exp
    
    %  addpath('Users/petavision/neuro_comp/dev/sosB/utilsB');
    
    % w0 is the window pointer
    % w0_rect is a 4-element array containing the x,y coordinates of the
    %   upper left and lower right corners of the screen   n   
    % w,h are the x,y midpoints of the screen
    % exp is a data structure containing relevant experimental values
    % these functions will not work because of a problem with java
    % ListenChar(2);              % prevents key stokes from displaying
    % KbName('UnifyKeyNames');    % Switches internal naming scheme to
    % MacOS-X naming scheme   
    
    [button answer] = getInfo;
      
    % unsaved params %% should save p to exp
    p = struct();
    
    % init window
    %Screen('Preference','SkipSyncTests', 1);
    maxScreen = max(Screen('Screens'));
    [p.w0, p.w0_rect] = Screen('OpenWindow',maxScreen);%, [], [0 0 400 400]);
    
    p.screen_xC = p.w0_rect(3)/2;          % x midpoint
    p.screen_yC = p.w0_rect(4)/2;          % y midpoint

    %fixation coordinates
    xlen = 25;
    p.fix_xy = [p.screen_xC, p.screen_xC, p.screen_xC+xlen, p.screen_xC-xlen; ...
		p.screen_yC+xlen, p.screen_yC-xlen, p.screen_yC, p.screen_yC];      

    Screen('TextSize', p.w0, 14);
    p.refresh_rate = Screen('GetFlipInterval',p.w0);
    
    p.blocks = 10;                 % number of blocks                 
    p.trials = 100;               % number of trials per block               
    p.total = p.blocks * p.trials;    % total number of trials   
    
    % saved params
    exp = setExpValues(answer, p.total);    
    
    %% flags    
    %p.exit_experiment = false;
    p.save_mode = true;
    p.train = true;       %                                             %|
    p.delay = true;

    if strcmp(button,'Yes')
        p.data_file = ['..\results\official\', num2str(round(exp.seed))];
    else
        p.data_file = ['..\results\tmp\', num2str(round(exp.seed))];
    end

    %set background color
    Screen('FillRect', p.w0, 128);
    Screen('Flip', p.w0);

    %%setup images
    %% assume all paths relative to current directory
    p.path_l = pwd; % local path
    
    if ~exist('data','DIR)
      error('~exist('data','DIR)');
    end
    chdir('data');
    p.path_r = pwd; % root_path
    
    if ~exist('ALLSTIMULI','DIR)
      error('~exist('ALLSTIMULI','DIR)');
    end
    chdir('ALLSTIMULI');
    p.path_s = pwd; % directory containing full images
    p.imgs  = dir('*.jpeg');
    
    cd ..
    if ~exist('PATCHES4','DIR)
      error('~exist('PATCHES4','DIR)');
    end
    chdir('PATCHES4'); 
    p.path_p = pwd; % directory containing patches
    p.ptchs  = dir('*.jpeg');
    chdir p.path_l;

    % make sure that the left and right images are different
%     s = 1;
%     while (s > 0)
% 	p.lft_ndx = Shuffle(1:p.total);
% 	p.rgt_ndx = Shuffle(1:p.total);
% 	s = sum(p.lft_ndx == p.rgt_ndx);
%     end
    [p.lft_ndx p.rgt_ndx] = contrstMatch(p,false);
    % draw an equal number of high and low salience images
    exp.hl_ndx = Shuffle([zeros(p.total/2,1); ones(p.total/2,1)]);
    %% start experiment
    instr(p.w0);
    experiment(button, p);
    Screen('CloseAll');
    exp.p = p;  %% save everything!
end  


function exp = setExpValues(answer, tot)    

    nflips = 3;

    exp = struct( ...
        'vision', answer{1}, ...
        'age', answer{2}, ...
        'gender', answer{3}, ...
        'handedness', answer{4}, ...
        'participation', answer{5}, ...
        'familiarity', answer{6}, ...
        'response_time', zeros(tot, 2), ...
        'choice', repmat(10, tot, 1), ...
        'confidence', zeros(tot,1), ...
        'VBLTimestamp', zeros(tot, nflips), ...
        'StimulusOnsetTime', zeros(tot, nflips), ...
        'FlipTimestamp', zeros(tot, nflips), ...
        'Missed', zeros(tot, nflips), ...
        'Beampos', zeros(tot, nflips), ...
	'ptch_ndx', zeros(tot,1));
    
    % draw the target patch from the left or right image with equal
    % probability
    % random number generator
    exp.seed = sum(100*clock);
    rand('twister', exp.seed);     
    exp.target_flag = Shuffle([ones(tot/2,1); zeros(tot/2,1)]);
    exp.key_name = cell(tot,1);
    exp.pairs = cell(tot,3);
end


function [button answer] = getInfo()
    button = questdlg('Is this an official experiment?','official','No');
    if strcmp(button, 'Cancel');
        error('Cancelled')
    end

    prompt = {'Do you have normal or corrected-to-normal vision?', ...
	      'What is your age?', 'What is your gender?', ...
	      'Are you right handed or left handed?' ...
	      'How many times have you participated?  Enter 0 if this is your first time.', ...
	      'Are you familiar with this image set?'};
    dlg_title = 'Input';
    num_lines = 1;
    %def = {'20','hsv'};
    answer = inputdlg(prompt,dlg_title,num_lines);
end