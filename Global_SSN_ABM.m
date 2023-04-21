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
clear; close all; clc; rng('default');

%TODO: remove this when we're ready
global enable_environment_updates;
global environment_updates_only;
enable_environment_updates = 1;
environment_updates_only = 1;

% Initialize Adjustable Parameters
n_nations = 1;

% Time
simTime = 100; % [years]
timeStep = 8; % [days]

% Environment
envParams.leoVol             = 5.54e11*(1e9);              % LEO shell volume [km^3]
envParams.initialSPD         = 2e-8*(1e-9);                 % Initial spatial debris density [debris objects / km^3]
envParams.Asat               = 40;                          % Satellite cross-sectional area [m^2]
envParams.vRel               = 10000;                       % Debris relative collision velocity [m / sec]
envParams.numCollisionDebris = 1000;                        % Number of new debris objects created from collision
envParams.initalDebris = envParams.initialSPD*envParams.leoVol; % Initial number of debris objects in LEO

% Initialize Global SSA model
timeEnd  = simTime*365.2425;                            % Simulation end time [days]                                 
timeVec  = 0:timeStep:timeEnd;    % Simulation time steps [days]
gssa_model = GlobalSSAModel(timeVec,timeStep,envParams);

%Add GSSN object 
%inputs: nn, no, dq, na, cost
gssn = GSSNObject(0, 0, 0, 0, 50);

gssa_model = gssa_model.add_gssn(gssn);

% Add nation agents
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
%     starting_budget = randi([50 80]);
%     nsat = 10;
    
    sensors = 10;
    sensor_capability = 500;
    sensor_const_speed = 0;
    sensor_mfg_cost = 0;
    sensor_ops_cost = 0;
    data_quality = 0;
    gssn_member = 0;
    fuzz = 0;
    starting_budget = 0;
    nsat = 160;

    newNation = NationAgent(iNation, sensors,...
        sensor_capability, sensor_const_speed,...
        sensor_mfg_cost, sensor_ops_cost, data_quality,...
        gssn_member, fuzz, starting_budget, nsat);

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
for t = timeVec(2:end-1)
    
    % perform the next model step
    gssa_model = gssa_model.timestep(t);
    % update waitbar
    waitbar(t/timeVec(end))

%     figure(1)
%     plot(t, gssa_model.n_members,'ko')
%     hold on

end
waitbar(timeVec(end)/timeVec(end));

% figure(1)
% xlabel('Time Step')
% ylabel('Number of Nations in GSSN')

cumulativeCollisions = cumsum(gssa_model.leo_environment.data.totalCollisions);
totalCollisions = cumulativeCollisions(end);
finalDebris = gssa_model.leo_environment.data.totalDebris(end);

