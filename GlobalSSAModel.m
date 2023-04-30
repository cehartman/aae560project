classdef GlobalSSAModel
    
    properties
        leo_environment
        nations
        n_nations
        n_members
        n_nonmembers
        gssn 
    end
    
    methods
        function obj = GlobalSSAModel(timeVec,timeStep,envParams)
            % initialize model
            obj.nations = {};
            obj.n_nations = 0;
            obj.n_members = 0;
            obj.n_nonmembers = 0;
            
            % initialize LEO satellite/debris model
            obj.leo_environment = LEOModel(timeVec,timeStep,envParams);
        end
        
        function obj = add_nation(obj, nation_agent)
            % Adds a nation agent object
            obj.nations{end+1} = nation_agent;
            obj.n_nations = obj.n_nations + 1;
            
        end
    
        function obj = add_gssn(obj,gssn_agent)
            % adds the GSSN object to the global model object
            obj.gssn = gssn_agent;
        end

        function obj = add_to_gssn(obj, nation,id)
            % adds a nation to the GSSN
            obj.gssn = obj.gssn.add_nation(nation);
            obj.nations{1,id}.gssn_member = true;
            obj.nations{1,id}.gssn_member_status = 'good-standing';
            obj.n_members = obj.n_members + 1;

        end

        function obj = remove_from_gssn(obj, nation,id)
            % removes a nation from the GSSN
            obj.gssn = obj.gssn.remove_nation(nation);
            obj.nations{1,id}.gssn_member = false;
            obj.nations{1,id}.gssn_member_status = 'non-member';
            obj.n_members = obj.n_members - 1;

        end
        
        function [obj, decision] = eval_nation(obj, nation)
            % triggers the GSSN to evaluate a nation's eligibility 
            [obj.gssn, decision] = obj.gssn.evaluate(nation);
        end
        
        % commands the model to advance a time step
        function obj = timestep(obj,t,econParams)
            global enable_environment_updates
            global environment_updates_only
            
            %STEP 1: Update Environment
            if enable_environment_updates % TODO: remove
                [obj.leo_environment,obj.nations] = obj.leo_environment.update(t,obj.nations,obj.gssn);
                total_objects = obj.leo_environment.numDebris;
            else
                total_objects = 8000;
            end
            
            if ~environment_updates_only % TODO: remove
                %STEP 2: Update Nation Preferences
                for i = 1:obj.n_nations
                    obj.nations{i} = obj.nations{i}.update(t, total_objects,...
                        obj.gssn.num_objects, obj.gssn.fee, econParams);
                end
                
                %STEP 3: Evaluate GSSN membership statuses
                for i = 1:obj.n_nations
                    
                    [obj, decision] = obj.eval_nation(obj.nations{1,i});
                    
                    if obj.nations{1,i}.want_gssn && ...
                            ~obj.nations{1,i}.gssn_member && ...
                            decision == 1
                        % if a nation wants to be in the gssn but isn't
                        % currently, and the gssn will let them in, add them
                        if obj.nations{1,i}.gssn_entry_wait >= obj.gssn.entry_wait
                            obj = obj.add_to_gssn(obj.nations{1,i}, i);
                            obj.nations{1,i} = obj.nations{1,i}.reset_gssn_waits();
                        else
                            obj.nations{1,i}.gssn_entry_wait = obj.nations{1,i}.gssn_entry_wait + 1;
                            obj.nations{1,i}.gssn_member_status = 'joining';
                        end                       
                        
                    elseif ~obj.nations{1,i}.want_gssn &&...
                            obj.nations{1,i}.gssn_member
                        % if a nation wants out, let them out
                        if obj.nations{1,i}.gssn_leave_wait >= obj.gssn.leave_wait
                            obj = obj.remove_from_gssn(obj.nations{1,i}, i);
                            obj.nations{1,i} = obj.nations{1,i}.reset_gssn_waits();
                        else
                            obj.nations{1,i}.gssn_leave_wait = obj.nations{1,i}.gssn_leave_wait + 1;
                            obj.nations{1,i}.gssn_kick_wait = obj.nations{1,i}.gssn_kick_wait + 1; % TODO: might be a better way to deal with this
                            obj.nations{1,i}.gssn_member_status = 'leaving';
                        end
                        
                    elseif obj.nations{1,i}.gssn_member && ...
                            obj.nations{1,i}.want_gssn &&...
                            decision == 0
                        % if a nation wants to be a member, is currently a
                        % member, but the GSSN rejects them, remove them
                        if obj.nations{1,i}.gssn_kick_wait >= obj.gssn.kick_wait
                            obj = obj.remove_from_gssn(obj.nations{1,i}, i);
                            obj.nations{1,i} = obj.nations{1,i}.reset_gssn_waits();
                        else
                            obj.nations{1,i}.gssn_kick_wait = obj.nations{1,i}.gssn_kick_wait + 1;
                            obj.nations{1,i}.gssn_member_status = 'bad-standing';
                        end
                        
                    elseif obj.nations{1,i}.gssn_member && ...
                            obj.nations{1,i}.want_gssn &&...
                            decision == 1
                        % if nation is a member, wants to be, and the GSSN
                        % permits them, the nation remains in good standing
                        obj.nations{1,i}.gssn_member_status = 'good-standing';
                        obj.nations{1,i} = obj.nations{1,i}.reset_gssn_waits();          

                    elseif ~obj.nations{1,i}.gssn_member && ...
                            obj.nations{1,i}.want_gssn &&...
                            decision == 0
                        % if the nation is not a member, wants to join, but
                        % the GSSN will not admit them, take no action
                        
                    elseif ~obj.nations{1,i}.gssn_member && ...
                            ~obj.nations{1,i}.want_gssn 
                        % if the nation is not a member and does not want
                        % join, take no action
                    else
                        error('Unexpected GSSN membership condition!');
                    end
                end

                % update GSSN object
                obj.gssn = obj.gssn.update(obj.nations,t);
            end
        end
    end
end