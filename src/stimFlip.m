% stim function flips the stimulus and then the mask

function stimFlip(delay, trial, ptb_struct, rgt_tex)

    global exp_struct
    
    r = ptb_struct.refresh_rate * .5;
    
    tt = 1.5;
    
    %disp(num2str(tt));
    d = tt - r;

    
    %disp(num2str(delay));

    % VBLTimestamp is a high-precision estimate of when the flip
    %   happened (in system time)
    % StimulusOnsetTime is an estimate of when the stimulus onset
    % FlipTimestamp is a time measurement taken after Flip happens
    % A negative Missed means Flip's deadline was met, positive missed
    % Beampos is the position of the raster beam
    if nargin == 3
        t0 = GetSecs;
        % Flip the stimulus
        [exp_struct.VBLTimestamp(trial, 1) exp_struct.StimulusOnsetTime(trial, 1) ...
            exp_struct.FlipTimestamp(trial, 1) exp_struct.Missed(trial, 1) ...
            exp_struct.Beampos(trial, 1)] = Screen('Flip', ptb_struct.w0, t0 + .3 + delay);
        
    elseif nargin == 4
        Screen('DrawTexture', ptb_struct.w0, rgt_tex);
        % Flip the mask
        [exp_struct.VBLTimestamp(trial, 2) exp_struct.StimulusOnsetTime(trial, 2) ...
            exp_struct.FlipTimestamp(trial, 2) exp_struct.Missed(trial, 2) ...
            exp_struct.Beampos(trial, 2)] = Screen('Flip', ptb_struct.w0, ...
            exp_struct.VBLTimestamp(trial, 1) + d);
        
        % if there is intermediate gray (that is, gray between the stimulus and
        % mask) then there is one more flip is required
        
        Screen('DrawTexture', ptb_struct.w0, ptb_struct.patch_tex);
        
        % Flip the mask
        [exp_struct.VBLTimestamp(trial, 3) exp_struct.StimulusOnsetTime(trial, 3) ...
            exp_struct.FlipTimestamp(trial, 3) exp_struct.Missed(trial, 3) ...
            exp_struct.Beampos(trial, 3)] = Screen('Flip', ptb_struct.w0, ...
            exp_struct.VBLTimestamp(trial, 2) + d);
    end
end