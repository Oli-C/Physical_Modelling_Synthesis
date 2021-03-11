% Feedback Comb Filter Reverberator
% This function creates a feed-back comb filter by 
% processing an individual input sample and updating 
% a delay buffer used in a loop to index each sample
% in a signal. Option for Low Pass Filter in feedback loop set by a flag.
%
% Developed from examples in: 
% "Hack Audio: An Introduction to Computer Programming and Digital Signal
% Processing in MATLAB" by Eric Tarr.
%
% DTM, 6/11/2018
% 
% Input Variables
%   n : current sample number of the input signal
%   delay : samples of delay
%   fbGain : feed-back gain (linear scale)
%   fbLPF: for low pass filter
%   LPF: flag to set filter on/off    
%

function [out,buffer,fbLPF] = FeedbackComb(in,buffer,n,delay,fbGain,fbLPF,LPF)

% Determine indexes for circular buffer
len = length(buffer);
indexC = mod(n-1,len) + 1; % Current index 
indexD = mod(n-delay-1,len) + 1; % Delay index

out = buffer(indexD,1);

if indexD == 1
    outPrevious = buffer(len,1);
else
    outPrevious = buffer(indexD - 1,1);
end

% Store the current output in appropriate index
% LPF in feedback loop - Two point moving average
if LPF == true
    buffer(indexC,1) = in + 0.5*fbGain*(out + outPrevious);
else
    buffer(indexC,1) = in + fbGain*out;
end
% Store the current output for the Feedback LPF 
% to be used with the next sample
fbLPF = out;


