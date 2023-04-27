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

% Initialize Adjustable Parameters
n_nations = 150;


% Economics
econParams.newSatCost = 171;    % million $ from OP
econParams.satOpCost = 1;       % million $ / year from OP
econParams.satOpRev = 279000/8261; % million $ / year per sat
econParams.newSensorCost = 1600; % million $ from Space Fence
econParams.sensorOpCost = 6;    % million $ / year from $33m/5yrs5mo for SF
econParams.inflation = 1.0; % assume 3% annually 
nationalBudgetsRange = [10000 50000]; % million $


% Time
simTime = 100; % [years]
timeStep = 8; % [days]

% Environment
envParams.leoVol             = 5.54e11*(1e9);              % LEO shell volume [km^3]
envParams.initialSPD         = 2e-8*(1e-9);                 % Initial spatial debris density [debris objects / km^3]
envParams.Asat               = 10;                          % Satellite cross-sectional area [m^2]
envParams.vRel               = 10000;                       % Debris relative collision velocity [m / sec]
envParams.numCollisionDebris = 1000;                        % Number of new debris objects created from collision
envParams.initalDebris = envParams.initialSPD*envParams.leoVol; % Initial number of debris objects in LEO

% Initialize Global SSA model
timeEnd  = simTime*365.2425;                            % Simulation end time [days]                                 
timeVec  = 0:timeStep:timeEnd;    % Simulation time steps [days]
gssa_model = GlobalSSAModel(timeVec,timeStep,envParams);

%Add GSSN object 
%inputs: nn, dq, cost
gssn = GSSNObject(0,  0, 100);

gssa_model = gssa_model.add_gssn(gssn);

% Add nation agents
members = {};
for iNation = 1:n_nations
    % determine nation-specific properties (some may be fixed for all 
    % nations, others may be set according to random distributions to make 
    % diverse nations)
    
    % create nation and add to GSSA model
    %inputs are:
    %id,sensors,sc,scs,smc,soc,dq,gm,fuzz, gdp
    % TODO: maybe we should move these random sample ranges to adjustable 
    % parameters section
%     sensors = randi([1 4]);
%     sensor_capability = randi([10 1000]);
%     sensor_const_speed = randi([1 5]);
%     sensor_mfg_cost = randi([40 60]);
%     sensor_ops_cost = randi([1 5]);
%     data_quality = 0;
%     gssn_member = randi([0 1]);
%     fuzz = 0;
%     starting_budget = randi(nationalBudgetsRange);
%     nsat = 10;
    
    sensors = 5;
    sensor_capability = 500;
    sensor_request_rate = 1*365.2425; % days
    sensor_const_speed = 3*365.2425/timeStep; % time steps % make variable per nation?
    sensor_mfg_cost = econParams.newSensorCost; % make variable per nation?
    sensor_ops_cost = econParams.sensorOpCost; % make fixed or variable per nation?
    sat_ops_cost = econParams.satOpCost;
    sat_revenue = econParams.satOpRev;
    sat_proc_cost = econParams.newSatCost;
    tech_cap = [1 0]; % [mean stddev]
    gssn_member = randi([0 1]);
    fuzz = 0;
    starting_budget = randi(nationalBudgetsRange);
    nsat = randi([50 160]); % TODO: make random
    sat_life = 8*365.2425; % days
    launch_rate = 70.5/365.2425*timeStep; % TODO: based on what? I.e., do we want to move away from random sampling?
    


    newNation = NationAgent(timeVec, timeStep, iNation, sensors,...
        sensor_capability, sensor_request_rate, sensor_const_speed,...
        sensor_mfg_cost, sensor_ops_cost, sat_ops_cost, sat_proc_cost, ...
        sat_revenue, tech_cap, gssn_member, fuzz, starting_budget, nsat, ...
        sat_life, launch_rate);



    gssa_model = gssa_model.add_nation(newNation); % supply inputs 

    if newNation.gssn_member == 1
        gssa_model = gssa_model.add_to_gssn(newNation);
    end
 
end



% Create Variables for plotting
total_members = [];

% Initialize storage arrays



% Start Simulation Steps
H = waitbar(0/timeVec(end),'Progress:');
for t = timeVec(2:end)
    
    % perform the next model step
    gssa_model = gssa_model.timestep(t,econParams);
    % update waitbar
    waitbar(t/timeVec(end),H)

%     figure(1)
%     plot(t, gssa_model.n_members,'ko')
%     hold on

end
waitbar(timeVec(end)/timeVec(end),H,'Simulation Complete!');

% figure(1)
% xlabel('Time Step')
% ylabel('Number of Nations in GSSN')

[finalCollisions, finalDebris] = GlobalSSN_AnalysisPlots(gssa_model,timeVec);
