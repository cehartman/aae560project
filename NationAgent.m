classdef NationAgent
    
    properties
        timeVec
        timeStep
        id
        n_sensors
        sensor_capability
        sensor_tracking_capacity
        tracking_capacity
        sensor_request_rate
        sensor_con_speed
        sensor_manu_cost % per nation or same for all nations?
        sensor_oper_cost
        gssn_member % bool
        fuzzing % bool
        economic_conditions
        tech_cap % technological capability (mean and std dev)
        sensor_data_quality %array of sensor data qualities
        nation_data_quality %nation data quality (avg of sensor data qualities)
        revenue
        total_cost
        need_sensor %bool
        last_sensor_request
        wait_con
        want_gssn %bool
        budget
        satellites
        launch_rate
        data
        econUpdates
     
    end
    
    methods
        
        function obj = NationAgent(timeVec,timeStep,id,sensors,sc,srr,scs,smc,soc,tc,gm,fuzz,gdp,nsat,lr)
            obj.timeVec = timeVec;
            obj.timeStep = timeStep;
            obj.id = id;
            obj.n_sensors = sensors;
            obj.sensor_capability = sc;
            obj.sensor_request_rate = srr;
            obj.sensor_con_speed = scs;
            obj.sensor_manu_cost = smc;
            obj.sensor_oper_cost = soc;
            obj.tech_cap = tc;
            obj.sensor_data_quality = normrnd(tc(1),tc(2),1,sensors);
            obj.sensor_data_quality(obj.sensor_data_quality>1) = 1; %cap sensor data quality at 1
            obj.nation_data_quality = mean(obj.sensor_data_quality);
            obj.sensor_tracking_capacity = sc*obj.sensor_data_quality;
            obj.tracking_capacity = sum(obj.sensor_tracking_capacity);
            obj.gssn_member = gm;
            obj.fuzzing = fuzz;
            obj.revenue = 0; % from successful space operations (maybe acrued each time step without a collision?)
            obj.total_cost = 0; % from sensor construction, sensor operation, satellite collisions
            obj.need_sensor = 0; %binary 0 = does not need sensor, 1 = need sensor
            obj.wait_con = 0;
            obj.last_sensor_request = 0;
            obj.want_gssn = gm;
            obj.budget = gdp;
            obj.satellites = nsat;
            obj.launch_rate = lr;
            obj.econUpdates = 0;
            
            % initialize data for analysis
            obj.data.totalSensors = ones(size(timeVec))*obj.n_sensors;
            obj.data.trackingCapacity = ones(size(timeVec))*obj.tracking_capacity;
            obj.data.totalSatellites = ones(size(timeVec))*obj.satellites;
        end
        
        function obj = update(obj, t, total_objects, gssn_objects, fee, econParams)

            % determine storage array index from current sim time
            tIdx = t/obj.timeStep+1;
            
            % possibly update economic conditions (only performed annually)
            if mod(t,365.2425) < 8
                obj.econUpdates = obj.econUpdates + 1;
                obj = obj.update_economic_conditions(econParams);
            end
            
            % nation evaluates if it desires a new sensor
            if obj.need_sensor == 0 || (t - obj.last_sensor_request) >= obj.sensor_request_rate
                obj = obj.sensor_desire(t,total_objects,gssn_objects);
                if obj.need_sensor == 1
                    disp(['Nation ' num2str(obj.id) ' requested sensor at year ' num2str(years(days(t)))]);
                end
            end

            obj = obj.gssn_desire(fee);
           


            %if the agent does not want to be part of the gssn but does 
            % want to add a sensor, and can afford it, 
            % add (or continue adding) the sensor

            %if a nation cannot afford it, it will have to wait until the
            %next timestep it can afford it to continue manufacturing it
            
%             if obj.want_gssn == 0 && 
            if obj.need_sensor == 1 ...
                    && obj.budget >= obj.sensor_manu_cost
                obj = obj.add_sensor();
                if obj.wait_con == 0
                    disp(['Nation ' num2str(obj.id) ' added sensor at year ' num2str(years(days(t)))]);
                end
            end
            
            %update tracking capacity
            obj.tracking_capacity = sum(obj.sensor_tracking_capacity);

            % launch satellite(s) (maybe)
            obj = obj.launch_satellites(econParams);
            
            % update national costs and revenue
            obj = obj.update_costs_and_revenue(econParams);
            
            % update data
            obj.data.totalSensors(tIdx) = obj.n_sensors;
            obj.data.trackingCapacity(tIdx) = obj.tracking_capacity;
            obj.data.totalSatellites(tIdx) = obj.satellites;

        end
        
        function obj = sensor_desire(obj, t, total_objects, gssn_objects)

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
                obj.last_sensor_request = t;
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
            if obj.wait_con < obj.sensor_con_speed
                obj.wait_con = obj.wait_con + 1;

            %if enough time has passed, add the cost of the sensor mfg to
            %the total cost, and increment the number of sensors
            elseif obj.wait_con >= obj.sensor_con_speed
                obj.total_cost = obj.total_cost + obj.sensor_manu_cost;
                obj.n_sensors = obj.n_sensors + 1;
                
                %add sensor with a random data quality
                sdq = normrnd(obj.tech_cap(1),obj.tech_cap(2));
                obj.sensor_data_quality(end+1) = sdq;
                obj.nation_data_quality = mean(obj.sensor_data_quality);
                obj.sensor_tracking_capacity(end+1) = obj.sensor_capability*sdq;
                
                %reset construction wait counter
                obj.wait_con = 0;

            end

        end
        
        function obj = gssn_desire(obj, fee)
            % nation decides whether to join, leave, or stay in the GSSN

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
        
        function obj = update_economic_conditions(obj,econParams)
            % "The SoS model also needs to support the injection of events 
            % that shape the economic or political conditions under which 
            % each nation is operating at that time, which affects 
            % variables like sensor manufacturing and operating costs and 
            % sensor addition timeline."
            

            %simulates random fluctuations in the nations budget
            %take the budget, and add or subtract a percentage of the
            %budget based on standard normal distribution

            obj.budget = obj.budget + obj.budget; %*normrnd(0,1); TODO: decide on budget fluctuation
            obj.sensor_manu_cost = obj.sensor_manu_cost*econParams.inflation;



        end
        
        function obj = update_costs_and_revenue(obj,econParams)
            % costs from sensor operation, satellite operation, revenue from
            % satellite operations. Manufacturing costs applied elsewhere.
            
            % sensor operation costs
            currentSensOpCost = obj.n_sensors*econParams.sensorOpCost*obj.timeStep/365.2425;
            obj.total_cost = obj.total_cost + currentSensOpCost;
            obj.budget = obj.budget - currentSensOpCost;
            
            % satelite operation costs
            currentSatOpCost = obj.satellites*econParams.satOpCost*obj.timeStep/365.2425;
            obj.total_cost = obj.total_cost + currentSatOpCost;
            obj.budget = obj.budget - currentSatOpCost;
            
            % satellite operation revenue
            currentSatRev = obj.satellites*econParams.satOpRev*obj.timeStep/365.2425;
            obj.revenue = obj.revenue + currentSatRev;
            obj.budget = obj.budget + currentSatRev;
        end
        
        function obj = launch_satellites(obj,econParams)
            %TODO: what economic considerations determine when satellites are launched?
            launchEvents = round(normrnd(obj.launch_rate,0.5));
            if launchEvents < 0
               launchEvents = 0; 
            end
            remainingLaunches = launchEvents;
            while remainingLaunches > 0
                if obj.budget > econParams.newSatCost
                    obj.satellites = obj.satellites + 1;
                    obj.total_cost = obj.total_cost + econParams.newSatCost;
                    obj.budget = obj.budget - econParams.newSatCost;
                end
                remainingLaunches = remainingLaunches-1;
            end
        end
        
    end
end