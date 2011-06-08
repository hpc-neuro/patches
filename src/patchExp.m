% SoS is the main function for the speed of sight experiment.  
% Call this function to begin the experiment. 

function patchExp()
    
    global exp_struct
    
    %  addpath('Users/petavision/neuro_comp/dev/sosB/utilsB');
    
    % w0 is the window pointer
    % w0_rect is a 4-element array containing the x,y coordinates of the
    %   upper left and lower right corners of the screen   n   
    % w,h are the x,y midpoints of the screen
    % exp_struct is a data structure containing relevant experimental values
    % these functions will not work because of a problem with java
    % ListenChar(2);              % prevents key stokes from displaying
    % KbName('UnifyKeyNames');    % Switches internal naming scheme to
    % MacOS-X naming scheme   
    
    [button answer] = getInfo;
      
    % unsaved params %% should save patch_struct to exp_struct
    patch_struct = struct();
    
    % init window
    %Screen('Preference','SkipSyncTests', 1);
    maxScreen = max(Screen('Screens'));
    [patch_struct.w0, patch_struct.w0_rect] = ...
	Screen('OpenWindow',maxScreen);%, ([], [0 0 400 400]);
    
    patch_struct.screen_xC = patch_struct.w0_rect(3)/2;          % x midpoint
    patch_struct.screen_yC = patch_struct.w0_rect(4)/2;          % y midpoint

    %fixation coordinates
    xlen = 25;
    patch_struct.fix_xy = ...
	[patch_struct.screen_xC, patch_struct.screen_xC, patch_struct.screen_xC+xlen, patch_struct.screen_xC-xlen; ...
	 patch_struct.screen_yC+xlen, patch_struct.screen_yC-xlen, patch_struct.screen_yC, patch_struct.screen_yC];      

    Screen('TextSize', patch_struct.w0, 20);
    patch_struct.refresh_rate = Screen('GetFlipInterval',patch_struct.w0);
    
    patch_struct.blocks = 10;                 % number of blocks                 
    patch_struct.trials = 100;               % number of trials per block               
    patch_struct.total = patch_struct.blocks * patch_struct.trials;    % total number of trials   
    
    % saved params
    exp_struct = setExpValues(answer, patch_struct.total);    
    
    %% flags    
    %patch_struct.exit_experiment = false;
    patch_struct.save_mode = true;
    patch_struct.train = true;       %                                             %|
    patch_struct.delay = true;

    patch_struct.path_local = pwd; % local path
    patch_struct.path_local = [ patch_struct.path_local, '/'];
    src_ndx = strfind(patch_struct.path_local, '/src');
    patch_struct.path_parent = patch_struct.path_local(1:src_ndx);

    %%set background color
    Screen('FillRect', patch_struct.w0, 128);
    Screen('Flip', patch_struct.w0);

    %%set file name for storing experimental data
    patch_struct.path_results = ...
	[patch_struct.path_parent, '/results/'];
    if ~exist(patch_struct.path_results,'DIR')
      error(['~exist(patch_struct.path_results,'DIR'): ', ...
	     patch_struct.path_results]);
    end
    if strcmp(button,'Yes')
      patch_struct.path_exp = [patch_struct.path_results, '/official/'];
    else
      patch_struct.path_exp = [patch_struct.path_results, '/tmp/'];
    end
    patch_struct.exp_file = ...
	[patch_struct.path_exp, num2str(round(exp_struct.seed))];

    %%setup images
    %% assume all paths relative to current directory
    
    patch_struct.path_root = [patch_struct.path_local, '/data/']; 
    if ~exist(patch_struct.path_root,'DIR')
      error(['~exist('data','DIR): ', patch_struct.path_root]);
    end
    
    patch_struct.path_stim = [patch_struct.path_root, '/ALLSTIMULI/']; 
    if ~exist(patch_struct.path_stim,'DIR')
      error(['~exist('ALLSTIMULI','DIR'): ', patch_struct.path_stim]);
    end
    patch_struct.imgs  = dir([patch_struct.path_stim, '*.jpeg']);
    
    patch_struct.path_patches = [patch_struct.path_root, '/PATCHES4/']; 
    if ~exist(patch_struct.path_patches,'DIR')
      error(['~exist('PATCHES4','DIR'): ', patch_struct.path_patches]);
    end
    patch_struct.ptchs  = dir([patch_struct.path_patches, '*.jpeg']);

    contrast_match_flag = 1;
    [patch_struct.lft_ndx patch_struct.rgt_ndx] = ...
	contrastMatch(patch_struct,contrast_match_flag);

    
    
    %% draw an equal number of high and low salience images
    exp_struct.hl_ndx = ...
	Shuffle([zeros(patch_struct.total/2,1); ones(patch_struct.total/2,1)]);

    %% save everything
    exp_struct.patch_struct = patch_struct;

    %% start experiment
    instr(patch_struct.w0);
    exp_struct = experiment(button, p);
    Screen('CloseAll');
    exp.p = p;  %% save everything!
end  


function exp_struct = setExpValues(answer, tot)    

    nflips = 3;

    exp_struct = struct( ...
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
    exp_struct.seed = sum(100*clock);
    rand('twister', exp_struct.seed);     
    exp_struct.target_flag = Shuffle([ones(tot/2,1); zeros(tot/2,1)]);
    exp_struct.key_name = cell(tot,1);
    exp_struct.pairs = cell(tot,3);
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