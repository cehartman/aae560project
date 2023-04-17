classdef SSNAgent
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % AAE 560 - SoS Modeling and Analysis
    % DAI Project
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        info
    end
    
    methods
        %------------------------------------------------------------------
        % Define SSN Nation Agent
        %------------------------------------------------------------------
        function obj = SSNAgent(GBS,cap,sat,period)
            if nargin < 1; GBS = 10; end
            if nargin < 2; cap = 500; end
            if nargin < 3; sat = 160; end
            if nargin < 4; period = 8; end
            
            % Assign Agent Parameters            
            obj.info.initialGBS  = GBS;                  % Number of initial ground-based sensors
            obj.info.trackCap    = cap;                  % Sensor tracking capacity
            obj.info.initialSat  = sat;                  % Number of initial satellites
            obj.info.orbitPeriod = period;               % Orbit period after which satellite is retired [years]
            obj.info.currentGBS  = obj.info.initialGBS; % Current number of ground-based sensors
            obj.info.currentSat  = obj.info.initialSat; % Current number of satellites
        end
    end
end