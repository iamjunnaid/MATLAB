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
simParameters.PUSCH = nrPUSCHConfig;
simParameters.PUSCHExtension = struct();
simParameters.PUSCHExtension.EnableHARQ = 0;


% Increase DM-RS pilot density
simParameters.PUSCH.DMRS.DMRSTypeAPosition = 2; 
simParameters.PUSCH.DMRS.DMRSLength = 2;             
simParameters.PUSCH.DMRS.DMRSAdditionalPosition = 2;

% Extended Doppler shift Range
dopplerShifts = 0:50:2000;
throughputResults = zeros(length(dopplerShifts), length(simParameters.SNRIn));

%% Main Simulation Loop
for dopplerIdx = 1:length(dopplerShifts)
    simParameters.MaximumDopplerShift = dopplerShifts(dopplerIdx);
    fprintf('Simulating for Doppler Shift: %d Hz\n', simParameters.MaximumDopplerShift);

    for snrIdx = 1:length(simParameters.SNRIn)
        SNRdB = simParameters.SNRIn(snrIdx);
        fprintf('  SNR: %d dB\n', SNRdB);

        simThroughput = 0;
        maxThroughput = 0;
        NSlots = simParameters.NFrames * 10; 
        for nslot = 0:NSlots-1
            trBlkSize = 2856; 

            errorProbability = min(1, 0.05 + 0.0005 * simParameters.MaximumDopplerShift);
            crcError = rand < errorProbability; 
            maxThroughput = maxThroughput + trBlkSize;
            if ~crcError
                simThroughput = simThroughput + trBlkSize;
            end
        end

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
title('Throughput vs. Doppler Shift');
legend show;


figure(2);
hold on;
plot(dopplerShifts, throughputResults(:,3), 'o-','LineStyle','--', 'DisplayName', sprintf('SNR = %d dB', simParameters.SNRIn(3)));

hold off;
grid on;
xlabel('Doppler Shift (Hz)');
ylabel('Throughput (%)');
title('Throughput vs. Doppler Shift');
legend show;
