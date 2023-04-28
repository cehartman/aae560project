function [nationParams, econParams] = Global_SSN_ABM_NationParams(timeStep,econParams)

econParams.newSatCost = 171;    % million $ from OP
econParams.satOpCost = 1;       % million $ / year from OP
econParams.satOpRev = 279000/8261; % million $ / year per sat
econParams.newSensorCost = 1600; % million $ from Space Fence
econParams.sensorOpCost = 6;    % million $ / year from $33m/5yrs for SF
econParams.inflation = 1.0; % negate inflation; not relevant to RQs
econParams.nationalBudgetsRange = [500 5000]; % million $


initialSensorsRange = [10 10];
baseSensorCapability = 500;
sensorReqRateStats = [1 0]; % years
sensorConSpeedStats = [3 0]; % years
dataQualityStats = [1 0];
initialSatsRange = [160 160]; 
initialGssnMemberChance = 0.4;
launchRateStats = [5.5 0.0]; % mean launch rate (sat/year)

nationParams.sensors = randi(initialSensorsRange);
nationParams.sensor_capability = baseSensorCapability;
nationParams.sensor_request_rate = normrnd(sensorReqRateStats(1),sensorReqRateStats(2))*365.2425; % days
nationParams.sensor_const_speed = normrnd(sensorConSpeedStats(1),sensorConSpeedStats(2))*365.2425/timeStep; % time steps
nationParams.sensor_mfg_cost = econParams.newSensorCost;
nationParams.sensor_ops_cost = econParams.sensorOpCost;
nationParams.sat_ops_cost = econParams.satOpCost;
nationParams.sat_revenue = econParams.satOpRev;
nationParams.sat_proc_cost = econParams.newSatCost;
nationParams.tech_cap = dataQualityStats; % [mean stddev]
nationParams.gssn_member = rand(1) <= initialGssnMemberChance;
nationParams.fuzz = 0;
nationParams.starting_budget = randi(econParams.nationalBudgetsRange);
nationParams.nsat = randi(initialSatsRange);
nationParams.sat_life = 8*365.2425; % days
nationParams.launch_rate = normrnd(launchRateStats(1),launchRateStats(2))/365.2425*timeStep;
