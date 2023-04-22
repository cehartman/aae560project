%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AAE 560 - SoS Modeling and Analysis
% DAI Project
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fclose all; close all; clearvars; clc

tic;

numMC = 10;
simTime = 100; % [years]
simStep = 8; % [days]
numCollisionsMC = zeros(numMC,ceil(simTime*365.2425/simStep));
numDebrisMC = zeros(numMC,ceil(simTime*365.2425/simStep));
for mc = 1:numMC
    ssn = SSNClassVV;
    ssn = ssn.Run(simTime,simStep);
    %ssn.AnalysisPlots;
    numCollisionsMC(mc,:) = ssn.data.totalCollisions;
    numDebrisMC(mc,:)     = ssn.data.totalDebris;
end

collisionAvg = mean(sum(numCollisionsMC,2));
collisionStdDev = std(sum(numCollisionsMC,2));


figure('Color','w'); hold on; box on; grid on;
plot(ssn.params.timeVec/365.2425,mean(numDebrisMC,1));
ax = gca; ax.YAxis.Exponent = 0; ax.YLim = [0 70000];
title('Average Number of Debris');
xlabel('Years','FontWeight','Bold');
ylabel('Debris Objects','FontWeight','Bold');

figure('Color','w'); hold on; box on; grid on;
plot(ssn.params.timeVec/365.2425,mean(cumsum(numCollisionsMC,2),1));
xlabel('Years','FontWeight','Bold');
title('Average Number of Collisions');
ylabel('Collisions','FontWeight','Bold');

toc;