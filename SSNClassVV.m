classdef SSNClassVV < SSNClass
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % AAE 560 - SoS Modeling and Analysis
    % DAI Project
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    properties
    end
    
    methods
        %------------------------------------------------------------------
        % Run Simulation
        %------------------------------------------------------------------
        function obj = Run(obj,timeEnd,timeStep)
            % Initialize Parameters / Data Structures
            obj = obj.InitializeParams(timeEnd,timeStep);
            obj = obj.AddNation(0,0,0,100); % Retire time set to 100 years (i.e., never retire)
            obj = obj.InitializeData;
            % Add annual launch rate to more closely match DELTA 2.0
            launchEvents = floor(normrnd(70.5/365.2425*obj.params.timeStep,0.5,size(obj.params.timeVec)));
            launchEvents(launchEvents < 0) = 0;
            retireIdxShift = find(obj.params.timeVec <= obj.nationAgent.info.orbitPeriod*365.2425,1,'last');
            retireEvents = circshift(launchEvents,retireIdxShift);
            retireEvents(1:retireIdxShift) = 0;
            % Loop Through Time Steps
            for tt = 2:length(obj.params.timeVec)-1
                % Status Display
                disp(['Processing Year ' num2str(years(days(obj.params.timeVec(tt)))) '...']);
                
                % Update Current Satellites
                obj.data.totalDebris(tt) = obj.data.totalDebris(tt);
                obj.nationAgent.info.currentSat = obj.data.totalSat(tt) + launchEvents(tt) - retireEvents(tt);
                % Update Environment
                obj = obj.updateEnvironment(obj.data.totalDebris(tt));
                % Compute Probability of Collision for Each Satellite
                collisionOccurred = obj.DetermineCollision;
                % Loop Through Satellites
                tempDebris = 0;
                numLostSat = 0;
                for ss = 1:obj.nationAgent.info.currentSat
                    if collisionOccurred(ss)
                        obj.data.totalCollisions(tt) = obj.data.totalCollisions(tt) + 1;
                        tempDebris = tempDebris + obj.params.numCollisionDebris;
                        numLostSat = numLostSat + 1;
                    end
                end
                % Update Number of Satellites and Debris
                obj.nationAgent.info.currentSat = obj.nationAgent.info.currentSat - numLostSat;
                obj.data.totalSat(tt+1)         = obj.nationAgent.info.currentSat;
                obj.data.totalDebris(tt+1)      = obj.data.totalDebris(tt) + tempDebris;
            end
        end
        
        %------------------------------------------------------------------
        % Initialize Parameters
        %------------------------------------------------------------------
        function obj = InitializeParams(obj,timeEnd,timeStep)
            obj = InitializeParams@SSNClass(obj,timeEnd,timeStep);
            % Collision Inputs
            % Modified to more closely match DELTA 2.0
            obj.params.Asat = 10; % Satellite cross-sectional area [m^2]
        end
    end
end