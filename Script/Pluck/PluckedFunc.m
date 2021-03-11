%% EXAM No. Y3859110
% Plucked String Digital Waveguide Sound Synthesis
% Based on travelling wave, two delay-line model.
% Variable plucking position and output.
% Simple bridge reflection coefficient.
% Univerity of York, Electronic Engineering,
% Adapted from Physical Modelling Synthesis Module - D.T.M. 29/1/2016.

%% Input Variables
% f0:                   Fundamental Frequency of string in Hz.
% pluckPosition:        Pluck Position as a proportion of string length.
% pickupPosition:       Pickup Position as a proportion of string length.
% bridgeReflection:     Reflection coefficient of the bridge.
% filename:             Saved filename.
% reverbEffect:         Enable/Disable reverb effect.
% roomType:             Room type of reverberation.
% filename:             Filename of saved output file.
% saveWav:              Enable/Disable save .wav of output.
% animate:              Animate the plucked string model compenents.
% plotTimeDomain:       Plot time domain of output.
% plotFreqDomain:       Plot frequency domain of output.
% plotSpectrogram:      Plot spectrogram of output.

function [out] = PluckedFunc(f0,pluckPosition, pickupPosition, bridgeReflection, reverbEffect, roomType, filename, saveWav, animate, plotTimeDomain, plotFreqDomain, plotSpectrogram)

Fs = 44100;         % Sample Rate for audio output
T = 1/Fs;           % Sample period
N = 44100;          % Number of samples in output

L = floor(0.5*Fs/f0); % String Length in samples

% Output Position (is "1 - position" to invert for GUI)
pickup = floor(L - floor(L*(1-pickupPosition))); 

r = -1 * bridgeReflection; % Bridge Reflection Coefficient

% Right-going delay line, defined by L
right = zeros(1,L);
% Left-going delay line, defined by L
left = zeros(1,L);

% Define initial string shape from pluck position x
pluck = pluckPosition*(L-1); % Find point on string corresponding to pluck position
pluckPosition = [([0:floor(pluck)]/pluck),(L-1-[(floor(pluck)+1):(L-1)])/(L-1-pluck)];

% Initial displacement for each delay line is equivalent to plucked string
% excitation shape divided by 2.
left(1:L) = pluckPosition(1:L)/2;
right(1:L) = pluckPosition(1:L)/2;

% Initialize output
out = zeros(1,N);

% Initialize variables for display
pkval = max(abs(pluckPosition));
string_pos = 1:L;

% Main digital waveguide loop
for n = 1:N
    
    % Shift left-going wave one step left; append dummy value for now
    left = [left(2:L),0];
    % At the 'nut' (left-hand end), assume perfect reflection (* -1).
    % New right-going value is negative of new value at nut of left-going
    nut = -left(1);
    % Add reflection from nut into first element of right-going delay line;
    % Shift right-going wave one step
    right = [nut, right(1:L-1)];
    % At the 'bridge' (right-hand end), assume perfect reflection (* -1).
    % New left-going value is negative of new value at bridge of right-going
    
    % Two-Point Moving Average Filter
    % bridge = (0.5)*(r*right(L)) + (0.5)*(r*right(L-1));
    
    % Three-Point Moving Average Filter
    bridge = r * (1/3) * (right(L) + right(L-1) + right(L-2));
    
    % Add new bridge value to end of left-going delay line, replacing dummy
    % value from above:
    left(L) = bridge;
    
    % Output is sum of left and right going delay lines at pickup point.
    % Calculate output:
    out(n) = left(pickup) + right(pickup);
    
    if animate
        % Plots and animates oscialltion
        % Resamples the output at a rate of Fs/200 to plot the mass
        % displacement in real-time.
        if mod(n,200)==0
            
            % Plot left and right-moving waves, and their sum
            plot(string_pos, left, string_pos, right, string_pos, left+right);
            
            % Make sure the axis scaling stays the same for each plot
            axis([1 L -pkval pkval]);
            
            drawnow;
        end
    end
end

% Normalize output to minimise clipping
out = out./max(abs(out)); 
%% Reverb

if reverbEffect
    out = MoorerReverb(out, roomType, Fs);
    out = out./max(abs(out)); 
    soundsc(out, Fs); % Play output
else
    soundsc(out, Fs); % Play output
end

%% Saving

% Save and write audio file
if saveWav
    % Normalize output to minimise clipping
    out = out./max(abs(out)); 
    audiowrite(strcat((filename),'.wav'),out,Fs);
end

%% Analysis

% Plot time domain response of output
if plotTimeDomain
    figure(2);
    plot(out);
    xlabel('Time (samples)');
    ylabel('Amplitude');
    title('Time Domain Response of Plucked String Model');
end

% Plot frequency domain response of output
if plotFreqDomain
    % FFT for frequency domain plot
    fftSize = 8192;
    f = (0:fftSize-1)*(Fs/fftSize);
    
    figure(3);
    semilogx(f,20*log10(abs(fft(out,fftSize))/max(abs(fft(out,fftSize)))));
    axis([0 16000 -40 0]);
    xlabel('Frequency (Hz)');
    ylabel('Magnitude Response (dB)');
    title('Frequency Domain Response of Plucked String Model');
end

% Plot spectrogram of output
if plotSpectrogram
    
    figure(4);
    spectrogram(out, window(@hann, 1024), 256, 1024, Fs, 'yaxis');
    xlabel('Time (samples)');
    ylabel('Frequency (KHz)');
    title('Spectrogram of Plucked String Model');
    set(gca,'YMinorTick','on')
end

end