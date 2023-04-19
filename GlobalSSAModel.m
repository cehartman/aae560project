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
        function obj = GlobalSSAModel() % TODO: inputs to initialize debris model
            % initialize model
            obj.nations = {};
            obj.n_nations = 0;
            obj.n_members = 0;
            obj.n_nonmembers = 0;
            
            % initialize GSSN object
            %obj.gssn = GSSNObject();
            
            % initialize LEO satellite/debris model
            %obj.leo_environment = LEOModel(); %TODO: hook in Joe's debris model
            
        end
        
        
        function obj = add_nation(obj, nation_agent)
            % Adds a nation agent object
            obj.nations{end+1} = nation_agent;
            obj.n_nations = obj.n_nations + 1;
            
        end
    
        function obj = add_gssn(obj,gssn_agent)
            obj.gssn = gssn_agent;
        end



        function obj = timestep(obj,t)
            % commands the model to advance a time step

            %STEP 1: Update Environment
            total_objects = 1000;
            %STEP 2: Update Nation Preferences
            
            for i = 1:obj.n_nations
                obj = obj.nations{i}.update(total_objects,...
                    obj.gssn.num_objects, obj.gssn.fee);
            end

            %STEP 3: Update GSSN Properties

            temp = {};
            ct = 0;
            for i = 1:obj.n_nations

                if obj.nations{i}.gssn_member == 1
                    ct = ct + 1;
                    temp{ct} = members;
                end
            end

            obj = obj.gssn.update(temp);

            clear temp

            %nation preferences have been updated, and GSSN have been
            %updated


            %STEP 3: GSSN In or OUT
            
            % execute environment object, nation agents, and GSSN object updates
            
        end
    end
end