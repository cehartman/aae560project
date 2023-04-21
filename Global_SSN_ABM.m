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

% Initialize Adjustable Parameters
sim_end_time = 100*365; % 100 years in days 
n_nations = 100;

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
    sensors = randi([1 4]);
    sensor_capability = randi([10 1000]);
    sensor_const_speed = randi([1 5]);
    sensor_mfg_cost = randi([40 60]);
    sensor_ops_cost = randi([1 5]);
    data_quality = 0;
    gssn_member = randi([0 1]);
    fuzz = 0;
    starting_budget = randi([50 80]);

    nation = NationAgent(iNation, sensors,...
        sensor_capability, sensor_const_speed,...
        sensor_mfg_cost, sensor_ops_cost, data_quality,...
        gssn_member, fuzz, starting_budget);

    gssa_model = gssa_model.add_nation(nation); % supply inputs 

    if nation.gssn_member == 1
        gssa_model = gssa_model.add_to_gssn(nation);
    end
 
end

%Create Variables for plotting
total_members = [];

% Initialize storage arrays
numCollisions = zeros(1,ceil(simTime*365.2425/timeStep));
numDebris = zeros(1,ceil(simTime*365.2425/timeStep));


% Start Simulation Steps
for t = timeVec
    
    % perform the next model step
    gssa_model = gssa_model.timestep(t);

    % increment time
    figure(1)
    plot(t, gssa_model.n_members,'ko')
    hold on

end

figure(1)
xlabel('Time Step')
ylabel('Number of Nations in GSSN')