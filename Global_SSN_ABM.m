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

% Add nation agents
for iNation = 1:n_nations
    % determine nation-specific properties (some may be fixed for all 
    % nations, others may be set according to random distributions to make 
    % diverse nations)
    
    % create nation and add to GSSA model
    %inputs are:
    %id,sensors,sc,scs,smc,soc,dq,gm,fuzz, gdp
    nation = NationAgent(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);

    gssa_model = gssa_model.add_nation(nation); % supply inputs 
    
end

%Add GSSN object 
%inputs: nn, no, dq, na, cost
gssn = GSSNObject(0, 0, 0, 0, 0);

gssa_model = gssa_model.add_gssn(gssn);


% Initialize storage arrays
numCollisions = zeros(1,ceil(simTime*365.2425/timeStep));
numDebris = zeros(1,ceil(simTime*365.2425/timeStep));


% Start Simulation Steps
for t = timeVec

    % perform the next model step
    gssa_model = gssa_model.timestep(t);
end