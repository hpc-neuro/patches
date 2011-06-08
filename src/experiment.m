% experiment handles the preparation of the stimulus and the mask.  
% It also calls post-presentation functions. 

function experiment(button, p)
    
    global exit_experiment exp
    
    bar = createBar(p.w0_rect);
    block = 1;
    exit_experiment = 0;

    for i = 1:p.total/2
        if mod(i,p.trials) == 0 && i < p.total/2  % p.total
          block = block + 1;
	  % block = ceil( i / p.trials );
        	
        elseif mod(i,p.trials) == 1 && i < p.total
            if i > 1
                break_str = ...
                    sprintf('%s\n\n', ...
			    ['You have just completed block ' num2str(block-1) ' of ' num2str(p.blocks) '.'], ...
			    'You may take a short break.');
            else
                break_str = ...
                    sprintf('%s\n\n', ...
			    'Press the Space Bar to begin.');
            end
	    DrawFormattedText(p.w0, break_str, 'center', 'center');
            Screen('Flip',p.w0);
	    spacePress;
	    pause(2); % give user a pause before next trial begins
        end

        left_name = p.imgs(p.lft_ndx(i)).name;
	rght_name = p.imgs(p.rgt_ndx(i)).name;
        
	% left = 1   right = 0
    if exp.target_flag(i)
        base = p.lft_ndx(i);
    else
        base = p.rgt_ndx(i);
    end

	% high = 0    low = 1 
	exp.ptch_ndx(i) = 2*(base-1)+1+exp.hl_ndx(i);
	    
	ptch_name = p.ptchs(exp.ptch_ndx(i)).name;
	exp.pairs{i,1} = left_name;
	exp.pairs{i,2} = rght_name;
	exp.pairs{i,3} = ptch_name;

    im_left = col2gray(imread([p.path_s left_name]));
    im_rght = col2gray(imread([p.path_s rght_name]));
    im_ptch = imread([p.path_p ptch_name]);
    
	%figure, imshow([p.path_s left_name]);

        if p.delay
            delay = rand*.15;
        else
            delay = .1;
        end

        % create the image texture
        left_tex = Screen('MakeTexture', p.w0, im_left);
        rght_tex = Screen('MakeTexture', p.w0, im_rght); 
        p.ptch_tex = Screen('MakeTexture', p.w0, im_ptch);
        
      %  l_rect = fndrect(im_left,1,p.screen_xC,p.screen_yC,500);
      %  r_rect = fndrect(im_rght,0,p.screen_xC,p.screen_yC,500);
    
      % draw the imagx[e texture to the backbuffer
        Screen('DrawTexture', p.w0, left_tex);%, [], l_rect);
        %Screen('DrawTexture', p.w0, rght_tex, [], r_rect);
                
        % draw image
        max_priority = MaxPriority(p.w0);
        
        Rush('stimFlip(delay, i, p)', max_priority );
        Rush('stimFlip(delay, i, p,rght_tex)', max_priority );

        %% reaction time
        % reaction time is approximated by taking a timestamp
        % before keypress is called and then subtracting the timestamp
        % returned by keypress from the before timestamp
        % sD is the error term
        %s0 = GetSecs;
        %[exp.choice(i) exp.key_name{i} sN sD] = keyPress(w0, i, exp, block);
        [exp.choice(i) exp.confidence(i)] = responseBar(p, bar, i, exp, block);
        %exp.response_time(i, :) = [(sN-s0) sD];
	%spacepress;
	% draw the fixation lines
	Screen('DrawLines', p.w0, p.fix_xy, 2);
	
	[exp.VBLTimestamp(i,3) exp.StimulusOnsetTime(i,3) ...
	 exp.FlipTimestamp(i,3) exp.Missed(i,3) ...
	 exp.Beampos(i,3)] = Screen('Flip', p.w0);
	

        if exit_experiment
            %  ListenChar(0);
            Screen('CloseAll');
            break;
        end

        if i == p.total
            end_str = ...
                sprintf('%s\n\n', ...
                'You have completed the experiment.  Thank you for participating.');
            DrawFormattedText(p.w0, end_str, 'center', 'center');
            %resultsNum(false, [160 80 40 20]);
            Screen('Flip',w0);
            WaitSecs(3);
        end
        
        %% Missed Flip Messages

        %dispMisses();

        % close the textures
        Screen('Close');
        % idisp(i);
    end

    if p.save_mode || strcmp(button, 'Yes')
        save(p.data_file, 'exp');
    end

   %ListenChar(0);
    Screen('CloseAll');      
   % results();
end

function ret = col2gray(im)
%apply the luminance equation to the image

    ret = .2989*im(:,:,1) ...
        +.5870*im(:,:,2) ...
        +.1140*im(:,:,3);

end
  
function rect = fndrect(img, side, xC, yC, gap)
    s = size(img);
    y = s(1);
    x = s(2);
    x2 = x/6;
    y2 = y/6;
    
    if side 
	xC = xC - gap/2;
    else
	xC = xC + gap/2;
    end

    rect = [xC-x2 yC-y2 xC+x2 yC+y2];
end

    