% function nationParams = Global_SSN_ABM_NationParams()

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
starting_budget = randi(econParams.nationalBudgetsRange);
nsat = randi(initialSatsRange);
sat_life = 8*365.2425; % days
launch_rate = normrnd(launchRateStats(1),launchRateStats(2))/365.2425*timeStep;