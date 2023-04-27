classdef GlobalSSAModel
    
    properties
        leo_environment
        nations
        n_nations
        n_members
        n_nonmembers
        gssn 
        n_members_cum
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
            obj.gssn = gssn_agent;
        end

        function obj = add_to_gssn(obj, nation,id)

            obj.gssn = obj.gssn.add_nation(nation);
            obj.nations{1,id}.gssn_member = 1;
            obj.n_members = obj.n_members + 1;

        end

        function obj = remove_from_gssn(obj, nation,id)
            obj.gssn = obj.gssn.remove_nation(nation);
            obj.nations{1,id}.gssn_member = 0;
            obj.n_members = obj.n_members - 1;

        end
        
        function [obj, decision] = eval_nation(obj, nation)

            [obj.gssn, decision] = obj.gssn.evaluate(nation);

        end

            

        function obj = timestep(obj,t,econParams)
            global enable_environment_updates
            global environment_updates_only
            % commands the model to advance a time step

            if enable_environment_updates % TODO: remove

                %STEP 1: Update Environment
                [obj.leo_environment,obj.nations] = obj.leo_environment.update(t,obj.nations);
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


                %STEP 3: If a nation is in the GSSN, make sure it's DQ is
                %up to par still

                for i = 1:obj.n_nations

                    [obj, decision] = obj.eval_nation(obj.nations{1,i});
                    
                    %if a nation wants to be in the gssn but isn't
                    %currently, and the gssn will let them in, add them
                    if obj.nations{1,i}.want_gssn == 1 && ...
                            obj.nations{1,i}.gssn_member == 0 && ...
                            decision == 1
                        obj = obj.add_to_gssn(obj.nations{1,i}, i);

                    end
                    
                    %if a nation wants out, let them out
                    if obj.nations{1,i}.want_gssn == 0 &&...
                            obj.nations{1,i}.gssn_member == 1
                        obj = obj.remove_from_gssn(obj.nations{1,i}, i);
                    end
                    
                    %if a nation wants to be a member, is currently a
                    %member, but the GSSN rejects them, remove them
                    if obj.nations{1,i}.gssn_member == 1 && ...
                            obj.nations{1,i}.want_gssn == 1 &&...
                            decision == 0
                        obj = obj.remove_from_gssn(obj.nations{1,i}, i);
                    end

                    if obj.nations{1,i}.gssn_member == 1 && ...
                            obj.nations{1,i}.want_gssn == 0 &&...
                            decision == 0
                        obj = obj.remove_from_gssn(obj.nations{1,i}, i);
                    end
                end

                %update GSSN object
                obj.gssn.update();

                





            end

            
            
        end
    end
end