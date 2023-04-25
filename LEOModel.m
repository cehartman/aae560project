classdef LEOModel
    
    properties
        timeVec
        timeStep
        params
        numDebris
        SPD
        data
    end
    
    methods
        
        function obj = LEOModel(timeVec,timeStep,envParams)
            % initialize LEO model with time and environment parameters
            obj.timeStep = timeStep;
            obj.timeVec = timeVec;
            obj.params = envParams;
            obj.numDebris = envParams.initalDebris;
            obj.SPD = envParams.initialSPD;
            
            % initialize debris/collisions storage data
            obj.data.totalDebris = zeros(size(timeVec));
            obj.data.totalDebris(1) = obj.numDebris;
            obj.data.totalCollisions = zeros(size(timeVec));
        end
        
        function [obj,nations] = update(obj,t,nations)
            
            % determine storage array index from current sim time
            tIdx = t/obj.timeStep+1;
            
            % update spatial debris density using new debris population
            % from previous time step
            obj = obj.update_spd();
            
            % for each nation...
            newDebris = 0; % new debris created during this time step from collisions
            for iNat = 1:length(nations)
                
                % determine whether any of their satellites experience a 
                % collision with debris
                collisionOccurred = obj.DetermineCollision(nations{iNat});
                
                % Loop through satellites for current nation
                numLostSat = 0;
                for ss = 1:nations{iNat}.satellites
                    if collisionOccurred(ss)
                        obj.data.totalCollisions(tIdx) = obj.data.totalCollisions(tIdx) + 1;
                        newDebris = newDebris + obj.params.numCollisionDebris;
                        numLostSat = numLostSat + 1;
                    end
                end
                % Update number of satellites for current nation
                nations{iNat}.satellites = nations{iNat}.satellites - numLostSat;
                
            end
            
            % update total debris
            obj.numDebris = obj.numDebris + newDebris;
            obj.data.totalDebris(tIdx) = obj.numDebris;
            
        end
        
        function obj = update_spd(obj)
            obj.SPD = obj.numDebris / obj.params.leoVol;
        end

        function collisionOccurred = DetermineCollision(obj,nation)
            % Compute Mean Number of Collisions
            c = obj.SPD*obj.params.Asat*obj.params.vRel*obj.timeStep*86400;
            numPossibleCollisions = poissrnd(c,nation.satellites,1);
            
            % Determine probability of successfully tracking object that
            % would cause collision
            trackingSuccessProb = nation.tracking_capacity/obj.numDebris; % TODO: determine whether we should model sat-sat collisions
            
            % if the random draw is above the tracking success probability,
            % or if the random draw is below the tracking success
            % probability but the 99% avoidance chance is failed, the
            % possible collision does occur
            trackSuccessDraw = rand(size(numPossibleCollisions));
            avoidanceDraw = rand(size(numPossibleCollisions));
            collisionOccurred = numPossibleCollisions > 0 & ((trackSuccessDraw >= trackingSuccessProb) ...
                | (trackSuccessDraw < trackingSuccessProb & avoidanceDraw > 0.99));
 
        end
        
        
    end
    
end