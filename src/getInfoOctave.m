
function [button answer] = getInfoOctave()
  use_default_answers = 1;

  prompt = {'Do you have normal or corrected-to-normal vision?', ...
	    'What is your age?', ...
	    'What is your gender?', ...
	    'Are you right handed or left handed?' ...
	    'How many times have you participated?  Enter 0 if this is your first time.', ...
	    'Are you familiar with this image set?'};

  dlg_title = 'Input';
  answer = cell(size(prompt));
  num_answers = length(answer);

  if use_default_answers
    button = 'No';
    return;
  end

  fflush(stdout);
  button_number = ...
      menu('Is this an official experiment?', ...
	   'Yes', 'No', 'Cancel');
  if button_number == 1
    button = 'Yes';
  elseif button_number == 2
    button = 'No';
  elseif button_number == 3
    Screen('CloseAll');
    error('Cancelled')
  else
    button = 'No';
  end

  %% 1: 'Do you have normal or corrected-to-normal vision?'
  answer_number = ...
      menu(prompt{1}, ...
	   'Yes', 'No', 'Cancel');
  if answer_number == 1
    answer{1} = 'Yes';
  elseif answer_number == 2
    answer{1} = 'No';
  elseif answer_number == 3
    Screen('CloseAll');
    error('Cancelled')
  else
    answer{1} = '';
  end

  %% 2: 'What is your age?'
  answer_str = input(prompt{2}, 's')
  answer{2} = answer_str;

  %% 3: 'What is your gender?
  answer_number = ...
      menu(prompt{3}, ...
	   'Male', 'Female', 'Cancel');
  if answer_number == 1
    answer{3} = 'Male';
  elseif answer_number == 2
    answer{3} = 'Female';
  elseif answer_number == 3
    Screen('CloseAll');
    error('Cancelled')
  else
    answer{3} = '';
  end

  %% 4: 'Are you right handed or left handed?'
  answer_number = ...
      menu(prompt{4}, ...
	   'Right', 'Left', 'Cancel');
  if answer_number == 1
    answer{4} = 'Right';
  elseif answer_number == 2
    answer{4} = 'Left';
  elseif answer_number == 3
    Screen('CloseAll');
    error('Cancelled')
  else
    answer{4} = '';
  end

    
  %% 5: 'How many times have you participated?  Enter 0 if this is your first time.'
  answer_str = input(prompt{5}, 's')
  answer{5} = answer_str;

  %% 6: 'Are you familiar with this image set?'
  answer_number = ...
      menu(prompt{6}, ...
	   'Yes', 'No', 'Cancel');
  if answer_number == 1
    answer{6} = 'Yes';
  elseif answer_number == 2
    answer{6} = 'No';
  elseif answer_number == 3
    Screen('CloseAll');
    error('Cancelled')
  else
    answer{6} = '';
  end
    
end%%function