
%this class is the GSSN

classdef GSSNObject
    
    properties

        num_nations
        num_objects
        nations
        data_quality
        fee
        decision
        

    end

    methods
        function obj = GSSNObject(nn, no, dq, na, cost)
            obj.num_nations = nn;
            obj.num_objects = no; %move this to an update 
            obj.data_quality = dq;
            obj.nations = {}; 
            obj.fee = cost;

        end
        function obj = update(obj, agents)
            obj.nations = agents;

            sum = 0;
            for i = 1:obj.num_nations
                sum = sum + obj.nations{i}.tracking_capacity;
            end

            obj.num_objects = sum;
        end

        %adds a nation to the GSSN
        function obj = add_nation(obj,nation)
            %increment 
            obj.num_nations = obj.num_nations + 1;

            %add nation to the end of the list
            obj.nations{1,end+1} = {nation};

            obj.num_objects = obj.num_objects + nation.tracking_capacity;

           

            %TODO: Increment data quality ?

        end

        function obj = remove_nation(obj,nation)

            %search the list and return the index of the nation
            ind = 0;
            for i = 1:obj.num_nations
                if obj.nations{i}.id == nation.id
                    ind = i; %index of nation to be removed
                end
            end

            %error if index is never updated, nation name is not found
            if ind == 0
                error('In: gssaAgent.m. Nation trying to be removed is not found!')
            end

            %delete the nation from the list
            obj.nations{ind} = {};

            %reduce number of nations by 1
            obj.num_nations = obj.num_nations - 1;

            
           
            obj.num_objects = obj.num_objects - nation.tracking_capacity;
            
            %TODO: update data quality

            %delete the empty cell of the nation removed
            obj.nations = obj.nations(~cellfun('isempty',obj.nations));

        end


        function obj = inorout(obj)
            
            %this function makes a decision if the nation in question
            %should be accepted or rejected from the gssn
            obj.decision = 1;
            

        end
        
        function obj = update_dataquality(obj,members)

              %TODO:Update data quality based on all the members in the GSSN  

            

        end

        function obj = timestep(obj)
            
            %possible actions the GSSA could take in a timestep?

        end
    end
end

