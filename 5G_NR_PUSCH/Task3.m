%% NR PUSCH Throughput Simulation: Enhanced Doppler Shift Estimation with Delay Spread Analysis
clc;
clear;
close all;
%% Simulation Parameters
simParameters = struct();
simParameters.NFrames = 10; % Number of 10 ms frames
simParameters.SNRIn = -16:4:6; % SNR range (dB)
simParameters.Carrier = nrCarrierConfig; % Carrier configuration
simParameters.Carrier.NSizeGrid = 16; % 16 resource blocks
simParameters.Carrier.CyclicPrefix = 'Normal';

dopplerShifts = 0:50:1000; 
delaySpreads = [1e-9, 100e-9, 1000e-9];
estimationErrors = zeros(length(dopplerShifts), length(delaySpreads));

% Channel model
channel = nrTDLChannel;
channel.DelayProfile = 'TDL-C'; 
channel.SampleRate = 15e3 * simParameters.Carrier.NSizeGrid;

for delayIdx = 1:length(delaySpreads)
    fprintf('Simulating for Delay Spread: %.0f ns\n', delaySpreads(delayIdx) * 1e9);

    for dopplerIdx = 1:length(dopplerShifts)
        release(channel);
        channel.DelaySpread = delaySpreads(delayIdx); 
        channel.MaximumDopplerShift = dopplerShifts(dopplerIdx);
        
        txDMRS = exp(1j * 2 * pi * (0:127) / 128); % Generate DM-RS signals
        rxDMRS = channel(txDMRS.'); % Pass the DM-RS through the channel
        noisePower = var(txDMRS) ./ (10.^(simParameters.SNRIn / 10));
        noise = sqrt(noisePower(1) / 2) * (randn(size(rxDMRS)) + 1j * randn(size(rxDMRS)));
        rxDMRS = rxDMRS + noise;

        phaseDiff = angle(mean(rxDMRS(2:end) .* conj(rxDMRS(1:end-1)))); % Doppler shift estimation using phase difference
        estimatedDoppler = phaseDiff / (2 * pi / 128);

        % Calculate estimation error
        estimationErrors(dopplerIdx, delayIdx) = abs(dopplerShifts(dopplerIdx) - estimatedDoppler);
    end
end

%% Plot Estimation Errors
figure;
hold on;
for delayIdx = 1:length(delaySpreads)
    plot(dopplerShifts, estimationErrors(:, delayIdx), '-o', 'DisplayName', sprintf('Delay Spread = %.0f ns', delaySpreads(delayIdx) * 1e9));
end
hold off;
grid on;
xlabel('Doppler Shift (Hz)');
ylabel('Estimation Error (Hz)');
title('Doppler Shift Estimation Accuracy vs. Delay Spread');
legend show;
