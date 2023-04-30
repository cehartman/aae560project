%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Global_SSN_ABM_RQ1Driver.m
% AAE 560 - SoS Modeling & Analysis - Project
% Authors: Logan Greer, Charlie Hartman, Joe Mandara
% Creation Date: 4/15/2023
%
% This script runs a global Space Situational Awareness (SSA) Space
% Surveillance Network (SSN) Agent Based Model (ABM) and evaluates output
% performance metrics.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fclose all; close all; clearvars; clc
try
    delete(gcp('nocreate'));
    parpool(8);
catch err
    disp(err.message);
end

tic;

% Initialize Parameters
numMC = 2;
n_nations = 10;
minGssnDQ = 0:0.2:1.0;

% Design Variable Loop
all_gssa_models = cell(size(minGssnDQ));
parfor iDQ = 1:length(minGssnDQ)
    fprintf('Processing DV minGssnDQ = %.1f\n',minGssnDQ(1,iDQ));
    
    % Run Monte Carlo Simulations
    all_gssa_models{1,iDQ} = Global_SSN_ABM_MCDriver(numMC,n_nations,minGssnDQ(iDQ));
end

% Calculate Performance Metrics
avgGssnTrackingSuccessProb = zeros(size(minGssnDQ));
minGssnTrackingSuccessProb = zeros(size(minGssnDQ));
maxGssnTrackingSuccessProb = zeros(size(minGssnDQ));
stdGssnTrackingSuccessProb = zeros(size(minGssnDQ));
avgGssnMembership = zeros(size(minGssnDQ));
minGssnMembership = zeros(size(minGssnDQ));
maxGssnMembership = zeros(size(minGssnDQ));
stdGssnMembership = zeros(size(minGssnDQ));
for iDQ = 1:length(minGssnDQ)
    % GSSN Tracking Capacity
    gssnTrackingSuccessProb = all_gssa_models{1,iDQ}.gssn.data.tracking_capacity ./ all_gssa_models{1,iDQ}.leo_environment.data.totalDebris;
    avgGssnTrackingSuccessProb(1,iDQ) = mean(gssnTrackingSuccessProb);
    minGssnTrackingSuccessProb(1,iDQ) = min(gssnTrackingSuccessProb);
    maxGssnTrackingSuccessProb(1,iDQ) = max(gssnTrackingSuccessProb);
    stdGssnTrackingSuccessProb(1,iDQ) = std(gssnTrackingSuccessProb);
    
    % GSSN Membership
    avgGssnMembership(1,iDQ) = mean(all_gssa_models{1,iDQ}.gssn.data.total_members_cum);
    minGssnMembership(1,iDQ) = min(all_gssa_models{1,iDQ}.gssn.data.total_members_cum);
    maxGssnMembership(1,iDQ) = max(all_gssa_models{1,iDQ}.gssn.data.total_members_cum);
    stdGssnMembership(1,iDQ) = std(all_gssa_models{1,iDQ}.gssn.data.total_members_cum); 
end

% Min GSSN Tracking Success Probability vs Min GSSN Data Quality
figure('Position',[600 400 720 420],'Color','w'); hold on; box on; grid on;
plot(minGssnDQ,avgGssnTrackingSuccessProb,'ko','LineWidth',1.5);
yneg = avgGssnTrackingSuccessProb - minGssnTrackingSuccessProb;
ypos = maxGssnTrackingSuccessProb - avgGssnTrackingSuccessProb;
errorbar(minGssnDQ,avgGssnTrackingSuccessProb,yneg,ypos,'k.','LineWidth',1.5);
yline(1.0,'g--','LineWidth',1.5);
yline(1.2,'b--','LineWidth',1.5);
title('');
xlabel('Minimum GSSN Required Data Quality','FontWeight','Bold');
ylabel('GSSN Tracking Success Probability','Fontweight','Bold');
lgdStr = {'Avg Tracking Success Probability', ...
    'Min/Max Tracking Success Probability', ...
    '100% Tracking Capacity Performance Requirement', ...
    '120% Tracking Capacity Design Goal'};
legend(lgdStr,'Location','SouthWest');

% Avg GSSN Membership vs Min GSSN Data Quality
figure('Position',[600 400 720 420],'Color','w'); hold on; box on; grid on;
plot(minGssnDQ,avgGssnMembership,'ko','LineWidth',1.5);
yneg = avgGssnMembership - minGssnMembership;
ypos = maxGssnMembership - avgGssnMembership;
errorbar(minGssnDQ,avgGssnMembership,yneg,ypos,'k.','LineWidth',1.5);
title('');
xlabel('Minimum GSSN Required Data Quality','FontWeight','Bold');
ylabel('GSSN Membership','Fontweight','Bold');
lgdStr = {'Avg GSSN Membership', ...
    'Min/Max GSSN Membership'};
legend(lgdStr,'Location','SouthWest');

toc;
