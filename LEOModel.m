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
            obj.timeStep  = timeStep;
            obj.timeVec   = timeVec;
            obj.params    = envParams;
            obj.numDebris = envParams.initalDebris;
            obj.SPD       = envParams.initialSPD;
            
            % initialize debris/collisions storage data
            obj.data.totalDebris     = zeros(size(timeVec));
            obj.data.totalDebris(1)  = obj.numDebris;
            obj.data.totalCollisions = zeros(size(timeVec));
            obj.data.leoSats         = zeros(size(timeVec));
            obj.data.leoSats(1)      = obj.params.leoSats;
        end
        
        function [obj,nations] = update(obj,t,nations,gssn)
            
            % determine storage array index from current sim time
            tIdx = t/obj.timeStep+1;
            
            % update spatial debris density using new debris population
            % from previous time step
            obj = obj.update_spd();
            
            % initial LEO satellite breakdown (modelled and non-modelled / independent)
            nationSats      = sum(cellfun(@(x) x.satellites, nations));
            leoSats         = max(obj.params.leoSats,nationSats);
            independentSats = leoSats - nationSats;
            
            % for each nation...
            newDebris = 0; % new debris created during this time step from collisions
            for iNat = 1:length(nations)
                
                % determine whether any of their satellites experience a 
                % collision with debris
                collisionOccurred = obj.DetermineCollision(nations{iNat},gssn);
                
                % update total collisions data storage
                newCollisions = sum(collisionOccurred);
                obj.data.totalCollisions(tIdx) = obj.data.totalCollisions(tIdx) + newCollisions;
                
                % add debris from this nation's satellite collisions
                newDebris = newDebris + obj.params.numCollisionDebris*newCollisions;
                
                % update number of satellites for current nation
                nations{iNat}.collision_occurred = newCollisions > 0;
                nations{iNat}.satellites = nations{iNat}.satellites - newCollisions;
                nations{iNat}.sat_retire(collisionOccurred) = [];
            end
            
            % determine collisions for non-modelled nations
            independentCollisionOccurred   = obj.DetermineCollision([],gssn,independentSats);
            newIndependentCollisions       = sum(independentCollisionOccurred);
            newDebris                      = newDebris + obj.params.numCollisionDebris*newIndependentCollisions;
            finalIndependentSats           = independentSats - newIndependentCollisions;
            obj.data.totalCollisions(tIdx) = obj.data.totalCollisions(tIdx) + newIndependentCollisions;
            
            % for independent collisions, randomly select nation to build new sensor
            gssnMemberNations   = cellfun(@(x) x.gssn_member, nations) == 1;
            currentAvailNations = cellfun(@(x) x.wait_con, nations) == 0;
            nonCollisionNations = ~cellfun(@(x) x.collision_occurred, nations);
            elligibleNations    = gssnMemberNations & currentAvailNations & nonCollisionNations;
            if newIndependentCollisions > 0 && any(elligibleNations)
                selectedNation      = randsample(find(elligibleNations),1);
                nations{selectedNation}.collision_occurred = true;
            end
            
            % update total debris
            obj.numDebris = obj.numDebris + newDebris;
            obj.data.totalDebris(tIdx) = obj.numDebris;
            
            % update total LEO satellites
            independentLaunchEvents = round(normrnd(obj.params.leoLaunchRate,0.5));
            finalNationSats        = sum(cellfun(@(x) x.satellites, nations));
%             obj.params.leoSats     = finalNationSats + finalIndependentSats + independentLaunchEvents;
            obj.data.leoSats(tIdx) = obj.params.leoSats;
        end
        
        function obj = update_spd(obj)
            obj.SPD = obj.numDebris / obj.params.leoVol;
        end

        function collisionOccurred = DetermineCollision(obj,nation,gssn,numSats)
            if nargin < 4
                numSats = nation.satellites;
            end
            % Compute Mean Number of Collisions
            c = obj.SPD*obj.params.Asat*obj.params.vRel*obj.timeStep*86400;
            numPossibleCollisions = poissrnd(c,numSats,1);
            
            % Non-modelled satellites have a chance of avoiding possible
            % collisions
            if isempty(nation)
                avoidanceDraw = rand(size(numPossibleCollisions));
                collisionOccurred = numPossibleCollisions > 0 & avoidanceDraw > 0.80;
            else
                % Determine probability of successfully tracking object that
                % would cause collision
                if nation.gssn_member % use GSSN tracking capacity
                    trackingSuccessProb = gssn.num_objects/obj.numDebris;
                else % use nation's tracking capacity
                    trackingSuccessProb = nation.tracking_capacity/obj.numDebris;
                end

                % if the random draw is above the tracking success probability,
                % or if the random draw is below the tracking success
                % probability but the 99% avoidance chance is failed, the
                % possible collision does occur
                trackSuccessDraw = rand(size(numPossibleCollisions));
                avoidanceDraw = rand(size(numPossibleCollisions));
                collisionOccurred = numPossibleCollisions > 0 & ((trackSuccessDraw > trackingSuccessProb) ...
                    | (trackSuccessDraw <= trackingSuccessProb & avoidanceDraw > 0.99));
            end
        end
        
        
    end
    
end