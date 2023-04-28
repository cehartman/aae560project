function envParams = Global_SSN_ABM_LEOParams(timeStep)

envParams.leoSats            = 5000;                        % Total number of satellites in LEO
% envParams.leoLaunches        = 70.5/365.2425*timeStep;      % Total launch rate in LEO
envParams.leoVol             = 5.54e11*(1e9);               % LEO shell volume [km^3]
envParams.initialSPD         = 2e-8*(1e-9);                 % Initial spatial debris density [debris objects / km^3]
envParams.Asat               = 20;                          % Satellite cross-sectional area [m^2]
envParams.vRel               = 10000;                       % Debris relative collision velocity [m / sec]
envParams.numCollisionDebris = 1000;                        % Number of new debris objects created from collision
envParams.initalDebris = envParams.initialSPD*envParams.leoVol; % Initial number of debris objects in LEO