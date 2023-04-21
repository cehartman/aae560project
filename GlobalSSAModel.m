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
        function obj = GlobalSSAModel(timeVec,timeStep,envParams) % TODO: inputs to initialize debris model
            % initialize model
            obj.nations = {};
            obj.n_nations = 0;
            obj.n_members = 0;
            obj.n_nonmembers = 0;
            
            % initialize GSSN object
            %obj.gssn = GSSNObject();
            
            % initialize LEO satellite/debris model
            obj.leo_environment = LEOModel(timeVec,timeStep,envParams); %TODO: hook in Joe's debris model
            
        end
        
        
        function obj = add_nation(obj, nation_agent)
            % Adds a nation agent object
            obj.nations{end+1} = nation_agent;
            obj.n_nations = obj.n_nations + 1;
            
        end
    
        function obj = add_gssn(obj,gssn_agent)
            obj.gssn = gssn_agent;
        end

        function obj = add_to_gssn(obj, nation)
            obj.gssn = obj.gssn.add_nation(nation);
            obj.n_members = obj.n_members + 1;

        end

        function obj = remove_from_gssn(obj, nation)
            obj.gssn = obj.gssn.remove_nation(nation);
            obj.n_members = obj.n_members - 1;

        end


        function obj = timestep(obj,t)
            % commands the model to advance a time step

            %STEP 1: Update Environment (pass out collision info)
            obj = obj.leo_environment.update(t);
            
            total_objects = 8000;

            %STEP 2: Update Nation Preferences
            for i = 1:obj.n_nations
                obj.nations{i} = obj.nations{i}.update(total_objects,...
                    obj.gssn.num_objects, obj.gssn.fee);
            end

            %STEP 3: Collect nations that want to be in the GSSN but are
            %not currently for evaluation
            ct = 0;
            candidate_index = 0;
            for i = 1:obj.n_nations
                if obj.nations{1,i}.gssn_member == 0 && obj.nations{1,i}.want_gssn == 1
                    ct = ct + 1;
                    candidate_index(ct) = i;

                end
            end

            %STEP 4: Collect Nations that want out of the GSSN

            want_out = 0;
            ct = 0;
            for i = 1:obj.n_nations
                if obj.nations{1,i}.gssn_member == 1 && obj.nations{1,i}.want_gssn == 0
                    ct = ct + 1;
                    want_out(ct) = i;

                end
            end

            %STEP 5: TODO: Need some logic here. Right now, the GSSN just
            %lets everyone in
            if candidate_index ~=0
                for i = 1:length(candidate_index)
                    obj = obj.add_to_gssn(obj.nations{1,candidate_index(i)});

                    obj.nations{1,candidate_index(i)}.gssn_member = 1;
                end
            end


            if want_out ~=0
                for i = 1:length(want_out)
                    obj = obj.remove_from_gssn(obj.nations{1,want_out(i)});

                    obj.nations{1,want_out(i)}.gssn_member = 0;
                end
            end

            %gssn increases fee
            obj.gssn.fee = obj.gssn.fee;


            
            
        end
    end
end