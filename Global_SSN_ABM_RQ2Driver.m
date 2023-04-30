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

% Initialize Parallel Computing
try
    delete(gcp('nocreate'));
    parpool(8);
catch err
    disp(err.message);
end

tic;

% Initialize Parameters
numMC = 10;
n_nations = 10;
minGssnDQ = 0.6;
nat1TechCapabilityScale = 0.5:0.5:4.0;
timeStep = 8; % [days] %NOTE: this is also set independently at a lower level

% Econ params are always the same for each nation
econParams.newSatCost = 171;    % million $ from OP
econParams.satOpCost = 1;       % million $ / year from OP
econParams.satOpRev = 279000/8261; % million $ / year per sat
econParams.newSensorCost = 1600; % million $ from Space Fence
econParams.sensorOpCost = 6;    % million $ / year from $33m/5yrs for SF
econParams.inflation = 1.0; % negate inflation; not relevant to RQs
econParams.sensorDiscount = 0;
econParams.sensorPenalty = 0;

% Set Fixed Nation Parameters (nation 1's SC changed later)
allNationParams(n_nations) = struct();
for iNat = 1:n_nations
    allNationParams(iNat).nationParams = Global_SSN_ABM_NationParams_Static(econParams,timeStep,iNat);
end

% Change Nation 1's Technological Capabilities
allNationParamsDV = repmat({allNationParams},size(nat1TechCapabilityScale));
for iTC = 1:length(nat1TechCapabilityScale)
    curFactor = nat1TechCapabilityScale(1,iTC);
    allNationParamsDV{1,iTC}(1).nationParams.sensor_capability = allNationParams(1).nationParams.sensor_capability*curFactor;
    allNationParamsDV{1,iTC}(1).nationParams.sensor_const_speed = allNationParams(1).nationParams.sensor_const_speed*(1/curFactor);
    allNationParamsDV{1,iTC}(1).nationParams.sensor_mfg_cost = allNationParams(1).nationParams.sensor_capability*(1/curFactor);
end

% Design Variable Loop
% Iterate Over Nation 1 Technological Capability DV
all_gssa_models = cell(size(nat1TechCapabilityScale));
parfor iTC = 1:length(nat1TechCapabilityScale)
    fprintf('Processing DV nat1TechCapabilityScale = %.1f\n',nat1TechCapabilityScale(1,iTC));
    
    % Run Monte Carlo Simulations for Current DV Setting
    all_gssa_models{1,iTC} = Global_SSN_ABM_MCDriver(numMC,allNationParamsDV{1,iTC},econParams,minGssnDQ);
end

% Calculate Performance Metrics
avgGssnTrackingSuccessProb = zeros(size(nat1TechCapabilityScale));
minGssnTrackingSuccessProb = zeros(size(nat1TechCapabilityScale));
maxGssnTrackingSuccessProb = zeros(size(nat1TechCapabilityScale));
stdGssnTrackingSuccessProb = zeros(size(nat1TechCapabilityScale));
avgGssnMembership = zeros(size(nat1TechCapabilityScale));
minGssnMembership = zeros(size(nat1TechCapabilityScale));
maxGssnMembership = zeros(size(nat1TechCapabilityScale));
stdGssnMembership = zeros(size(nat1TechCapabilityScale));
for iTC = 1:length(nat1TechCapabilityScale)
    % GSSN Tracking Capacity
    gssnTrackingSuccessProb = all_gssa_models{1,iTC}.gssn.data.tracking_capacity ./ all_gssa_models{1,iTC}.leo_environment.data.totalDebris;
    avgGssnTrackingSuccessProb(1,iTC) = mean(gssnTrackingSuccessProb);
    minGssnTrackingSuccessProb(1,iTC) = min(gssnTrackingSuccessProb);
    maxGssnTrackingSuccessProb(1,iTC) = max(gssnTrackingSuccessProb);
    stdGssnTrackingSuccessProb(1,iTC) = std(gssnTrackingSuccessProb);
    
    % GSSN Membership
    avgGssnMembership(1,iTC) = mean(all_gssa_models{1,iTC}.gssn.data.total_members_cum);
    minGssnMembership(1,iTC) = min(all_gssa_models{1,iTC}.gssn.data.total_members_cum);
    maxGssnMembership(1,iTC) = max(all_gssa_models{1,iTC}.gssn.data.total_members_cum);
    stdGssnMembership(1,iTC) = std(all_gssa_models{1,iTC}.gssn.data.total_members_cum);
    avgNation1GssnMembership(iTC,:) = mean(all_gssa_models{1,iTC}.nations{1}.data.gssnMembership,1);
end

% Min GSSN Tracking Success Probability vs Nation 1 Technological Capability
f1 = figure('Position',[600 400 720 420],'Color','w'); hold on; box on; grid on;
plot(nat1TechCapabilityScale,avgGssnTrackingSuccessProb,'ko','LineWidth',1.5);
yneg = avgGssnTrackingSuccessProb - minGssnTrackingSuccessProb;
ypos = maxGssnTrackingSuccessProb - avgGssnTrackingSuccessProb;
errorbar(nat1TechCapabilityScale,avgGssnTrackingSuccessProb,yneg,ypos,'k.','LineWidth',1.5);
yline(1.0,'g--','LineWidth',1.5);
yline(1.2,'b--','LineWidth',1.5);
title('');
xlabel('Nation 1 Technological Capability Multiplier','FontWeight','Bold');
ylabel('Minimum GSSN Tracking Success Probability','Fontweight','Bold');
lgdStr = {'Avg Tracking Success Probability', ...
    'Min/Max Tracking Success Probability', ...
    '100% Tracking Capacity Performance Requirement', ...
    '120% Tracking Capacity Design Goal'};
legend(lgdStr,'Location','SouthWest');
saveas(f1,['Analysis/RQ2/MinDQ_' strrep(num2str(minGssnDQ),'.','d') '/RQ2_GSSNTrackingProbability.fig']);
saveas(f1,['Analysis/RQ2/MinDQ_' strrep(num2str(minGssnDQ),'.','d') '/RQ2_GSSNTrackingProbability.png']);

% Avg GSSN Membership vs Nation 1 Technological Capability
f2 = figure('Position',[600 400 720 420],'Color','w'); hold on; box on; grid on;
plot(nat1TechCapabilityScale,avgGssnMembership,'ko','LineWidth',1.5);
yneg = avgGssnMembership - minGssnMembership;
ypos = maxGssnMembership - avgGssnMembership;
errorbar(nat1TechCapabilityScale,avgGssnMembership,yneg,ypos,'k.','LineWidth',1.5);
ax = gca; ax.YLim = [0 10];
title('');
xlabel('Nation 1 Technological Capability Multiplier','FontWeight','Bold');
ylabel('Average GSSN Membership','Fontweight','Bold');
lgdStr = {'Avg GSSN Membership', ...
    'Min/Max GSSN Membership'};
legend(lgdStr,'Location','SouthWest');
saveas(f2,['Analysis/RQ2/MinDQ_' strrep(num2str(minGssnDQ),'.','d') '/RQ2_GSSNMembership.fig']);
saveas(f2,['Analysis/RQ2/MinDQ_' strrep(num2str(minGssnDQ),'.','d') '/RQ2_GSSNMembership.png']);

% Nation 1 Average GSSN Membership Over Time per Nation 1 Technological Capability                             
plot_colors = distinguishable_colors(length(nat1TechCapabilityScale),'w');
timeVec  = 0:timeStep:100*365.2425;    % Simulation time steps [days]
xData = years(days(timeVec));
f3 = figure('Position',[600 400 720 420],'Color','w'); hold on; box on; grid on;
for iTC = 1:length(nat1TechCapabilityScale)
    plot(xData,avgNation1GssnMembership(iTC,:),'LineWidth',2,'Color',plot_colors(iTC,:));
end
title('');
xlabel('Time (Years)','FontWeight','Bold');
ylabel('Average Nation 1 GSSN Membership','Fontweight','Bold');
ax = gca; ax.XLim = round([xData(1) xData(end)]); ax.YLim = [0 1.1];
lgdStr = strcat({'Technological Capability Multiplier '},strsplit(num2str(nat1TechCapabilityScale)));
legend(lgdStr,'location','northeastoutside');
saveas(f3,['Analysis/RQ2/MinDQ_' strrep(num2str(minGssnDQ),'.','d') '/RQ2_GSSNMembershipNation1.fig']);
saveas(f3,['Analysis/RQ2/MinDQ_' strrep(num2str(minGssnDQ),'.','d') '/RQ2_GSSNMembershipNation1.png']);

toc;
