function bar = createBar(w0_rect)
    
    bar_y = w0_rect(4) - w0_rect(4)/6;
    bar_offset = 350;
    %bar_width = 3;
    %bar = [bar_start+5 bar_stop-5 bar_start+5 bar_start+5 bar_stop-5 bar_stop-5;
    %   bar_y bar_y bar_y-20 bar_y+20 bar_y-20 bar_y+20];

    bar = struct( ...
        'start', w0_rect(1)+bar_offset, ...
        'stop', w0_rect(3)-bar_offset, ...
        'top', bar_y - 40, ...
        'bot', bar_y + 40, ...
        'min', bar_y - 100, ...
        'xC', w0_rect(3)/2-50);
    
    bar.yy = bar_y;
    bar.y = bar.bot-20;
    bar.left = bar.start-18;
    bar.right = bar.stop-28;
    bar.rect = [bar.start bar.stop bar.start bar.start bar.stop bar.stop;
        bar_y bar_y bar_y-20 bar_y+20 bar_y-20 bar_y+20];