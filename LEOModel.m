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
            obj.timeStep = timeStep;
            obj.timeVec = timeVec;
            
            obj.params = envParams;
            
            obj.data.totalDebris = ones(size(timeVec))*obj.params.initalDebris;
            obj.data.totalCollisions = zeros(size(timeVec));
%             obj.data.totalSat        = ones(size(timeVec))*obj.nationAgent.info.initialSat;
            
        end
        
        function obj = update(obj,tt,numDebris,nations)
            
            obj = obj.update_debris(numDebris);
            
            collisionOccurred = obj.DetermineCollision();
            
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
        
        function obj = update_debris(obj,numDebris)
            obj.numDebris = numDebris;
            obj.SPD = obj.numDebris / obj.params.leoVol;
        end
        
        function collisionOccurred = DetermineCollision(obj)
            % Compute Mean Number of Collisions
            c = obj.SPD*obj.params.Asat*obj.params.vRel*obj.params.timeStep*86400;
            numPossibleCollisions = poissrnd(c,obj.nationAgent.info.currentSat,1);
            collisionOccurred = numPossibleCollisions > obj.nationAgent.info.currentGBS * obj.nationAgent.info.trackCap;% ...
                %| rand(1,obj.nationAgent.info.currentSat) > 0.99.^numPossibleCollisions;
        end
        
        
    end
    
end