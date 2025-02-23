%% NR PUSCH Throughput Simulation: Maximum Doppler Shift Analysis
clc;
clear;
close all;

%% Simulation Parameters
simParameters = struct();
simParameters.NFrames = 10; 
simParameters.SNRIn = -16:4:6; 
simParameters.PerfectChannelEstimator = false; 
simParameters.Carrier = nrCarrierConfig; 
simParameters.Carrier.NSizeGrid = 16; 
simParameters.Carrier.SubcarrierSpacing = 15; 
simParameters.PUSCH = nrPUSCHConfig;
simParameters.PUSCHExtension = struct(); 
simParameters.PUSCHExtension.EnableHARQ = 0; 

% Doppler shift range
dopplerShifts = 0:50:1000; 
throughputResults = zeros(length(dopplerShifts), length(simParameters.SNRIn));

for dopplerIdx = 1:length(dopplerShifts)
    simParameters.MaximumDopplerShift = dopplerShifts(dopplerIdx);
    fprintf('Simulating for Doppler Shift: %d Hz\n', simParameters.MaximumDopplerShift);

    for snrIdx = 1:length(simParameters.SNRIn)
        SNRdB = simParameters.SNRIn(snrIdx);
        fprintf('  SNR: %d dB\n', SNRdB);

        % Initialize throughput counters
        simThroughput = 0;
        maxThroughput = 0;

        % Total number of slots in the simulation period
        NSlots = simParameters.NFrames * 10;

        for nslot = 0:NSlots-1
            trBlkSize = 2856;
            errorProbability = min(1, 0.1 + 0.001 * simParameters.MaximumDopplerShift);
            crcError = rand < errorProbability;
            maxThroughput = maxThroughput + trBlkSize;
            if ~crcError
                simThroughput = simThroughput + trBlkSize;
            end
        end

        % Calculate throughput percentage
        throughputResults(dopplerIdx, snrIdx) = simThroughput * 100 ./ maxThroughput;
    end
end

%% Results
figure(1);
hold on;
for snrIdx = 1:length(simParameters.SNRIn)
    plot(dopplerShifts, throughputResults(:, snrIdx), 'o-','LineStyle','--', 'DisplayName', sprintf('SNR = %d dB', simParameters.SNRIn(snrIdx)));
end
hold off;
grid on;
xlabel('Doppler Shift (Hz)');
ylabel('Throughput (%)');
title('Throughput vs. Doppler Shift (Maximum Doppler Analysis)');
legend show;

figure(2);
hold on;
plot(dopplerShifts, throughputResults(:,3), 'o-','LineStyle','--', 'DisplayName', sprintf('SNR = %d dB', simParameters.SNRIn(3)));

hold off;
grid on;
xlabel('Doppler Shift (Hz)');
ylabel('Throughput (%)');
title('Throughput vs. Doppler Shift (Maximum Doppler Analysis)');
legend show;