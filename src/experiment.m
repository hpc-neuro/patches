% experiment handles the preparation of the stimulus and the mask.
% It also calls post-presentation functions.

function experiment(button, patch_struct)

global exit_experiment exp_struct

bar = createBar(patch_struct.w0_rect);
block = 1;
exit_experiment = 0;

for i = 1:patch_struct.total/2
    if mod(i,patch_struct.trials) == 0 && i < patch_struct.total/2
        block = block + 1;
        
    elseif mod(i,patch_struct.trials) == 1
        if i > 1
            break_str = ...
                sprintf('%s\n\n', ...
                ['You have just completed block ' num2str(block-1) ' of ' num2str(patch_struct.blocks) '.'], ...
                'You may take a short break.');
        else
            break_str = ...
                sprintf('%s\n\n', ...
                'Press the Space Bar to begin.');
        end
        DrawFormattedText(patch_struct.w0, break_str, 'center', 'center');
        Screen('Flip',patch_struct.w0);
        spacePress;
        pause(2); % give user a pause before next trial begins
    end
    
    left_name = patch_struct.imgs(patch_struct.lft_ndx(i)).name;
    rght_name = patch_struct.imgs(patch_struct.rgt_ndx(i)).name;
    
    % left = 0   right = 1
    if exp_struct.target_flag(i)
        target_ndx = patch_struct.rgt_ndx(i);
    else
        target_ndx = patch_struct.lft_ndx(i);
    end
    
    % Get patch from target
    patch = patch_struct.patch_data(target_ndx).patches(1);
    patch_data.patch = patch;
    
    im_left = col2gray(imread([patch_struct.path_s left_name]));
    im_rght = col2gray(imread([patch_struct.path_s rght_name]));
    im_ptch = imread([patch_struct.path_p ptch_name]);
    
    %figure, imshow([patch_struct.path_s left_name]);
    
    delay = exp_struct.delay;
    
    % create the image texture
    left_tex = Screen('MakeTexture', patch_struct.w0, im_left);
    rght_tex = Screen('MakeTexture', patch_struct.w0, im_rght);
    patch_struct.ptch_tex = Screen('MakeTexture', patch_struct.w0, im_ptch);
    
    %  l_rect = fndrect(im_left,1,patch_struct.screen_xC,patch_struct.screen_yC,500);
    %  r_rect = fndrect(im_rght,0,patch_struct.screen_xC,patch_struct.screen_yC,500);
    
    % draw the imagx[e texture to the backbuffer
    Screen('DrawTexture', patch_struct.w0, left_tex);%, [], l_rect);
    %Screen('DrawTexture', patch_struct.w0, rght_tex, [], r_rect);
    
    % draw image
    max_priority = MaxPriority(patch_struct.w0);
    
    Rush('stimFlip(delay, i, p)', max_priority );
    Rush('stimFlip(delay, i, p,rght_tex)', max_priority );
    
    % reaction time
    % reaction time is approximated by taking a timestamp
    % before keypress is called and then subtracting the timestamp
    % returned by keypress from the before timestamp
    % sD is the error term
    %s0 = GetSecs;
    %[exp_struct.choice(i) exp_struct.key_name{i} sN sD] = keyPress(w0, i, exp_struct, block);
    [exp_struct.choice(i) exp_struct.confidence(i)] = responseBar(p, bar, i, exp_struct, block);
    %exp_struct.response_time(i, :) = [(sN-s0) sD];
    %spacepress;
    % draw the fixation lines
    Screen('DrawLines', patch_struct.w0, patch_struct.fix_xy, 2);
    
    [exp_struct.VBLTimestamp(i,3) exp_struct.StimulusOnsetTime(i,3) ...
        exp_struct.FlipTimestamp(i,3) exp_struct.Missed(i,3) ...
        exp_struct.Beampos(i,3)] = Screen('Flip', patch_struct.w0);
    
    
    if exit_experiment
        %  ListenChar(0);
        Screen('CloseAll');
        break;
    end
    
    if i == patch_struct.total
        end_str = ...
            sprintf('%s\n\n', ...
            'You have completed the experiment.  Thank you for participating.');
        DrawFormattedText(patch_struct.w0, end_str, 'center', 'center');
        %resultsNum(false, [160 80 40 20]);
        Screen('Flip',w0);
        WaitSecs(3);
    end
    
    % Missed Flip Messages
    
    %dispMisses();
    
    % close the textures
    Screen('Close');
    % idisp(i);
end

if patch_struct.save_mode || strcmp(button, 'Yes')
    save(patch_struct.data_file, 'exp_struct');
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

