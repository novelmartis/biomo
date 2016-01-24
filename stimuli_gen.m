function [screenRect,output] = stimuli_gen(t,os_u,os_d,sizescrn,period,radius_os,length_os,length_bo)

% STIMULI_GEN  Generate oscillator stimuli.
%  
%   stimuli_gen(t,os_u,os_d,sizescrn,period,radius_os,length_os,length_bo)
%
%   will display 'os_u' against-gravity oscillators, and 'os_d' towards-gravity
%   oscillators, for 't' minutes.
%
%   Press the key 'q' to exit from the stimuli.
%
%   Optional: 'sizescrn' is a 1x4 vector which sets the screen size,'period'
%   sets the period of oscillation,'radius_os' sets the radius of the circles,
%   'length_os' sets the distance between neightbouring points in an oscillator, and
%   'length_bo'sets the body length.
%
%   To adjust for display resolution problems, use res_x and res_y on Line 196
%   (which is the resolution to which you want your stimuli to scale).
%
%   Look at the code to find more adjustable parameters.

switch nargin
    case 5
        radius_os = 10;
        length_os = 70;
        length_bo = 220;
    case 4
        period = 2;
        radius_os = 10;
        length_os = 70;
        length_bo = 220;
    case 3
        period = 2;
        sizescrn = [];
        radius_os = 10;
        length_os = 70;
        length_bo = 220;
    case 1
        os_u = 1;
        os_d = 3;
        period = 2;
        sizescrn = [];
        radius_os = 10;
        length_os = 70;
        length_bo = 220;
    otherwise
        t = .1;
        os_u = 1;
        os_d = 3;
        period = 2;
        sizescrn = [];
        radius_os = 10;
        length_os = 70;
        length_bo = 220;
end

% Press 'q' to exit
Screen('Preference', 'SkipSyncTests', 1);
ListenChar(2)

% An oscillator is made up of n_os points which oscillate maintaining one
% straight line between them.
n_os = 3;
%radius_os = 10;
%length_os = 70; % distance between the points on the oscillator
%length_bo = 220; % length of the oscillation body. The centre-line is fixed.

%os_u = 3; % no. of against-gravity oscillators
%os_d = 1; % no. of towards-gravity oscillators

degree = 90; % in deg
%period = 2; % in s

T = t*60; % total time of animation (in s)
interval = 1/16; % time-step (in s)

% bo_d_vec = 0:length_bo/(os_d-1):length_bo;
% bo_u_vec = 0:length_bo/(os_u-1+2):length_bo;
% bo_u_vec = bo_u_vec(2:end-1);

if os_d > os_u
    bo_d_vec = 0:length_bo/(os_d-1):length_bo;
    bo_u_vec = zeros(1,os_u);
    if mod(os_d,2)
        if ~mod(os_u,2) && os_u~=0
            looper = -os_u/2:1:os_u/2;
            looper((end+1)/2) = [];
            k = 1;
            for i = looper
                bo_u_vec(k) = bo_d_vec(1,(end+1)/2+i);
                k=k+1;
            end
        else
            diff = os_d - os_u;
            bo_u_vec = bo_d_vec(1,(1+diff/2):(end-diff/2));
        end
    else
        if mod(os_u,2)
            diff = os_d - os_u + 1;
            bo_u_vec1 = bo_d_vec(1,(1+diff/2):(end-diff/2));
            bo_u_vec(1,1) = bo_d_vec(1,diff/2);
            if os_u > 1
                bo_u_vec(1,2:end) = bo_u_vec1;
            end
        else
            diff = os_d - os_u;
            bo_u_vec = bo_d_vec(1,(1+diff/2):(end-diff/2));
        end
    end
else
    bo_u_vec = 0:length_bo/(os_u-1):length_bo;
    bo_d_vec = zeros(1,os_d);
    if mod(os_u,2)
        if ~mod(os_d,2) && os_d ~= 0
            looper = -os_d/2:1:os_d/2;
            looper((end+1)/2) = [];
            k = 1;
            for i = looper
                bo_d_vec(k) = bo_u_vec(1,(end+1)/2+i);
                k = k +1;
            end
        else
            diff = os_u - os_d;
            bo_d_vec = bo_u_vec(1,(1+diff/2):(end-diff/2));
        end
    else
        if mod(os_d,2)
            diff = os_u - os_d + 1;
            bo_d_vec1 = bo_u_vec(1,(1+diff/2):(end-diff/2));
            bo_d_vec(1,1) = bo_u_vec(1,diff/2);
            if os_d > 1
                bo_d_vec(1,2:end) = bo_d_vec1;
            end
        else
            diff = os_u - os_d;
            bo_d_vec = bo_u_vec(1,(1+diff/2):(end-diff/2));
        end
    end
end

time_vec = 0:interval:T;
ang_vec = linspace(0,2-2/(period/interval),(period)/(interval));
if mod(length(ang_vec),2)
    ang_vec(1,period/interval/2+1:end) = 2 - ang_vec(1,period/interval/2+1:end);
else
    ang_vec(1,period/interval/2+1:end) = 2 - ang_vec(1,period/interval/2+1:end);
end
ang_vec = ang_vec - 0.5;
ang_vec = degree*ang_vec;

for i = 1:n_os
    if i==1
        for k = 1:os_u
            myAnime(k).point = repmat([bo_u_vec(k)-radius_os -radius_os bo_u_vec(k)+radius_os radius_os],[length(time_vec),1]);
        end
    else
        for k = (i-1)*os_u+1:i*os_u
            coord_mat = zeros(length(time_vec),4);
            for t = 1:length(time_vec)
                pointer = mod(k,os_u);
                if pointer == 0
                    pointer = os_u;
                end
                coord_mat(t,1) = bo_u_vec(pointer)+(i-1)*length_os*sin(pi/180*ang_vec(mod(t,period/interval)+1))-radius_os;
                coord_mat(t,3) = bo_u_vec(pointer)+(i-1)*length_os*sin(pi/180*ang_vec(mod(t,period/interval)+1))+radius_os;
                coord_mat(t,2) = -(i-1)*length_os*cos(pi/180*ang_vec(mod(t,period/interval)+1))-radius_os;
                coord_mat(t,4) = -(i-1)*length_os*cos(pi/180*ang_vec(mod(t,period/interval)+1))+radius_os;
            end
            myAnime(k).point = coord_mat;
        end
    end
end

for i = 1:n_os
    if i==1
        for k = 1:os_d
            myAnime(k+os_u*n_os).point = repmat([bo_d_vec(k)-radius_os -radius_os bo_d_vec(k)+radius_os radius_os],[length(time_vec),1]);
        end
    else
        for k = (i-1)*os_d+1:i*os_d
            coord_mat = zeros(length(time_vec),4);
            for t = 1:length(time_vec)
                pointer = mod(k,os_d);
                if pointer == 0
                    pointer = os_d;
                end
                coord_mat(t,1) = bo_d_vec(pointer)+(i-1)*length_os*sin(pi/180*ang_vec(mod(t,period/interval)+1))-radius_os;
                coord_mat(t,3) = bo_d_vec(pointer)+(i-1)*length_os*sin(pi/180*ang_vec(mod(t,period/interval)+1))+radius_os;
                coord_mat(t,2) = (i-1)*length_os*cos(pi/180*ang_vec(mod(t,period/interval)+1))-radius_os;
                coord_mat(t,4) = (i-1)*length_os*cos(pi/180*ang_vec(mod(t,period/interval)+1))+radius_os;
            end
            myAnime(k+os_u*n_os).point = coord_mat;
        end
    end
end

[win, screenRect]=Screen('OpenWindow',0,0.*[1 1 1],sizescrn);
Screen(win,'TextSize',20);
HideCursor(win)

screenCntrX=screenRect(RectRight)/2;
screenCntrY=screenRect(RectBottom)/2;

res_x = screenRect(3);
res_y = screenRect(4);

for i =1:length(myAnime)
    myAnime(i).point(:,[1 3])=res_x/screenRect(3)*myAnime(i).point(:,[1 3])+screenCntrX-length_bo/2;
    myAnime(i).point(:,[2 4])=res_y/screenRect(4)*myAnime(i).point(:,[2 4])+screenCntrY;
end

for t = 1:length(time_vec)
    if t ==1
        now = tic;
    end
    keyName = '4';
    [keyPressed keyTime keyCode]=KbCheck;
    if keyPressed
        keyName=KbName(keyCode);
    end
    if strcmp(keyName,'q')
        break
    end
    for k = 1:length(myAnime)
        keyName = '4';
        [keyPressed keyTime keyCode]=KbCheck;
        if keyPressed
            keyName=KbName(keyCode);
        end
        if strcmp(keyName,'q')
            break
        end
        Screen('FillOval',win,255.*[1,1,1],myAnime(k).point(t,:))
    end
    if strcmp(keyName,'q')
        break
    end
    Screen(win,'Flip');
    keyName = '4';
    [keyPressed keyTime keyCode]=KbCheck;
    if keyPressed
        keyName=KbName(keyCode);
    end
    if strcmp(keyName,'q')
        break
    end
    pause(interval-toc(now))
    now = tic;
    keyName = '4';
    [keyPressed keyTime keyCode]=KbCheck;
    if keyPressed
        keyName=KbName(keyCode);
    end
    if strcmp(keyName,'q')
        break
    end
end
sca
output = ['Hope it was useful! Have a nice day :)'];
ListenChar(0)
