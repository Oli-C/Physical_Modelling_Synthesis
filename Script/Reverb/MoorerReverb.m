%% EXAM No. Y3859110
% Moorer Reverberator function.
% Early Reflections and a low-pass filter in the feedback.
% Path of four comb filters, followed by two all-pass filters.
%
% Developed from examples in:
% "Hack Audio: An Introduction to Computer Programming and Digital Signal
% Processing in MATLAB" by Eric Tarr.
%
% Univerity of York, Electronic Engineering,
% Adapted from Physical Modelling Synthesis Module - D.T.M. 6/11/2018.

%% Input Variables
% input:        Input stream.
% roomType:     Room type of reverberation.
% Fs:           Sample rate of input.

function [out] = MoorerReverb(input, roomType, Fs)

% Zero pad the file so the output will include the reverb tail
in = [input';zeros(Fs*3,1)];

% Define impulse excitation for obtaining impulse response
IR_test = [zeros(Fs*3,1)];
IR_test(1) = 1;

% Initialize Main Output Signal
N_out = length(in);

out = zeros(N_out,1);
out1 = zeros(N_out,1);
out2 = zeros(N_out,1);
out3 = zeros(N_out,1);
out4 = zeros(N_out,1);

outComb = zeros(N_out,1);
outOneAllPass = zeros(N_out,1);

outRef = zeros(N_out,1);

% Initialize Impulse Response Output Signal
N_IR = length(IR_test);
IR_out = zeros(N_IR,1);

IR_out1 = zeros(N_IR,1);
IR_out2 = zeros(N_IR,1);
IR_out3 = zeros(N_IR,1);
IR_out4 = zeros(N_IR,1);

IR_outComb = zeros(N_IR,1);

IR_outOneAllPass = zeros(N_IR,1);

IR_outRef = zeros(N_IR,1);

% Set Maximum delay time for the unit reverberators of 70 ms
maxDelay = ceil(2.7*Fs); %0.07

% Initialize all buffers - one buffer per unit reverberator
Refbuffer = zeros(maxDelay,1);

buffer1 = zeros(maxDelay,1);
buffer2 = zeros(maxDelay,1);
buffer3 = zeros(maxDelay,1);
buffer4 = zeros(maxDelay,1);

buffer5 = zeros(maxDelay,1);
buffer6 = zeros(maxDelay,1);

% Initialise the Early Reflection Unit Tapped Delay Line

% Delay (ms) and Gain Parameters

if roomType == 'Hall'
    
    % Large Room Characteristics
    
    g1 = .9; % Gain of filters
    
    % Delay times for filters d1 - d4 FBCF, d5, d6 are AllPass
    d1 = floor(.0594*Fs); 
    d2 = floor(.0742*Fs);
    d3 = floor(.0822*Fs);
    d4 = floor(.0874*Fs);
    d5 = floor(.01*Fs);
    d6 = floor(.0034*Fs);
else
    
    % Small Room Characteristics
    
    g1 = .65; % Small gain for smaller reverb feedback.
    d1 = floor(.0297*Fs);
    d2 = floor(.0371*Fs);
    d3 = floor(.0411*Fs);
    d4 = floor(.0437*Fs);
    d5 = floor(.005*Fs);
    d6 = floor(.0017*Fs);
end

% Variables used as delay for a simple LPF in each Comb Filter function
fbLPF1 = 0;

% Impulse Response
for n = 1:N_IR
    
    % Early Reflection Tapped Delay Line
    [IR_outRef(n,1),Refbuffer] = EarlyReflections(IR_test(n,1),Refbuffer,Fs,n);
    
    % Parallel FBCFs
    [IR_out1(n,1),buffer1,fbLPF1] = FeedbackComb(IR_outRef(n,1),buffer1,n,d1,g1,fbLPF1,true);
    
    [IR_out2(n,1),buffer2,fbLPF1] = FeedbackComb(IR_outRef(n,1),buffer2,n,d2,g1,fbLPF1,true);
    
    [IR_out3(n,1),buffer3,fbLPF1] = FeedbackComb(IR_outRef(n,1),buffer3,n,d3,g1,fbLPF1,true);
    
    [IR_out4(n,1),buffer4,fbLPF1] = FeedbackComb(IR_outRef(n,1),buffer4,n,d4,g1,fbLPF1,true);
    
    IR_outComb(n,1) = ((IR_out1(n,1) + IR_out2(n,1) + IR_out3(n,1) + IR_out4(n,1)) / 4);
    
    % Two Series All-pass Filters
    
    [IR_outOneAllPass(n,1),buffer5] = AllPass(IR_outComb(n,1),buffer5,n,d5,g1);
    
    [IR_out(n,1),buffer6] = AllPass(IR_outOneAllPass(n,1),buffer6,n,d6,g1);
    
end

% Plot Impulse Response
% figure(5);
% plot(IR_out);


%% Plot

% Uncomment below for approx RT60 plot:

figure(5);
IR_out = IR_out/max(abs(IR_out)); % Normalize to Unity Gain (0 dB)
Ts = 1/Fs;
t = [0:N_IR-1]*Ts;
plot(t,20*log10(abs(IR_out)));
line([0 4],[-60 -60],'Color','red','LineStyle','--');
axis([0 4 -180 0])
title('RT60 of Reverb Out');


% Reverberate
for n = 1:N_out
    
    % Early Reflections Tapped Delay Line
    [outRef(n,1),Refbuffer] = EarlyReflections(in(n,1),Refbuffer,Fs,n);
    
    % Four Parallel FBCFs
    [out1(n,1),buffer1,fbLPF1] = FeedbackComb(outRef(n,1),buffer1,n,d1,g1,fbLPF1,true);
    [out2(n,1),buffer2,fbLPF1] = FeedbackComb(outRef(n,1),buffer2,n,d2,g1,fbLPF1,true);
    [out3(n,1),buffer3,fbLPF1] = FeedbackComb(outRef(n,1),buffer3,n,d3,g1,fbLPF1,true);
    [out4(n,1),buffer4,fbLPF1] = FeedbackComb(outRef(n,1),buffer4,n,d4,g1,fbLPF1,true);
    
    outComb(n,1) = (out1(n,1) + out2(n,1) + out3(n,1) + out4(n,1)) / 4;
    
    % Two Series All-pass Filters
    
    [outOneAllPass(n,1),buffer5] = AllPass(outComb(n,1),buffer5,n,d5,g1);
    [out(n,1),buffer6] = AllPass(outOneAllPass(n,1),buffer6,n,d6,g1);
end