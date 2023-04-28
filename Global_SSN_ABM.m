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
clear; close all; clc; rng(3);
F = findall(0,'type','figure','tag','TMWWaitbar'); delete(F);

%TODO: remove this when we're ready
global enable_environment_updates;
global environment_updates_only;
enable_environment_updates = 1;
environment_updates_only = 0;

% Initialize Adjustable Parameters / Design Variables
n_nations = 1;
minGssnDQ = 0.8;
gssnFee   = 2000; % million $ / year

% Time
simTime = 100; % [years]
timeStep = 8; % [days]

% LEO Environment
envParams = Global_SSN_ABM_LEOParams(timeStep);

% Initialize Global SSA model
timeEnd  = simTime*365.2425;      % Simulation end time [days]                                 
timeVec  = 0:timeStep:timeEnd;    % Simulation time steps [days]
gssa_model = GlobalSSAModel(timeVec,timeStep,envParams);

%Add GSSN object 
%inputs: nn, dq, cost
gssn = GSSNObject(0, minGssnDQ, gssnFee, timeStep, timeVec);

gssa_model = gssa_model.add_gssn(gssn);

% Add nation agents
members = {};
for iNation = 1:n_nations
    % determine nation-specific properties (some may be fixed for all 
    % nations, others may be set according to random distributions to make 
    % diverse nations)
    
    % create nation and add to GSSA model
    [nationParams, econParams] = Global_SSN_ABM_NationParams(timeStep);
    
    newNation = NationAgent(timeVec, timeStep, iNation, ...
        nationParams.sensors, nationParams.sensor_capability, ...
        nationParams.sensor_request_rate, nationParams.sensor_const_speed,...
        nationParams.sensor_mfg_cost, nationParams.sensor_ops_cost, ...
        nationParams.sat_ops_cost, nationParams.sat_proc_cost, ...
        nationParams.sat_revenue, nationParams.tech_cap, ...
        nationParams.gssn_member, nationParams.fuzz, ...
        nationParams.starting_budget, nationParams.nsat, ...
        nationParams.sat_life, nationParams.launch_rate);

    gssa_model = gssa_model.add_nation(newNation); % supply inputs 

    if newNation.gssn_member == 1
        gssa_model = gssa_model.add_to_gssn(newNation, iNation);
    end
 

end

gssa_model.gssn = gssa_model.gssn.update(0);

% Start Simulation Steps
H = waitbar(0/timeVec(end),'Progress:');
for t = timeVec(2:end)
    % perform the next model step
    gssa_model = gssa_model.timestep(t,econParams);
    % update waitbar
    waitbar(t/timeVec(end),H)
end
waitbar(timeVec(end)/timeVec(end),H,'Simulation Complete!');

[finalCollisions, finalDebris] = GlobalSSN_AnalysisPlots(gssa_model,timeVec);
