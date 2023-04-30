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
% fclose all; close all; clearvars; clc

numMC = 1;
n_nations = 10;
minGssnDQ = 0:0.2:1.0;
minGssnTrackingSuccessProb = zeros(size(minGssnDQ));
avgGssnMembership = zeros(size(minGssnDQ));
all_gssa_models = cell(length(minGssnDQ),1);
for iDQ = 1:length(minGssnDQ)
    gssa_model = Global_SSN_ABM_MCDriver(numMC,n_nations,minGssnDQ(iDQ));
    gssnTrackingSuccessProb = gssa_model.gssn.data.tracking_capacity ./ gssa_model.leo_environment.data.totalDebris;
    minGssnTrackingSuccessProb(iDQ) = min(gssnTrackingSuccessProb);
    avgGssnMembership(iDQ) = mean(gssa_model.gssn.data.total_members_cum);
    
    % store gssa_model
    all_gssa_models{iDQ} = gssa_model;
end

% Min GSSN Tracking Success Probability vs Min GSSN Data Quality
figure('Position',[600 400 720 420],'Color','w'); hold on; box on; grid on;
yline(1.0,'g--','LineWidth',1.5);
yline(1.2,'b--','LineWidth',1.5);
plot(minGssnDQ,minGssnTrackingSuccessProb,'k*');
title('');
xlabel('Minimum GSSN Required Data Quality','FontWeight','Bold');
ylabel('Minimum GSSN Tracking Success Probability','Fontweight','Bold');
legend({'100% Tracking Capacity Performance Requirement','120% Tracking Capacity Design Goal'},'Location','NorthEast');

% Avg GSSN Membership vs Min GSSN Data Quality
figure('Position',[600 400 720 420],'Color','w'); hold on; box on; grid on;
plot(minGssnDQ,avgGssnMembership,'k*');
title('');
xlabel('Minimum GSSN Required Data Quality','FontWeight','Bold');
ylabel('Average GSSN Membership','Fontweight','Bold');
