% wait until the space bar is pressed to continue

function spacePress()

    key_name = '';

    while ~strcmp(key_name,'space')
        [d, s, key] = KbCheck;
        key_name = KbName(key);
    end

end