function EyelinkGazeContingentDemo(mode)
path_r = 'C:\toolbox\DARPA\';   
movies = dir([path_r '*.mov']);   %mp4
dummymode=0;  

try
    delete('demo.asc');
end      

try
    delete('demo.edf');
end     

    stopkey=KbName('t');
    hazekey=KbName('space');
    if 1; Screen('Preference', 'SkipSyncTests', 1); end;
    commandwindow;
    hurryup=0;
    
    % Setup default mode to color vs. gray.
    if nargin < 1
        mode = 1;
    end;
    ms=150;
    screenNumber=max(Screen('Screens'));
    
    [w, wRect]=Screen('OpenWindow',screenNumber);
    %[win, scr_rect]=Screen(screen,'OpenWindow',0,[],[],2);

    % Set background color to gray.
    backgroundcolor=GrayIndex(w); % returns as default the mean gray value of screen
    el=EyelinkInitDefaults(w);
    
    if ~EyelinkInit(dummymode)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end 
    % We create a Luminance+Alpha matrix for use as transparency mask:
    % Layer 1 (Luminance) is filled with 'backgroundcolor'.
    transLayer=2;
    [x,y]=meshgrid(-ms:ms, -ms:ms);
    maskblob=ones(2*ms+1, 2*ms+1, transLayer) * backgroundcolor;
    % Layer 2 (Transparency aka Alpha) is filled with gaussian transparency
    % mask.
    xsd=ms/2.2;
    ysd=ms/2.2;
    maskblob(:,:,transLayer)=round(255 - exp(-((x/xsd).^2)-((y/ysd).^2))*255);
    
    % Build a single transparency mask texture:
    masktex=Screen('MakeTexture', w, maskblob);
    mRect=Screen('Rect', masktex);
    

    % Set background color to 'backgroundcolor' and do initial flip to show
    % blank screen:
    Screen('FillRect', w, backgroundcolor);
    Screen('Flip', w);
    Eyelink('command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
    Eyelink('Openfile', 'demo.edf');
    EyelinkDoTrackerSetup(el);
    EyelinkDoDriftCorrection(el);  
    WaitSecs(0.1);
    Eyelink('StartRecording');
    
    eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
    if eye_used == el.BINOCULAR; % if both eyes are tracked
        eye_used = el.LEFT_EYE; % use left eye
    end
    Screen('FillRect', w, backgroundcolor);
    Screen('Flip', w);
    [a,b]=RectCenter(wRect);
    WaitSetMouse(a,b,screenNumber); % set cursor and wait for it to take effect
    
    HideCursor;
    buttons=0;
    
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);
    % Wait until all keys on keyboard are released:
    while KbCheck; WaitSecs(0.1); end;
    
    mxold=0;
    myold=0;

    oldvbl=Screen('Flip', w);
    tavg = 0;
    ncount = 0;

    tRect= [0     0   1280   720]
    
    [ctRect, dx, dy]=CenterRect(tRect, wRect);
    nonfoveatex=Screen('MakeTexture', w, backgroundcolor);

for nn=1:1 %length(movies)       
    moviename=[path_r movies(nn).name];        
    [movie movieduration fps imgw imgh] = Screen('OpenMovie', w, moviename);        
    Screen('SetMovieTimeIndex', movie, 0);
    rate=1;
    Screen('PlayMovie', movie, rate);
    aa=0;
    while (1)
        Eyelink('Message',[moviename '-frame-' num2str(aa)] );

        [d, s, keyCode] = KbCheck;
        key_name = KbName(keyCode);
        aa=aa+1;
        %try
        foveatex = Screen('GetMovieImage', w, movie, 1);
     
        if foveatex<=0
              break;
        end;
        if keyCode(hazekey)
            EyeLink('Message', 'Haze Key pressed')
        
        if dummymode==0 %
            error=Eyelink('CheckRecording');
            if(error~=0)
                break;
            end
            
            if Eyelink( 'NewFloatSampleAvailable') > 0
                % get the sample in the form of an event structure
                evt = Eyelink( 'NewestFloatSample');
                if eye_used ~= -1 % do we know which eye to use yet?
                    % if we do, get current gaze position from sample
                    x = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
                    y = evt.gy(eye_used+1);
                    % do we have valid data and is the pupil visible?
                    if x~=el.MISSING_DATA && y~=el.MISSING_DATA && evt.pa(eye_used+1)>0
                        mx=x;
                        my=y;
                    end
                end
            end
        else
            
            % Query current mouse cursor position (our "pseudo-eyetracker") -
            % (mx,my) is our gaze position.
            if (hurryup==0)
                [mx, my, buttons]=GetMouse; %(w);
            else
                % In benchmark mode, we just do a quick sinusoidal motion
                % without query of the mouse:
                mx=500 + 500*sin(ncount/10); my=300;
            end;
        end
        % We only redraw if gazepos. has changed:
        if (mx~=mxold || my~=myold)
            % Compute position and size of source- and destinationrect and
            % clip it, if necessary...
            myrect=[mx-ms my-ms mx+ms+1 my+ms+1]; % center dRect on current mouseposition
            dRect = ClipRect(myrect,ctRect);
            sRect=OffsetRect(dRect, -dx, -dy);
            
            % Valid destination rectangle?
            if ~IsEmptyRect(dRect)
                % Yes! Draw image for current frame:
                
                % Step 1: Draw the alpha-mask into the backbuffer. It
                % defines the aperture for foveation: The center of gaze
                % has zero alpha value. Alpha values increase with distance from
                % center of gaze according to a gaussian function and
                % approach 255 at the border of the aperture...
                Screen('BlendFunction', w, GL_ONE, GL_ZERO);
                Screen('DrawTexture', w, masktex, [], myrect);
                
                % Step 2: Draw peripheral image. It is only drawn where
                % the alpha-value in the backbuffer is 255 or high, leaving
                % the foveated area (low or zero alpha values) alone:
                % This is done by weighting each color value of each pixel
                % with the corresponding alpha-value in the backbuffer
                % (GL_DST_ALPHA).
                Screen('BlendFunction', w, GL_DST_ALPHA, GL_ZERO);
                Screen('DrawTexture', w, nonfoveatex, [], ctRect);
                
                % Step 3: Draw foveated image, but only where the
                % alpha-value in the backbuffer is zero or low: This is
                % done by weighting each color value with one minus the
                % corresponding alpha-value in the backbuffer
                % (GL_ONE_MINUS_DST_ALPHA).
                Screen('BlendFunction', w, GL_ONE_MINUS_DST_ALPHA, GL_ONE);
                Screen('DrawTexture', w, foveatex, sRect, dRect);
                
                % Show final result on screen. This also clears the drawing
                % surface back to black background color and a zero alpha
                % value.
                % Actually... We use clearmode=2: This doesn't clear the
                % backbuffer, but we don't need to clear it for this kind
                % of stimulus and it gives us 2 msecs extra headroom for
                % higher refresh rates! For benchmark purpose, we disable
                % syncing to retrace if hurryup is == 1.
                vbl = Screen('Flip', w, 0, 2, 2*hurryup);
                vbl = GetSecs;
                tavg = tavg + (vbl-oldvbl);
                oldvbl=vbl;
                ncount = ncount + 1;
            end;
        end;
        Screen('Close', foveatex);
        % Keep track of last gaze position:
        mxold=mx;
        myold=my;
        else
            Screen('BlendFunction', w, GL_ONE, GL_ZERO);
            Screen('DrawTexture', w, foveatex);
            Screen('Flip', w);
            Screen('Close', foveatex);

        end     
        % if escape was pressed stop display
        if keyCode(stopkey)
            EyeLink('Message', 'Key pressed')
            break;
        end    
    end
    train_str = ...
     sprintf('%s\n\n',['Finished movie # ' num2str(nn) '\n Press the Space Bar to begin next movie.']);
     DrawFormattedText(w, train_str, 'center', 100);
     Screen('Flip',w);
     [a, keyCode2] = KbWait;
     
   
end %%%%%end movie loop 
       
    % stop eyelink
    Eyelink('StopRecording');
     Eyelink('CloseFile');
    % Display full image a last time, just for fun...
    
    
    tavg = tavg / ncount * 1000;
    fprintf('End of %s. Avg. redraw time is %f ms = %f Hz.\n\n', mfilename, tavg, 1000 / tavg);
    edf_file='demo.edf';
      try
        fprintf('Receiving data file ''%s''\n', edf_file );
        status=Eyelink('ReceiveFile');
        if status > 0
            fprintf('ReceiveFile status %d\n', status);
        end
        if 2==exist(edf_file, 'file')
            fprintf('Data file ''%s'' can be found in ''%s''\n', edf_file, pwd );
        end
    catch rdf  
        fprintf('Problem receiving data file ''%s''\n', edf_file );
        rdf;
      end
        
      seed_str=datestr(clock,30);
asc_file=[seed_str '.asc'];
      dos('edf2asc demo.edf')
      copyfile('demo.asc',asc_file);
    cleanup;
    return;

function cleanup
% Shutdown Eyelink:
Eyelink('Shutdown');

% Close window:
sca;
Priority(0);

commandwindow;


