function nationParams = Global_SSN_ABM_NationParams_Static(econParams,timeStep,nationId)

baseSensorCapability = 500; % could either leave this fixed or vary it

% Parameters that are the same for every nation
nationParams.sensor_request_rate = 1*365.2425; % days
nationParams.sensor_const_speed = 3*365.2425/timeStep; % time steps
nationParams.sensor_mfg_cost = econParams.newSensorCost;
nationParams.sensor_ops_cost = econParams.sensorOpCost;
nationParams.sat_ops_cost = econParams.satOpCost;
nationParams.sat_revenue = econParams.satOpRev;
nationParams.sat_proc_cost = econParams.newSatCost;
nationParams.sensor_capability = baseSensorCapability;
nationParams.sat_life = 8*365.2425; % years->days
nationParams.launchRateIncrease = 0.05; % launch rate increase per year

switch nationId
    case 1
        nationParams.sensors = 10;
        nationParams.tech_cap = [0.8000 0.2000]; % [mean stddev]
        nationParams.gssn_member = false;
        nationParams.fuzz = 1.0; % 1.0 = no fuzz, 0.0 = full fuzz
        nationParams.starting_budget = 4534;
        nationParams.nsat = 160;
        nationParams.launch_rate = 10/365.2425*timeStep;
        
    case 2
        nationParams.sensors = 10;
        nationParams.tech_cap = [0.9000 0.2000]; % [mean stddev]
        nationParams.gssn_member = true;
        nationParams.fuzz = 1.0; % 1.0 = no fuzz, 0.0 = full fuzz
        nationParams.starting_budget = 4769;
        nationParams.nsat = 160;
        nationParams.launch_rate = 10/365.2425*timeStep;
        
    case 3
        nationParams.sensors = 10;
        nationParams.tech_cap = [0.8000 0.2000]; % [mean stddev]
        nationParams.gssn_member = true;
        nationParams.fuzz = 1.0; % 1.0 = no fuzz, 0.0 = full fuzz
        nationParams.starting_budget = 4643;
        nationParams.nsat = 160;
        nationParams.launch_rate = 10/365.2425*timeStep;
        
    case 4
        nationParams.sensors = 10;
        nationParams.tech_cap = [1.0000 0.2000]; % [mean stddev]
        nationParams.gssn_member = false;
        nationParams.fuzz = 1.0; % 1.0 = no fuzz, 0.0 = full fuzz
        nationParams.starting_budget = 1779;
        nationParams.nsat = 160;
        nationParams.launch_rate = 10/365.2425*timeStep;
        
    case 5
        nationParams.sensors = 10;
        nationParams.tech_cap = [0.8000 0.2000]; % [mean stddev]
        nationParams.gssn_member = false;
        nationParams.fuzz = 1.0; % 1.0 = no fuzz, 0.0 = full fuzz
        nationParams.starting_budget = 1377;
        nationParams.nsat = 160;
        nationParams.launch_rate = 10/365.2425*timeStep;
    case 6
        nationParams.sensors = 10;
        nationParams.tech_cap = [0.6000 0.2000]; % [mean stddev]
        nationParams.gssn_member = true;
        nationParams.fuzz = 1.0; % 1.0 = no fuzz, 0.0 = full fuzz
        nationParams.starting_budget = 4677;
        nationParams.nsat = 160;
        nationParams.launch_rate = 10/365.2425*timeStep;
    case 7
        nationParams.sensors = 10;
        nationParams.tech_cap = [0.7000 0.2000]; % [mean stddev]
        nationParams.gssn_member = true;
        nationParams.fuzz = 1.0; % 1.0 = no fuzz, 0.0 = full fuzz
        nationParams.starting_budget = 3648;
        nationParams.nsat = 160;
        nationParams.launch_rate = 10/365.2425*timeStep;
    case 8
         nationParams.sensors = 10;
        nationParams.tech_cap = [0.8000 0.2000]; % [mean stddev]
        nationParams.gssn_member = true;
        nationParams.fuzz = 1.0; % 1.0 = no fuzz, 0.0 = full fuzz
        nationParams.starting_budget = 4578;
        nationParams.nsat = 160;
        nationParams.launch_rate = 10/365.2425*timeStep;
    case 9
        nationParams.sensors = 10;
        nationParams.tech_cap = [1.0000 0.2000]; % [mean stddev]
        nationParams.gssn_member = false;
        nationParams.fuzz = 1.0; % 1.0 = no fuzz, 0.0 = full fuzz
        nationParams.starting_budget = 2413;
        nationParams.nsat = 160;
        nationParams.launch_rate = 10/365.2425*timeStep;
    case 10
        nationParams.sensors = 10;
        nationParams.tech_cap = [0.9000 0.2000]; % [mean stddev]
        nationParams.gssn_member = true;
        nationParams.fuzz = 1.0; % 1.0 = no fuzz, 0.0 = full fuzz
        nationParams.starting_budget = 2945;
        nationParams.nsat = 160;
        nationParams.launch_rate = 10/365.2425*timeStep;
end
