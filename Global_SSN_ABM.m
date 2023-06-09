function [gssa_model, finalCollisions, finalDebris] = Global_SSN_ABM(fixRndSeed, allNationParams, econParams, minGssnDQ)
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
if nargin < 1
    fixRndSeed = false;
end
if nargin < 2
    n_nations = 10;
else
    n_nations = length(allNationParams);
end
if nargin < 3
    [~,econParams] = Global_SSN_ABM_NationParams(0);
end
if nargin < 4
    minGssnDQ = 0.0;
end
% clear;
% close all; clc;
if fixRndSeed
    rng(3);
end
F = findall(0,'type','figure','tag','TMWWaitbar'); delete(F);

addpath('Utilities');

%TODO: remove this when we're ready
global enable_environment_updates;
global environment_updates_only;
enable_environment_updates = 1;
environment_updates_only = 0;

% Initialize Adjustable Parameters / Design Variables
gssnFeeCoeff = [500 100]; % million $ / year
wait_times = [1 1 5]; % wait, leave, kick [years]

% Time
simTime = 100; % [years]
timeStep = 8; % [days]

% LEO Environment
envParams = Global_SSN_ABM_LEOParams(timeStep);

% Initialize Global SSA model
timeEnd  = simTime*365.2425;      % Simulation end time [days]                                 
timeVec  = 0:timeStep:timeEnd;    % Simulation time steps [days]
gssa_model = GlobalSSAModel(timeVec,timeStep,envParams);

% Add GSSN object 
gssn = GSSNObject(0, minGssnDQ, gssnFeeCoeff, wait_times, timeStep, timeVec);
gssa_model = gssa_model.add_gssn(gssn);

% Add nation agents
for iNation = 1:n_nations
    % determine nation-specific properties (some may be fixed for all 
    % nations, others may be set according to random distributions to make 
    % diverse nations)
    
    % create nation params
    if ~exist('allNationParams','var')
        [nationParams, econParams] = Global_SSN_ABM_NationParams(timeStep);
    else
        nationParams = allNationParams(iNation).nationParams;
    end
    
    % create nation
    newNation = NationAgent(timeVec, timeStep, iNation, ...
        nationParams.sensors, nationParams.sensor_capability, ...
        nationParams.sensor_request_rate, nationParams.sensor_const_speed,...
        nationParams.sensor_mfg_cost, nationParams.sensor_ops_cost, ...
        nationParams.sat_ops_cost, nationParams.sat_proc_cost, ...
        nationParams.sat_revenue, nationParams.tech_cap, ...
        nationParams.gssn_member, nationParams.fuzz, ...
        nationParams.starting_budget, nationParams.nsat, ...
        nationParams.sat_life, nationParams.launch_rate, ...
        nationParams.launchRateIncrease);
    
    % add nation to GSSA model
    gssa_model = gssa_model.add_nation(newNation);
    
    if newNation.gssn_member == true
        gssa_model = gssa_model.add_to_gssn(newNation, iNation);
    end
end

% initial GSSN update
gssa_model.gssn = gssa_model.gssn.update(gssa_model.nations,0);

% Start Simulation Steps
H = waitbar(0/timeVec(end),'Progress:');
for t = timeVec(2:end)
    % perform the next model step
    gssa_model = gssa_model.timestep(t,econParams);
    % update waitbar
    waitbar(t/timeVec(end),H)
end
waitbar(timeVec(end)/timeVec(end),H,'Simulation Complete!');

% generate analysis plots
% [finalCollisions, finalDebris] = GlobalSSN_AnalysisPlots(gssa_model,timeVec);
