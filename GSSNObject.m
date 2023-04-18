
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
        function obj = GSSNObject(cost)
            obj.num_nations = 0;
            obj.num_objects = 0;
            obj.data_quality = 0;
            obj.nations = {}; 

        end

        %adds a nation to the GSSN
        function obj = add_nation(obj,nation_name,objects_tracking)
            %increment 
            obj.num_nations = obj.num_nations + 1;

            %add nation to the end of the list
            obj.nations(end+1) = {nation_name};

            obj.num_objects = obj.num_objects + objects_tracking;

            %Increment data quality

        end

        function obj = remove_nation(obj,nation_name, objects_tracking)

            %search the list and return the index of the nation
            ind = 0;
            for i = 1:obj.num_nations
                if obj.nations(i) == nation_name
                    ind = i; %index of nation to be removed
                end
            end

            %error if index is never updated, nation name is not found
            if ind == 0
                error('In: gssaAgent.m. Nation trying to be removed is not found!')
            end

            %delete the nation from the list
            obj.nations(ind) = [];

            %reduce number of nations by 1
            obj.num_nations = obj.num_nations - 1;

            
           
            obj.num_objects = obj.num_objects - objects_tracking;
            %update data quality

        end


        function obj = inorout(obj,agent)
            
            %this function makes a decision if the nation in question
            %should be accepted or rejected from the gssn
            %Basically, can the nation afford to be in the GSSN or not

        end
        
        function obj = update_dataquality(obj,members)

              %TODO:Update data quality based on all the members in the GSSN  

            

        end

        function obj = timestep(obj)
            
            %possible actions the GSSA could take in a timestep?

        end
    end
end

