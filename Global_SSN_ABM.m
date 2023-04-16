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

% Add nation agents

% Initialize storage arrays

% Start Simulation Steps
t = 0;
while t < sim_end_time
    % increment time
    t = t+8; % 8 day time steps
    % perform the next model step
    gssa_model = gssa_model.step(t);
end