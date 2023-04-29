
%this class is the GSSN

classdef GSSNObject
    
    properties
        timeStep
        num_nations
        num_objects
        nations
        min_data_quality %this is an input to test our hypothesis
        feeCoeff
        fee
        decision
        entry_wait
        leave_wait
        kick_wait
        data
        
    end

    methods
        function obj = GSSNObject(nn, dq, gssnFeeCoeff, wait_times, timeStep, timeVec)
            % initialize GSSN object

            obj.num_nations = nn;
            obj.num_objects = 0; 
            obj.min_data_quality = dq;
            obj.nations = []; 
            obj.feeCoeff = gssnFeeCoeff;
            obj.fee = 0;
            obj.timeStep = timeStep;
            obj.entry_wait = wait_times(1)*365.2425/timeStep; % time steps;
            obj.leave_wait = wait_times(2)*365.2425/timeStep; % time steps;
            obj.kick_wait = wait_times(3)*365.2425/timeStep; % time steps;
            
            % initialize GSSN data storage
            obj.data.total_members_cum = zeros(1,length(timeVec));
            obj.data.total_members_cum(1) = nn;
            obj.data.tracking_capacity = zeros(1,length(timeVec));
            obj.data.combined_sensors = zeros(1,length(timeVec));
            obj.data.fee = zeros(1,length(timeVec));

        end
        
        function obj = update(obj,nations,t)

            % determine number of total objects tracked by GSSN
            sum = 0;
            sumSens = 0;
            for i = 1:obj.num_nations
                sum = sum + nations{i}.tracking_capacity*nations{i}.fuzz_factor;
                sumSens = sumSens + nations{i}.n_sensors;
            end
            obj.num_objects = sum;
            
            % determine current GSSN membership fee
            obj.fee = obj.feeCoeff(1) + obj.feeCoeff(2)*obj.num_nations;
            
            % update data
            obj.data.total_members_cum(t/obj.timeStep+1) = obj.num_nations;
            obj.data.tracking_capacity(t/obj.timeStep+1) = sum;
            obj.data.combined_sensors(t/obj.timeStep+1) = sumSens;
            obj.data.fee(t/obj.timeStep+1) = obj.fee;
        end
        
        
        function [obj, decision] = evaluate(obj,nation)
            
            %check if nations average data quality is greater than or equal
            %to the minimum data quality required by the GSSN

            if nation.nation_data_quality >= obj.min_data_quality
                decision = 1;
            else
                decision= 0;
            end

        end
        
        function obj = add_nation(obj,nation)

            %look at the data quality of a nation, and compare it to the
            %input data quality

            %increment
            obj.num_nations = obj.num_nations + 1;

            %add nation to the end of the list
            obj.nations(end+1) = nation.id;

            obj.num_objects = obj.num_objects + nation.tracking_capacity;

        end

        function obj = remove_nation(obj,nation)

            %delete the nation from the list
            obj.nations(obj.nations == nation.id) = [];

            %reduce number of nations by 1
            obj.num_nations = obj.num_nations - 1;
            obj.num_objects = obj.num_objects - nation.tracking_capacity;
            
            %TODO: update data quality

        end

        
        function obj = update_dataquality(obj,members)

              
        %unused, since data quality is fixed for a simulation and 
            

        end

        function obj = timestep(obj)
            
            %possible actions the GSSA could take in a timestep?

        end
    end
end

