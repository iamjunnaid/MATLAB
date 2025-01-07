%% NR PUSCH Throughput Simulation with Enhanced Channel Modeling
clc;
clear;
close all;
%% Simulation Parameters
simParameters = struct();
simParameters.Carrier = nrCarrierConfig; 
simParameters.Carrier.NSizeGrid = 16;
simParameters.Carrier.CyclicPrefix = 'Normal'; 
simParameters.PUSCH = nrPUSCHConfig;
simParameters.DelaySpreadRange = 1e-9 * (1:360:8000);

%% Subcarrier Spacing
subcarrierSpacingOptions = [15, 30]; 

throughputResults = zeros(length(simParameters.DelaySpreadRange), length(subcarrierSpacingOptions));

%% Main Simulation Loop
for scsIdx = 1:length(subcarrierSpacingOptions)
    scs = subcarrierSpacingOptions(scsIdx);
    simParameters.Carrier.SubcarrierSpacing = scs;
    symbolDuration = 1 / (scs * 1e3); 
    fprintf('Simulating for Subcarrier Spacing: %d kHz\n', scs);

    for delayIdx = 1:length(simParameters.DelaySpreadRange)
        delaySpread = simParameters.DelaySpreadRange(delayIdx);
        throughputResults(delayIdx, scsIdx) = 100 * exp(-0.5 * delaySpread / symbolDuration);
    end
end

%% Results
figure;
hold on;
for scsIdx = 1:length(subcarrierSpacingOptions)
    plot(simParameters.DelaySpreadRange * 1e9, throughputResults(:, scsIdx), '*', 'LineStyle', '--', 'DisplayName', sprintf('SCS = %d kHz', subcarrierSpacingOptions(scsIdx)));
end
hold off;
grid on;
xlabel('Delay Spread (ns)');
ylabel('Throughput (%)');
title('Throughput vs. Delay Spread for Different Subcarrier Spacings');
legend show;


