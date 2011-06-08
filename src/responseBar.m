function [choice confidence] = responseBar(p, bar, trial, exp, block)

global ptb_mouseclick_timeout exit_experiment train

ptb_mouseclick_timeout = .025;

SetMouse(p.screen_xC,bar.yy);
%WaitTicks(1);

press = '';
xC = p.screen_xC;
text_l = xC-xC/2;
text_r = xC+xC/2;


choice = 9;
count = 1;
if trial < 1200
    info_text = ...
        sprintf('%s\n\n', ...
        ['trial = ',num2str(trial)], ...
        'Escape: pause or exit', ...
        'Press YES or NO to answer');
end

while ~any(press)
    
    [x, y, press] = GetMouse(p.w0);
    %disp(['x: ',num2str(x),'   y: ',num2str(y)]);
    %Screen('FillRect',p.w0,128);
    if y > bar.min
        if x < bar.start
            x = bar.start;
        elseif x > bar.stop
            x = bar.stop;
        end
        Screen('FillRect',p.w0,[200 0 0],[x-5 bar.top x+5 bar.bot]);
        %Screen('DrawLine', p.w0, [200 0 0], x-5, bar_top, x+5, bar_bot);
    end
    
    %Screen('DrawLines',p.w0, bar, 3);
    drawBar(p.w0,bar);
    %Screen('DrawLines', p.w0, fix_xy, 2);
    
    if x < xC
        side = 'left';
        txt_x = text_l;
        choice = 1;
    elseif x > xC
        side = 'right';
        txt_x = text_r;
        choice = 0;
    else
        side = 'neither';
    end
    
    confidence = abs(xC-x);
    
    %Screen('DrawText',p.w0,num2str(confidence),txt_x,bar.y);
    [keyIsDown,b, keyCode] = KbCheck;
    keyName = KbName(keyCode);
    s = size(keyName);
    % disp(['count: ', num2str(size(keyName))]);
    % if someone presses two buttons at the same time an error will be
    % thrown; this prevents the error
    if s(2) == 2
        keyName = '';
    end
    
    if keyIsDown
        switch keyName
            
            case 'right'
                choice = 7;
                
            case 'i'
                %   disp('true')
                DrawFormattedText(p.w0, info_text, 'center', 'center');
                Screen('Flip', p.w0);
                pause;
                
            case 't'
                train = false;
                break;
                
            case 'esc'
                esc_str = sprintf('%s\n\n', ...
                    ['trial = ',num2str(trial)], ...
                    'Home: save', ...
                    'Escape: save and exit', ...
                    'End: exit without saving', ...
                    'Press YES or NO to answer');
                
                DrawFormattedText(p.w0, esc_str, 'center','center');
                Screen('Flip', p.w0);
                WaitSecs(.2);
                [a, keyCode2] = KbWait;
                keyName2 = KbName(keyCode2);
                
                switch keyName2
                    case 'end'
                        exit_experiment = true;
                        break;
                        
                    case 'Home'
                        save date_file exp;
                        break;
                        
                    case 'esc'
                        save date_file exp;
                        exit_experiment = true;
                        break;
                        
                    case 'right'
                        choice = 0;
                        break;  
                        
                    case 'left'
                        choice = 1;
                        break;
                end
                
            case 'end'
                exit_experiment = true;
                break;
                
            otherwise
                %disp('Unknown Key');
        end
    end
    
    Screen('DrawTexture', p.w0, p.ptch_tex);
    Screen('Flip',p.w0);
    
end



