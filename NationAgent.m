classdef NationAgent
    
    properties
        id
        n_sensors
        sensor_capability
        tracking_capacity
        sensor_con_speed
        sensor_manu_cost % per nation or same for all nations?
        sensor_oper_cost
        gssn_member % bool
        fuzzing % bool
        economic_conditions
        data_quality
        revenue
        total_cost
        need_sensor %bool
        wait
        gssn_desire %bool
     
    end
    
    methods
        
        function obj = NationAgent(id,sensors,sc,scs,smc,soc,dq,gm,fuzz)
            obj.id = id;
            obj.n_sensors = sensors;
            obj.sensor_capability = sc;
            obj.tracking_capacity = sensors*sc;
            obj.sensor_con_speed = scs;
            obj.sensor_manu_cost = smc;
            obj.sensor_oper_cost = soc;
            obj.data_quality = dq;
            obj.gssn_member = gm;
            obj.fuzzing = fuzz;
            obj.revenue = 0; % from successful space operations (maybe acrued each time step without a collision?)
            obj.total_cost = 0; % from sensor construction, sensor operation, satellite collisions
            obj.need_sensor = 0; %binary 0 = does not need sensor, 1 = need sensor
            obj.wait = 0;
            obj.gssn_desire = 0;
          

        end
        
        function obj = update(obj)
            % execute nation decisions for current time step
            
            %decide to join GSSA or not

            %decide whether or not to build a new sensor

        end
        
        function obj = assess_sensor_population(obj, total_objects)

            %this method requires input of the total number of objects in
            %the environment and updates the desire of the agent to build a
            %sensor or not

            obj.tracking_capacity = sensors*sc;
            if obj.tracking_capacity < 1.2 * total_objects
                obj.need_sensor = 1;
            else
                obj.need_sensor = 0;
            end

        end
        
        function obj = add_sensor(obj)
            % if nation desires to add a sensor, and does not join the SSA to meet tracking needs,
            % this method tracks how long the agent has been waiting for
            % the sensor to be built

            %if the agent hasn't been waiting long enough, keep waiting
            if obj.wait < obj.sensor_con_speed
                obj.wait = obj.wait + 1;

            %if enough time has passed, add the cost of the sensor mfg to
            %the total cost, and increment the number of sensors
            elseif obj.wait >= obj.sensor_con_speed
                obj.total_cost = obj.total_cost + obj.sensor_manu_cost;
                obj.n_sensors = obj.n_sensors + 1;

            end


            %for each time step, increment counter until SCS is met, then
            %add the sensor to the nations capability
        end
        
        function obj = assess_gssn_membership(obj, total_objects, gssn)
            % nations decides whether to join, leave, or stay in the GSSN

            %First thing the nation looks at is if its tracking needs are
            %met
            
            obj.assess_sensor_population(obj,total_objects)
            
            %if an agent doesn't need a sensor, nothing will change here
            %if its current needs are not met, and the agent is not in the
            %gssn already, figure out how much adding a sensor would cost
            %and do a simple compare to the cost of being part of the GSSN
            
            if obj.need_sensor == 1 && obj.gssn_member == 0

                %simple check, could add complexity here
 %%%%%%%%%%MANUFACTURING COST OR OPERATION COST?%%%%%%%%%%%%%%%%%%
                if obj.sensor_manu_cost < gssn.fee
                    obj.gssn_desire = 0;
                elseif obj.sensor_manu_cost >= gssn.fee
                    obj.gssn_desire = 1;

                end
            
                %TODO(?): could add another decision tree on whether or not the
                %agent wants to leave the gssn

                %now that the agent has expressed a desire to join the
                %GSSN, we will assess if the GSSN will let the agent join

                gssn.inorout(obj);

                %if the agent wants in, and the gssn will let them in,
                %admit

                if gssn.decision == 1 && obj.gssn_desire == 1

                    %add member to GSSN
                    obj.gssn_member = 1;
                    %add gssn object tracking capability to nation tracking
                    %capability
                

                %if the nation wants in, but the gssn won't let them in,
                %then the nation needs to build a sensor
                elseif gssn.decision == 0 && obj.gssn_desire == 1

                    obj.gssn_member = 0;
                    obj.add_sensor(obj);

                end



        end
        
%       function obj = fuzzing_decision(obj)
%             % nation decides whether or not to fuzz their data 
%             
%         end
        
        function obj = update_economic_conditions(obj)
            % "The SoS model also needs to support the injection of events 
            % that shape the economic or political conditions under which 
            % each nation is operating at that time, which affects 
            % variables like sensor manufacturing and operating costs and 
            % sensor addition timeline."
        end
        
        function obj = update_costs_and_revenue(obj)
            % costs from sensor manufacturing/operation, revenue from
            % successful space operations
        end
        
    end
end