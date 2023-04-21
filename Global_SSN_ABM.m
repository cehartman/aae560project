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
n_nations = 2;

%Add GSSN object 
%inputs: nn, no, dq, na, cost
gssn = GSSNObject(0, 1000, 0, 0, 0);

gssa_model = gssa_model.add_gssn(gssn);

% Add nation agents
for iNation = 1:n_nations
    % determine nation-specific properties (some may be fixed for all 
    % nations, others may be set according to random distributions to make 
    % diverse nations)
    
    % create nation and add to GSSA model
    %inputs are:
    %id,sensors,sc,scs,smc,soc,dq,gm,fuzz, gdp
    sensors = randi([1 10]);
    sensor_capability = randi([10 500]);
    sensor_const_speed = randi([1 5]);
    sensor_mfg_cost = randi([1 10]);
    sensor_ops_cost = randi([1 5]);
    data_quality = 0;
    gssn_member = randi([0 1]);
    fuzz = 0;
    starting_budget = randi([10 50]);

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



% Start Simulation Steps
t = 0;
step = 0;
while t < sim_end_time
    step = step + 1;
    % increment time

    t = t+8; % 8 day time steps

    % perform the next model step
    gssa_model = gssa_model.timestep(t);
    
end