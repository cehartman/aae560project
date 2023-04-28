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
Global_SSN_ABM_Params;

% Economics
econParams = Global_SSN_ABM_EconParams;

% Time
simTime = 100; % [years]
timeStep = 8; % [days]

% Environment
envParams = Global_SSN_ABM_LEOParams;

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
    Global_SSN_ABM_NationParams;
    
    newNation = NationAgent(timeVec, timeStep, iNation, sensors,...
        sensor_capability, sensor_request_rate, sensor_const_speed,...
        sensor_mfg_cost, sensor_ops_cost, sat_ops_cost, sat_proc_cost, ...
        sat_revenue, tech_cap, gssn_member, fuzz, starting_budget, nsat, ...
        sat_life, launch_rate);

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
