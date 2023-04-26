
%this class is the GSSN

classdef GSSNObject
    
    properties

        num_nations
        num_objects
        nations
        min_data_quality %this is an input to test our hypothesis
        fee
        decision
        

    end

    methods
        function obj = GSSNObject(nn, ~, dq, na, cost)
            obj.num_nations = nn;
            obj.num_objects = 0; 
            obj.min_data_quality = dq;
            obj.nations = {}; 
            obj.fee = cost;
            obj.decision = [];
            gssn_tracking = 0;


        end
        
        function obj = update(obj, agents)
            obj.nations = agents;

            sum = 0;
            for i = 1:obj.num_nations
                sum = sum + obj.nations{i}.tracking_capacity;
            end

            obj.num_objects = sum;
        end
        
        
        function obj = evaluate(obj,nation)
            
            %check if nations average data quality is greater than or equal
            %to the minimum data quality required by the GSSN

            if nation.nation_data_quality >= obj.min_data_quality
                obj.decision = 1;
            else
                obj.decision = 0;
            end


        end
        
        function obj = add_nation(obj,nation)

            %look at the data quality of a nation, and compare it to the
            %input data quality

            %increment
            obj.num_nations = obj.num_nations + 1;

            %add nation to the end of the list
            obj.nations{1,end+1} = nation;

            obj.num_objects = obj.num_objects + nation.tracking_capacity;

        end

        function obj = remove_nation(obj,nation)


            %delete the nation from the list
            obj.nations{nation.id} = {};

            %reduce number of nations by 1
            obj.num_nations = obj.num_nations - 1;

            
           
            obj.num_objects = obj.num_objects - nation.tracking_capacity;
            
            %TODO: update data quality

            %delete the empty cell of the nation removed
            obj.nations = obj.nations(~cellfun('isempty',obj.nations));

        end

        
        function obj = update_dataquality(obj,members)

              
        %unused, since data quality is fixed for a simulation and 
            

        end

        function obj = timestep(obj)
            
            %possible actions the GSSA could take in a timestep?

        end
    end
end

