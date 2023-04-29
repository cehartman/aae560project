%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Global_SSN_ABM.m
% AAE 560 - SoS Modeling & Analysis - Project
% Authors: Logan Greer, Charlie Hartman, Joe Mandara
% Creation Date: 4/15/2023
%
% This script runs a global Space Situational Awareness (SSA) Space
% Surveillance Network (SSN) Agent Based Model (ABM) and evaluates output
% performance metrics.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fclose all; close all; clearvars; clc

numMC = 10;
all_gssa_models = cell(numMC,1);
for iMC = 1:numMC
    Global_SSN_ABM;
    all_gssa_models{iMC} = gssa_model;
end

% Re-create data structures
% (excludes sensor status and GSSN membership status plots)
gssa_model = struct;
totalDebris = zeros(numMC,length(timeVec));
gssnTrackingCapacity = zeros(numMC,length(timeVec));
totalCollisions = zeros(numMC,length(timeVec));
gssnCombinedSensors = zeros(numMC,length(timeVec));
leoSats = zeros(numMC,length(timeVec));
nationTrackingCapacity = zeros(n_nations,numMC,length(timeVec));
nationTotalSensors = zeros(n_nations,numMC,length(timeVec));
nationTotalSatellites = zeros(n_nations,numMC,length(timeVec));
nationBudget = zeros(n_nations,numMC,length(timeVec));
nationRevenue = zeros(n_nations,numMC,length(timeVec));
nationCost = zeros(n_nations,numMC,length(timeVec));
gssnTotalMembers = zeros(numMC,length(timeVec));
for iMC = 1:numMC
    totalDebris(iMC,:) = all_gssa_models{iMC}.leo_environment.data.totalDebris;
    gssnTrackingCapacity(iMC,:) = all_gssa_models{iMC}.gssn.data.tracking_capacity;
    totalCollisions(iMC,:) = all_gssa_models{iMC}.leo_environment.data.totalCollisions;
    gssnCombinedSensors(iMC,:) = all_gssa_models{iMC}.gssn.data.combined_sensors;
    leoSats(iMC,:) = all_gssa_models{iMC}.leo_environment.data.leoSats;
    for iNation = 1:n_nations
        nationTrackingCapacity(iNation,iMC,:) = all_gssa_models{iMC}.nations{iNation}.data.trackingCapacity;
        nationTotalSensors(iNation,iMC,:) = all_gssa_models{iMC}.nations{iNation}.data.totalSensors;
        nationTotalSatellites(iNation,iMC,:) = all_gssa_models{iMC}.nations{iNation}.data.totalSatellites;
        nationBudget(iNation,iMC,:) = all_gssa_models{iMC}.nations{iNation}.data.budget;
        nationRevenue(iNation,iMC,:) = all_gssa_models{iMC}.nations{iNation}.data.revenue;
        nationCost(iNation,iMC,:) = all_gssa_models{iMC}.nations{iNation}.data.cost;
    end
    gssnTotalMembers(iMC,:) = all_gssa_models{iMC}.gssn.data.total_members_cum;
end
gssa_model.leo_environment.data.totalDebris = mean(totalDebris);
gssa_model.gssn.data.tracking_capacity = mean(gssnTrackingCapacity);
gssa_model.leo_environment.data.totalCollisions = mean(totalCollisions);
gssa_model.gssn.data.combined_sensors = mean(gssnCombinedSensors);
gssa_model.leo_environment.data.leoSats = mean(leoSats);
for iNation = 1:n_nations
    gssa_model.nations{iNation}.data.trackingCapacity = mean(squeeze(nationTrackingCapacity(iNation,:,:)));
    gssa_model.nations{iNation}.data.totalSensors = mean(squeeze(nationTotalSensors(iNation,:,:)));
    gssa_model.nations{iNation}.data.totalSatellites = mean(squeeze(nationTotalSatellites(iNation,:,:)));
    gssa_model.nations{iNation}.data.budget = mean(squeeze(nationBudget(iNation,:,:)));
    gssa_model.nations{iNation}.data.revenue = mean(squeeze(nationRevenue(iNation,:,:)));
    gssa_model.nations{iNation}.data.cost = mean(squeeze(nationCost(iNation,:,:)));
end
gssa_model.gssn.data.total_members_cum = mean(gssnTotalMembers);

[finalCollisions, finalDebris] = GlobalSSN_AnalysisPlots(gssa_model,timeVec);
