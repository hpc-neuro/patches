% experiment handles the preparation of the stimulus and the mask.
% It also calls post-presentation functions.

function experiment()

global exit_experiment exp_struct

bar = createBar(exp_struct.ptb_struct.w0_rect);
block = 1;
exit_experiment = 0;

delay = exp_struct.delay;

if exp_struct.eye_tracking
    Eyelink('Message', 'Start');
end

for i = 1:exp_struct.total
    i_mod_trials = mod(i, exp_struct.trials);
    if i_mod_trials == 0 && i < exp_struct.total
        block = block + 1;
        
    elseif i_mod_trials == 1
        if i > 1
            break_str = ...
                sprintf('%s\n\n', ...
                ['You have just completed block ' num2str(block-1) ...
                 ' of ' num2str(exp_struct.blocks) '.'], ...
                'You may take a short break.');
        else
            break_str = ...
                sprintf('%s\n\n', ...
                'Press the Space Bar to begin.');
        end
        DrawFormattedText(exp_struct.ptb_struct.w0, break_str, 'center', 'center');
        Screen('Flip', exp_struct.ptb_struct.w0);
        spacePress;
        pause(2); % give user a pause before next trial begins
    end
    
    left_index = exp_struct.trial_struct.lft_ndx(i);
    right_index = exp_struct.trial_struct.rgt_ndx(i);
    
    left_name = exp_struct.imgs(left_index).name;
    right_name = exp_struct.imgs(right_index).name;
    
    % left = 0   right = 1
    if exp_struct.trial_struct.target_flag(i)
        target_ndx = right_index;
    else
        target_ndx = left_index;
    end
    exp_struct.trial_struct.target_ndx(i) = target_ndx;
    
    % Get patch from target
    patch_struct = exp_struct.patch_data(target_ndx).patches(1);
    exp_struct.trial_struct.patch_struct{i} = patch_struct;
    
    % Read images
    im_left = imread([exp_struct.path_stim left_name]);
    im_right = imread([exp_struct.path_stim right_name]);
    im_patch = patch_struct.patch;
    
    % Convert to grayscale
    im_left = col2gray(im_left);
    im_right = col2gray(im_right);
    im_patch = col2gray(im_patch);
            
    % create the image texture
    left_tex = Screen('MakeTexture', exp_struct.ptb_struct.w0, im_left);
    right_tex = Screen('MakeTexture', exp_struct.ptb_struct.w0, im_right);
    exp_struct.ptb_struct.patch_tex = Screen('MakeTexture', exp_struct.ptb_struct.w0, im_patch);
    
    % draw the left texture to the backbuffer
    Screen('DrawTexture', exp_struct.ptb_struct.w0, left_tex);
    stimFlip(delay, i, exp_struct.ptb_struct);

    % draw right texture and then patch
    % TODO: This is really inelegant.
    stimFlip(delay, i, exp_struct.ptb_struct, right_tex);
    
    % show response bar
    [exp_struct.trial_struct.choice(i) exp_struct.trial_struct.confidence(i)] = responseBar(exp_struct.ptb_struct, ...
        bar, i, exp_struct, block);
    
    if exp_struct.sound
        if choice == exp_struct.trial_struct.target_flag(i)
            sound(exp_struct.ding, exp_struct.ding_rate);
        else
            sound(exp_struct.buzzer, exp_struct.buzzer_rate);
        end
    end
    Screen('DrawLines', exp_struct.ptb_struct.w0, exp_struct.ptb_struct.fix_xy, 2);
    
    [exp_struct.VBLTimestamp(i,3) exp_struct.StimulusOnsetTime(i,3) ...
        exp_struct.FlipTimestamp(i,3) exp_struct.Missed(i,3) ...
        exp_struct.Beampos(i,3)] = Screen('Flip', exp_struct.ptb_struct.w0);
    
    
    if i == exp_struct.total
        end_str = ...
            sprintf('%s\n\n', ...
            'You have completed the experiment.  Thank you for participating.');
        DrawFormattedText(exp_struct.ptb_struct.w0, end_str, 'center', 'center');
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


if exp_struct.eye_tracking
    Eyelink('StopRecording');
    Eyelink('CloseFile');
    edf_file = exp_struct.edf_file;
    try
        fprintf('receiving data file ''%s''\n', edf_file);
        status = Eyelink('ReceiveFile');
        if status > 0
            fprintf('ReceiveFile status %d\n', status);
        end
        if exist(edf_file, 'file') == 2
            fprintf('Data file ''%s'' can be found in ''%s''\n', edf_file, pwd);
        end
    catch rdf
        fprintf('Problem receiving data file ''%s''\n', edf_file);
        rdf;
    end
    
    asc_file = [exp_struct.exp_file, '_eyes.asc'];
    dos(['edf2asc ' edf_file]);
    copyfile('demo.asc', asc_file);
    
    Eyelink('Shutdown');
    
    exp_struct.eye_link_file = asc_file;
end

if exp_struct.save_mode
    save(exp_struct.exp_file, 'exp_struct');
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

% function rect = fndrect(img, side, xC, yC, gap)
% s = size(img);
% y = s(1);
% x = s(2);
% x2 = x/6;
% y2 = y/6;
% 
% if side
%     xC = xC - gap/2;
% else
%     xC = xC + gap/2;
% end
% 
% rect = [xC-x2 yC-y2 xC+x2 yC+y2];
% end

