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
        data_quality %array of sensor data qualities
        revenue
        total_cost
        need_sensor %bool
        wait
        want_gssn %bool
        budget
     
    end
    
    methods
        
        function obj = NationAgent(id,sensors,sc,scs,smc,soc,dq,gm,fuzz, gdp)
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
            obj.want_gssn = gm;
            obj.budget = gdp;
            
          

        end
        
        function obj = update(obj, total_objects, gssn_objects, fee)

            
            obj = sensor_desire(obj,total_objects,gssn_objects);

            obj = gssn_desire(obj,fee);
           


            %if the agent does not want to be part of the gssn but does 
            % want to add a sensor, and can afford it, 
            % add (or continue adding) the sensor

            %if a nation cannot afford it, it will have to wait until the
            %next timestep it can afford it to continue manufacturing it
            
            if obj.want_gssn == 0 && obj.need_sensor == 1 && obj.budget >= obj.sensor_manu_cost
                obj = obj.add_sensor();
            end
            
            %update tracking capacity
            obj.tracking_capacity = obj.sensor_capability * obj.n_sensors;

            %update economic conditions
            obj = obj.update_economic_conditions();

        end
        
        function obj = sensor_desire(obj, total_objects, gssn_objects)

            %this method requires input of the total number of objects in
            %the environment and updates the desire of the agent to build a
            %sensor or not
            

            %if the agent is part of the gssn, total tracking capability of
            %the agent is the number of gssn objects being tracked
            
            if obj.gssn_member == 1
                total_tracked = gssn_objects;
            else
                total_tracked = obj.tracking_capacity;
            end


            if total_tracked < 1.2 * total_objects
                obj.need_sensor = 1;
            else
                obj.need_sensor = 0;
            end


            %the agent has now expressed a desire for a new sensor or not
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
                
                %add sensor with a random data quality
                obj.data_quality(end+1) = randi([1 3]);

                obj.wait = 0;

            end

        end
        
        function obj = gssn_desire(obj, fee)
            % nations decides whether to join, leave, or stay in the GSSN

            %if an agent doesn't need a sensor, nothing will change here
            %if its current needs are not met, and the agent is not in the
            %gssn already, figure out how much adding a sensor would cost
            %and do a simple compare to the cost of being part of the GSSN
            
            if obj.need_sensor == 1 && obj.gssn_member == 0

                %simple check, could add complexity here
 %%%%%%%%%%MANUFACTURING COST OR OPERATION COST?%%%%%%%%%%%%%%%%%%

                %if it's cheaper to mfg a sensor vs joining gssn, nation
                %will choose to make its own
                if obj.sensor_manu_cost < fee || obj.budget < fee
                    obj.want_gssn= 0;

                
                elseif obj.sensor_manu_cost >= fee && obj.budget > fee
                    obj.want_gssn = 1;

                end

                %the agent has now updated its desire of if it wants to be
                %part of the GSSN or not based on cost alone. Note this
                %does not change anything if the agent is already part of
                %the gssn

                %TODO: Add economics logic
            end

        end
        
%        function obj = fuzzing_decision(obj)
%             % nation decides whether or not to fuzz their data 
%             
%         end
        
        function obj = update_economic_conditions(obj)
            % "The SoS model also needs to support the injection of events 
            % that shape the economic or political conditions under which 
            % each nation is operating at that time, which affects 
            % variables like sensor manufacturing and operating costs and 
            % sensor addition timeline."
            

            %simulates random fluctuations in the nations budget
            %take the budget, and add or subtract a percentage of the
            %budget based on standard normal distribution

            obj.budget = obj.budget + obj.budget * rand()/100;
            obj.sensor_manu_cost = obj.sensor_manu_cost*1.03;



        end
        
        function obj = update_costs_and_revenue(obj)
            % costs from sensor manufacturing/operation, revenue from
            % successful space operations
        end
        
    end
end