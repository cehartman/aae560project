%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Global_SSN_ABM_RQ2Driver.m
% AAE 560 - SoS Modeling & Analysis - Project
% Authors: Logan Greer, Charlie Hartman, Joe Mandara
% Creation Date: 4/15/2023
%
% This script runs a global Space Situational Awareness (SSA) Space
% Surveillance Network (SSN) Agent Based Model (ABM) and evaluates output
% performance metrics.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fclose all; close all; clearvars; clc; rng('default');

% test parameters
numMC = 1;
n_nations = 10;
minGssnDQ = 0.6;
nat1TechCapabilityScale = [0.5:0.25:3.0];
timeStep = 8; % [days] %NOTE: this is also set independently at a lower level

% initialize data storage
minGssnTrackingSuccessProb = zeros(size(nat1TechCapabilityScale));
avgGssnMembership = zeros(size(nat1TechCapabilityScale));
all_gssa_models = cell(length(nat1TechCapabilityScale),1);
allNationParams(n_nations) = struct();

% Econ params are always the same for each nation
econParams.newSatCost = 171;    % million $ from OP
econParams.satOpCost = 1;       % million $ / year from OP
econParams.satOpRev = 279000/8261; % million $ / year per sat
econParams.newSensorCost = 1600; % million $ from Space Fence
econParams.sensorOpCost = 6;    % million $ / year from $33m/5yrs for SF
econParams.inflation = 1.0; % negate inflation; not relevant to RQs
econParams.sensorDiscount = 0;
econParams.sensorPenalty = 0;

% set fixed nation parameters (nation 1's SC changed later)
allNationParams(n_nations) = struct();
for iNat = 1:n_nations
    allNationParams(iNat).nationParams = Global_SSN_ABM_NationParams_Static(econParams,timeStep,iNat);
end

% iterate over nation 1 sensor capability DV
for iTC = 1:length(nat1TechCapabilityScale)
    
    curFactor = nat1TechCapabilityScale(iTC);
    % update nation 1's tech capabilities for the current DV iteration
    allNationParams(1).nationParams.sensor_capability = allNationParams(1).nationParams.sensor_capability*curFactor;
    allNationParams(1).nationParams.sensor_const_speed = allNationParams(1).nationParams.sensor_const_speed*(1/curFactor);
    allNationParams(1).nationParams.sensor_mfg_cost = allNationParams(1).nationParams.sensor_capability*(1/curFactor);
    
    % run MC simulation for current DV setting
    gssa_model = Global_SSN_ABM_MCDriver(numMC,allNationParams,econParams,minGssnDQ);
    gssnTrackingSuccessProb = gssa_model.gssn.data.tracking_capacity ./ gssa_model.leo_environment.data.totalDebris;
    minGssnTrackingSuccessProb(iTC) = min(gssnTrackingSuccessProb);
    avgGssnMembership(iTC) = mean(gssa_model.gssn.data.total_members_cum);
    avgNation1GssnMembership(iTC,:) = mean(gssa_model.nations{1}.data.gssnMembership,1);
    
    % store gssa_model
    all_gssa_models{iTC} = gssa_model;
end

% Min GSSN Tracking Success Probability vs Nation 1 Sensor Capability
figure('Position',[600 400 720 420],'Color','w'); hold on; box on; grid on;
yline(1.0,'g--','LineWidth',1.5);
yline(1.2,'b--','LineWidth',1.5);
plot(nat1TechCapabilityScale,minGssnTrackingSuccessProb,'k*');
title('');
xlabel('Nation 1 Tech Multiplier','FontWeight','Bold');
ylabel('Minimum GSSN Tracking Success Probability','Fontweight','Bold');
legend({'100% Tracking Capacity Performance Requirement','120% Tracking Capacity Design Goal'},'Location','NorthEast');

% Avg GSSN Membership vs Nation 1 Sensor Capability
figure('Position',[600 400 720 420],'Color','w'); hold on; box on; grid on;
plot(nat1TechCapabilityScale,avgGssnMembership,'k*');
title('');
xlabel('Nation 1 Tech Multiplier','FontWeight','Bold');
ylabel('Average GSSN Membership','Fontweight','Bold');

% Average GSSN Membership OverTime for Nation 1 vs Nation 1 Sensor Capability                             
plot_colors = distinguishable_colors(length(nat1TechCapabilityScale),'w');
timeVec  = 0:timeStep:100*365.2425;    % Simulation time steps [days]
xData = years(days(timeVec));
figure('Position',[600 400 720 420],'Color','w'); hold on; box on; grid on;
for iTC = 1:length(nat1TechCapabilityScale)
    plot(xData,avgNation1GssnMembership(iTC,:),'LineWidth',2,'Color',plot_colors(iTC,:));
end
title('');
xlabel('Time (Years)','FontWeight','Bold');
ylabel('Average Nation 1 GSSN Membership','Fontweight','Bold');
ax = gca; ax.XLim = round([xData(1) xData(end)]); ax.YLim = [0 1.1];
lgdStr = strcat({'Tech Multiplier '},strsplit(num2str(nat1TechCapabilityScale)));
legend(lgdStr,'location','northeastoutside');
