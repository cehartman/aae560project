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

% Initialize Global SSA model
gssa_model = GlobalSSAModel();

% Initialize Adjustable Parameters
sim_end_time = 100*365; % 100 years in days 
n_nations = 1;

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

% Start Simulation Steps
t = 0;
while t < sim_end_time
    % increment time
    t = t+8; % 8 day time steps
    % perform the next model step
    gssa_model = gssa_model.timestep(t);
end