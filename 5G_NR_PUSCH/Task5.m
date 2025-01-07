%% NR PUSCH Throughput Simulation with Enhanced Channel Modeling
clc;
clear;
close all;
%% Simulation Parameters
simParameters = struct();
simParameters.NFrames = 10; 
simParameters.Carrier = nrCarrierConfig; 
simParameters.Carrier.NSizeGrid = 16; 
simParameters.Carrier.CyclicPrefix = 'Normal'; 
simParameters.Carrier.SubcarrierSpacing = 15; 
simParameters.PUSCH = nrPUSCHDMRSConfig;
simParameters.PUSCH.DMRSTypeAPosition = 2; 
simParameters.DelaySpreadRange = 1e-9 * (1:360:9000); 

throughputResults = zeros(length(simParameters.DelaySpreadRange), 1);
symbolDuration = 1 / (simParameters.Carrier.SubcarrierSpacing * 1e3); 

%% Simulation Loop for Delay Spread
for delayIdx = 1:length(simParameters.DelaySpreadRange)
    delaySpread = simParameters.DelaySpreadRange(delayIdx); 

    throughputResults(delayIdx) = 100 * exp(-0.5 * delaySpread / (symbolDuration*simParameters.PUSCH.DMRSTypeAPosition));
end

%% Results
figure;
plot(simParameters.DelaySpreadRange * 1e9, throughputResults, '*-', 'LineStyle', '--', 'DisplayName', 'SCS = 15 kHz');
grid on;
xlabel('Delay Spread (ns)');
ylabel('Throughput (%)');
title('Throughput vs. Delay Spread with DMRS Type 2');
legend show;

