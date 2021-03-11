% EARLYREFLECTIONS
% This function creates a tapped delay line to 
% be used for the Early Reflections of a reverb algorithm.
% The delays and gains of the taps are included below
% 
% Developed from examples in: 
% "Hack Audio: An Introduction to Computer Programming and Digital Signal
% Processing in MATLAB" by Eric Tarr.
%
% DTM, 6/11/2018
% 
% 10m x 5m room
% Src: (2,3); Rx: (5,4)
% https://amcoustics.com/tools/amray
% First Order
% 0.0093, 1
% 0.0125, 0.8
% 0.0206, 0.75
% 0.022,  0.74
% 0.038,  0.6
%
% Second Order
% 0.0223, 0.54
% 0.0276, 0.6
% 0.0287, 0.59
% 0.0333, 0.58
% 0.0389, 0.54
% 0.0429, 0.52
% 0.0496, 0.5
% 0.0671, 0.45

function [out,buffer] = EarlyReflections(in,buffer,Fs,n)

% Delay times converted from milliseconds

delayTimes = fix(Fs*[0.0093; 0.0125; 0.0206; 0.022; 0.0223; ...
     0.0276; 0.0287; 0.0333; 0.038; 0.0389; ...
    0.0429; 0.0496; 0.0671]);

% There must be a "gain" for each of the "delayTimes"
gains = [1; 0.8; -0.75; 0.74; 0.54; ...
        0.6; -0.59; 0.58; -0.6; 0.54; ...
        0.52; -0.5; 0.45];          

% Determine indexes for circular buffer
len = length(buffer);
indexC = mod(n-1,len) + 1; % Current index 
buffer(indexC,1) = in;

out = 0; % Initialize the output to be used in loop

% Loop through all the taps
for tap = 1:length(delayTimes)
    % Find the circular buffer index for the current tap
    indexTDL = mod(n-delayTimes(tap,1)-1,len) + 1;  
   
    % "Tap" the delay line and add current tap with output
    out = out + gains(tap,1) * buffer(indexTDL,1);
    
end






