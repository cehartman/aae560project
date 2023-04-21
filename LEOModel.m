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
            
            % initialize debris/collisions storage arrays
            obj.data.totalDebris = ones(size(timeVec))*obj.params.initalDebris;
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
            obj.data.totalDebris(tIdx+1) = obj.data.totalDebris(tIdx) + newDebris;
            obj.numDebris = obj.numDebris + newDebris;

            
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
            % the possible collision does occur
            collisionOccurred = numPossibleCollisions & rand(size(numPossibleCollisions)) > trackingSuccessProb;
            
        end
        
        
    end
    
end