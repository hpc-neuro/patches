% stim function flips the stimulus and then the mask

function stimFlip(delay, trial, p, rgt_tex)

    global exp
    
    r = p.refresh_rate * .5;
    
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
        [exp.VBLTimestamp(trial, 1) exp.StimulusOnsetTime(trial, 1) ...
            exp.FlipTimestamp(trial, 1) exp.Missed(trial, 1) ...
            exp.Beampos(trial, 1)] = Screen('Flip', p.w0, t0 + .3 + delay);
        
    elseif nargin == 4
        Screen('DrawTexture', p.w0, rgt_tex);
        % Flip the mask
        [exp.VBLTimestamp(trial, 2) exp.StimulusOnsetTime(trial, 2) ...
            exp.FlipTimestamp(trial, 2) exp.Missed(trial, 2) ...
            exp.Beampos(trial, 2)] = Screen('Flip', p.w0, ...
            exp.VBLTimestamp(trial, 1) + d);
        
        % if there is intermediate gray (that is, gray between the stimulus and
        % mask) then there is one more flip is required
        
        Screen('DrawTexture', p.w0, p.ptch_tex);
        
        % Flip the mask
        [exp.VBLTimestamp(trial, 3) exp.StimulusOnsetTime(trial, 3) ...
            exp.FlipTimestamp(trial, 3) exp.Missed(trial, 3) ...
            exp.Beampos(trial, 3)] = Screen('Flip', p.w0, ...
            exp.VBLTimestamp(trial, 2) + d);
    end
end