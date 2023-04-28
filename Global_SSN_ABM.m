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
n_nations = 5;
baseSensorCapability = 500;
initialSensorsRange = [1 10];
sensorReqRateStats = [1 0]; % years
sensorConSpeedStats = [3 0]; % years
dataQualityStats = [0.95 0.05];
launchRateStats = [70.5 0.0]; % mean launch rate (sat/year)
initialSatsRange = [50 160]; 
initialGssnMemberChance = 0.5;
minGssnDQ = 0.8;
gssnFee = 2000; % million $ / year


% Economics
econParams.newSatCost = 171;    % million $ from OP
econParams.satOpCost = 1;       % million $ / year from OP
econParams.satOpRev = 279000/8261; % million $ / year per sat
econParams.newSensorCost = 1600; % million $ from Space Fence
econParams.sensorOpCost = 6;    % million $ / year from $33m/5yrs5mo for SF
econParams.inflation = 1.0; % negate inflation; not relevant to RQs
nationalBudgetsRange = [500 5000]; % million $

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
    sensors = randi(initialSensorsRange);
    sensor_capability = baseSensorCapability;
    sensor_request_rate = normrnd(sensorReqRateStats(1),sensorReqRateStats(2))*365.2425; % days
    sensor_const_speed = normrnd(sensorConSpeedStats(1),sensorConSpeedStats(2))*365.2425/timeStep; % time steps
    sensor_mfg_cost = econParams.newSensorCost;
    sensor_ops_cost = econParams.sensorOpCost;
    sat_ops_cost = econParams.satOpCost;
    sat_revenue = econParams.satOpRev;
    sat_proc_cost = econParams.newSatCost;
    tech_cap = dataQualityStats; % [mean stddev]
    gssn_member = rand(1) <= initialGssnMemberChance;
    fuzz = 0;
    starting_budget = randi(nationalBudgetsRange);
    nsat = randi(initialSatsRange);
    sat_life = 8*365.2425; % days
    launch_rate = normrnd(launchRateStats(1),launchRateStats(2))/365.2425*timeStep;
    
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
