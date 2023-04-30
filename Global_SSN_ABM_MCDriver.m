function gssa_model = Global_SSN_ABM_MCDriver(numMC,n_nations,minGssnDQ)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Global_SSN_ABM_MCDriver.m
% AAE 560 - SoS Modeling & Analysis - Project
% Authors: Logan Greer, Charlie Hartman, Joe Mandara
% Creation Date: 4/15/2023
%
% This script runs a global Space Situational Awareness (SSA) Space
% Surveillance Network (SSN) Agent Based Model (ABM) and evaluates output
% performance metrics.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fclose all; close all; %clearvars; clc

fixRndSeed = false;
all_gssa_models = cell(1,numMC);
parfor iMC = 1:numMC
    fprintf('\tProcessing MC %d\n',iMC);
    all_gssa_models{1,iMC} = Global_SSN_ABM(fixRndSeed,n_nations,minGssnDQ);
end
close all;
F = findall(0,'type','figure','tag','TMWWaitbar'); delete(F);

timeVec = all_gssa_models{1}.leo_environment.timeVec;
% n_nations = all_gssa_models{iMC}.n_nations;

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
gssa_model.leo_environment.data.totalDebris = mean(totalDebris,1);
gssa_model.gssn.data.tracking_capacity = mean(gssnTrackingCapacity,1);
gssa_model.leo_environment.data.totalCollisions = mean(totalCollisions,1);
gssa_model.gssn.data.combined_sensors = mean(gssnCombinedSensors,1);
gssa_model.leo_environment.data.leoSats = mean(leoSats,1);
if n_nations == 1
    dim = 1;
else
    dim = 2;
end
for iNation = 1:n_nations
    gssa_model.nations{iNation}.data.trackingCapacity = mean(squeeze(nationTrackingCapacity(iNation,:,:)),dim);
    gssa_model.nations{iNation}.data.totalSensors = mean(squeeze(nationTotalSensors(iNation,:,:)),dim);
    gssa_model.nations{iNation}.data.totalSatellites = mean(squeeze(nationTotalSatellites(iNation,:,:)),dim);
    gssa_model.nations{iNation}.data.budget = mean(squeeze(nationBudget(iNation,:,:)),dim);
    gssa_model.nations{iNation}.data.revenue = mean(squeeze(nationRevenue(iNation,:,:)),dim);
    gssa_model.nations{iNation}.data.cost = mean(squeeze(nationCost(iNation,:,:)),dim);
end
gssa_model.gssn.data.total_members_cum = mean(gssnTotalMembers,1);

% [finalCollisions, finalDebris] = GlobalSSN_AnalysisPlots(gssa_model,timeVec);
