%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AAE 560 - SoS Modeling and Analysis
% DAI Project
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fclose all; close all; clearvars; clc

tic;

simTime = 100; % [years]
simStep = 8; % [days]

ssn = SSNClass;
ssn = ssn.Run(simTime,simStep);
ssn.AnalysisPlots;

toc;