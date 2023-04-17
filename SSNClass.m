classdef SSNClass
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % AAE 560 - SoS Modeling and Analysis
    % DAI Project
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    properties
        params
%         agent
        data
        env
        nationAgent
        numNationAgents = 0;
    end
    
    methods
        %------------------------------------------------------------------
        % Run Simulation
        %------------------------------------------------------------------
        function obj = Run(obj,timeEnd,timeStep)
            % Initialize Parameters / Data Structures
            obj = obj.InitializeParams(timeEnd,timeStep);
            obj = obj.AddNation(10,500,160,8);
            obj = obj.InitializeData;
            
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
%                     % Generate Random Probability of Collision
%                     r = rand;
%                     % If Collision Occurs
%                     if r < obj.env.Ppc
                    if collisionOccurred(ss)
                        obj.data.totalCollisions(tt) = obj.data.totalCollisions(tt) + 1;
                        tempDebris = tempDebris + obj.params.numCollisionDebris;
                        numLostSat = numLostSat + 1;
                    end
                end
                % Update Number of Satellites and Debris
                obj.nationAgent.info.currentSat  = obj.nationAgent.info.currentSat - numLostSat;
                obj.data.totalSat(tt+1)          = obj.nationAgent.info.currentSat;
                obj.data.totalDebris(tt+1)       = obj.data.totalDebris(tt) + tempDebris;
            end
        end
        
        %------------------------------------------------------------------
        % Initialize Parameters
        %------------------------------------------------------------------
        function obj = InitializeParams(obj,timeEnd,timeStep)
            if nargin < 1; timeEnd = 100; end
            if nargin < 2; timeStep = 8; end
            
            % Collision Inputs
            obj.params.leoVol             = 5.54e11*(1e9);              % LEO shell volume [km^3]
            obj.params.initialSPD         = 2e-8*(1e-9);                 % Initial spatial debris density [debris objects / km^3]
            obj.params.Asat               = 40;                          % Satellite cross-sectional area [m^2]
            obj.params.vRel               = 10000;                       % Debris relative collision velocity [m / sec]
            obj.params.numCollisionDebris = 1000;                        % Number of new debris objects created from collision
            % Debris
            obj.params.initalDebris = obj.params.initialSPD*obj.params.leoVol; % Initial number of debris objects in LEO
            % Simulation Time
            obj.params.timeEnd  = timeEnd*365.2425;                            % Simulation end time [days]
            obj.params.timeStep = timeStep;                                    % Simulation propagation time step [days]
            obj.params.timeVec  = 0:obj.params.timeStep:obj.params.timeEnd;    % Simulation time steps [days]
        end
        
        %------------------------------------------------------------------
        % Add Nation Agent
        %------------------------------------------------------------------
        function obj = AddNation(obj,GBS,cap,sat,period)
            obj.nationAgent     = SSNAgent(GBS,cap,sat,period);
            obj.numNationAgents = obj.numNationAgents + 1;
        end
        
        %------------------------------------------------------------------
        % Initialize Data
        %------------------------------------------------------------------
        function obj = InitializeData(obj)
            obj.data.totalDebris     = ones(size(obj.params.timeVec))*obj.params.initalDebris;
            obj.data.totalCollisions = zeros(size(obj.params.timeVec));
            obj.data.totalSat        = ones(size(obj.params.timeVec))*obj.nationAgent.info.initialSat;
        end
        
        %------------------------------------------------------------------
        % Update LEO Environment
        %------------------------------------------------------------------
        function obj = updateEnvironment(obj,numDebris)
            obj.env.numDebris = numDebris;
            obj.env.SPD = obj.env.numDebris / obj.params.leoVol;
        end
        
        %------------------------------------------------------------------
        % Compute Probability of Collision
        %------------------------------------------------------------------
% %         function obj = ComputeCollisionProb(obj)
%         function collisionOccurred = DetermineCollision(obj)
%             % Compute Mean Number of Collisions
%             c = obj.env.SPD*obj.params.Asat*obj.params.vRel*obj.params.timeStep*86400;
% %             % Compute Probability of 1 or More Collisions
% %             obj.env.Ppc = 1 - exp(-c);
%             
% %             epsilon = 1e-20;
% %             j = 0:obj.env.numDebris;
% %             Pj = poisspdf(j,c);
% %             kIdx = find(Pj<=epsilon,1,'first')-1;
% %             Pj_hat = Pj ./ sum(Pj(1:kIdx));
% %             r = rand;
% %             nPossibleCollisions = find(cumsum(Pj_hat)>r,1,'first')-1;
%             nPossibleCollisions = poissrnd(c);
%             if nPossibleCollisions > obj.nationAgent.info.currentGBS * obj.nationAgent.info.trackCap
%                 collisionOccurred = true;
%             else
%                 collisionOccurred = false;
%             end
%         end
        function collisionOccurred = DetermineCollision(obj)
            % Compute Mean Number of Collisions
            c = obj.env.SPD*obj.params.Asat*obj.params.vRel*obj.params.timeStep*86400;
            numPossibleCollisions = poissrnd(c,obj.nationAgent.info.currentSat,1);
            collisionOccurred = numPossibleCollisions > obj.nationAgent.info.currentGBS * obj.nationAgent.info.trackCap;
        end
        
        %------------------------------------------------------------------
        % Compute Probability of Collision
        %------------------------------------------------------------------
        function obj = AnalysisPlots(obj)
            % Total Debris vs Time
            figure('Color','w'); hold on; box on; grid on;
            plot(obj.params.timeVec/365.2425,obj.data.totalDebris);
            ax = gca; ax.YAxis.Exponent = 0;
            xlabel('Years','FontWeight','Bold');
            ylabel('Total Debris','FontWeight','Bold');
            % Total Satellites vs Time
            figure('Color','w'); hold on; box on; grid on;
            plot(obj.params.timeVec/365.2425,obj.data.totalSat);
            xlabel('Years','FontWeight','Bold');
            ylabel('Total Satellites','FontWeight','Bold');
            % Total Collisions vs Time
            figure('Color','w'); hold on; box on; grid on;
            plot(obj.params.timeVec/365.2425,cumsum(obj.data.totalCollisions));
            xlabel('Years','FontWeight','Bold');
            ylabel('Total Collisions','FontWeight','Bold');
        end
    end
end