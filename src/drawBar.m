function drawBar(w0,bar)
    
    %Screen('TextSize', w0, 24);
    Screen('DrawLines',w0, bar.rect, 3);
    Screen('DrawText',w0,'Undecided',bar.xC,bar.y);
    Screen('DrawText',w0,'First',bar.left,bar.y);
    Screen('DrawText',w0,'Second',bar.right,bar.y);