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
        sensor_manu_cost
        sensor_oper_cost
        sat_oper_cost
        sat_proc_cost
        sat_revenue
        gssn_member % bool
        gssn_member_status
        all_gssn_member_status
        fuzz_factor % bool
        tech_cap % technological capability (mean and std dev)
        sensor_data_quality %array of sensor data qualities
        nation_data_quality %nation data quality (avg of sensor data qualities)
        revenue
        total_cost
        need_sensor %bool
        last_sensor_request
        sensor_con_status
        all_status
        wait_con
        want_gssn %bool
        gssn_entry_wait
        gssn_leave_wait
        gssn_kick_wait
        budget
        yearly_budget
        satellites
        sat_life
        sat_retire
        launch_rate
        launch_rate_increase
        data
        econ_updates
        collision_occurred
    end
    
    methods
        
        function obj = NationAgent(timeVec,timeStep,id,sensors,sc,srr,scs,smc,soc,satoc,spc,sr,tc,gm,fuzz,gdp,nsat,sat_life,lr,lri)
            obj.timeVec = timeVec;
            obj.timeStep = timeStep;
            obj.id = id;
            obj.n_sensors = sensors;
            obj.sensor_capability = sc;
            obj.sensor_request_rate = srr;
            obj.sensor_con_speed = scs;
            obj.sensor_manu_cost = smc;
            obj.sensor_oper_cost = soc;
            obj.sat_oper_cost = satoc;
            obj.sat_proc_cost = spc;
            obj.sat_revenue = sr;
            obj.tech_cap = tc;
            obj.sensor_data_quality = normrnd(tc(1),tc(2),1,sensors);
            obj.sensor_data_quality(obj.sensor_data_quality>1) = 1; %cap sensor data quality at 1
            obj.sensor_data_quality(obj.sensor_data_quality<0) = 0; %No Negative data quality
            obj.nation_data_quality = mean(obj.sensor_data_quality);
            obj.sensor_tracking_capacity = sc*obj.sensor_data_quality;
            obj.tracking_capacity = sum(obj.sensor_tracking_capacity);
            obj.gssn_member = gm;
            obj.all_gssn_member_status = {'non-member','good-standing','bad-standing','joining','leaving'};
            obj.fuzz_factor = fuzz;
            obj.revenue = 0; % from successful space operations (acrued each time step per satellite)
            obj.total_cost = 0; % from sensor construction, sensor operation, etc
            obj.need_sensor = 0; %binary 0 = does not need sensor, 1 = need sensor
            obj.wait_con = 0;
            obj.sensor_con_status = 'na';
            obj.all_status = {'na','requested','building','done'};
            obj.last_sensor_request = 0;
            obj.want_gssn = gm;
            obj.gssn_entry_wait = 0;
            obj.gssn_leave_wait = 0;
            obj.gssn_kick_wait = 0;
            obj.budget = gdp;
            obj.yearly_budget = gdp;
            obj.satellites = nsat;
            obj.sat_life = sat_life;
            obj.sat_retire = obj.timeVec(1) + rand(1,obj.satellites)*obj.sat_life; % random sample uniformly between 0 and max sat life
            obj.launch_rate = lr;
            obj.launch_rate_increase = lri;
            obj.econ_updates = 0;
            obj.collision_occurred = 0;
            
            % initialize data for analysis
            obj.data.totalSensors = ones(size(timeVec))*obj.n_sensors;
            obj.data.trackingCapacity = ones(size(timeVec))*obj.tracking_capacity;
            obj.data.totalSatellites = ones(size(timeVec))*obj.satellites;
            obj.data.budget = zeros(size(timeVec));
            obj.data.revenue = zeros(size(timeVec));
            obj.data.cost = zeros(size(timeVec));
            obj.data.curSatOpCost = zeros(size(timeVec));
            obj.data.curSatOpRev = zeros(size(timeVec));
            obj.data.sensorStatus = repmat({obj.sensor_con_status},size(timeVec));
            obj.data.gssnMember = false(size(timeVec));
            obj.data.gssnMember(1) = gm;
            obj.data.gssnMemberStatus = repmat({'non-member'},size(timeVec));
            
            % set GSSN member status
            if obj.gssn_member
                obj.gssn_member_status = 'good-standing';
                obj.data.gssnMemberStatus{1} = 'good-standing';
            else
                obj.gssn_member_status = 'non-member';
            end
        end
        
        function obj = update(obj, t, total_objects, gssn_objects, fee, econParams)
            
            % determine storage array index from current sim time
            tIdx = t/obj.timeStep+1;
            
            % possibly update economic conditions (only performed annually)
            obj = obj.update_economic_conditions(t,econParams);
            
            % nation evaluates if it desires a new sensor
            obj = obj.sensor_desire(t,total_objects,gssn_objects);
            
            % determine if nation would rather join the gssn
            obj = obj.gssn_desire(fee,total_objects);
            
            % if the agent does not want to be part of the gssn but does
            % want to add a sensor, and can afford it,
            % add (or continue adding) the sensor
            obj = obj.add_sensor(t,econParams);
            
            % update sensor construction progress
            obj = obj.update_sensor_progress(t);
            
            % update tracking capacity
            obj.tracking_capacity = sum(obj.sensor_tracking_capacity);
            
            % launch and retire satellite(s) (maybe)
            obj = obj.update_satellites(t);
            
            % update national costs and revenue
            obj = obj.update_costs_and_revenue(tIdx,fee);
            
            % update data
            obj.data.totalSensors(tIdx) = obj.n_sensors;
            obj.data.trackingCapacity(tIdx) = obj.tracking_capacity;
            obj.data.totalSatellites(tIdx) = obj.satellites;
            obj.data.budget(tIdx) = obj.budget;
            obj.data.revenue(tIdx) = obj.revenue;
            obj.data.cost(tIdx) = obj.total_cost;
            obj.data.sensorStatus{tIdx} = obj.sensor_con_status;
            obj.data.gssnMemberStatus{tIdx} = obj.gssn_member_status;
            obj.data.gssnMember(tIdx) = obj.gssn_member;
            
        end
        
        function obj = sensor_desire(obj, t, total_objects, gssn_objects)
            %this method requires input of the total number of objects in
            %the environment and updates the desire of the agent to build a
            %sensor or not
            
            % if sensor is able to be requested
            if strcmp(obj.sensor_con_status,'na') || ...
                    (t - obj.last_sensor_request) >= obj.sensor_request_rate
                
                %if the agent is part of the gssn, total tracking capability of
                %the agent is the number of gssn objects being tracked
                if obj.gssn_member
                    total_tracked = max(gssn_objects,obj.tracking_capacity);
                else
                    total_tracked = obj.tracking_capacity;
                end
                
                % if collision occurred or tracking capacity insufficient
                if obj.wait_con > 0
                    obj.need_sensor = 1;
                elseif obj.collision_occurred || total_tracked < 1.2 * total_objects
                    obj.need_sensor = 1;
                    obj.last_sensor_request = t;
                    obj.sensor_con_status = 'requested';
                    if ~license('test','distrib_computing_toolbox')
                        fprintf('Year %.4f: Nation %d requested sensor\n',years(days(t)),obj.id);
                    end
                else
                    obj.need_sensor = 0;
                end
                
                %the agent has now expressed a desire for a new sensor or not
            end
        end
        
        function obj = update_sensor_progress(obj,t)
            % this method tracks how long the agent has been waiting for
            % the sensor to be built
            
            % if the agent just requested a sensor
            if (strcmp(obj.sensor_con_status,'na') && obj.wait_con == 0) || ...
                    (strcmp(obj.sensor_con_status,'requested') && (t - obj.last_sensor_request) == 0)
                % if the agent hasn't been waiting long enough, keep waiting
            elseif obj.wait_con < obj.sensor_con_speed
                obj.wait_con = obj.wait_con + 1;
                obj.sensor_con_status = 'building';
            else
                obj.sensor_con_status = 'done';
            end
        end
        
        function obj = add_sensor(obj,t,econParams)
            % if nation desires to add a sensor, and does not join the SSA to meet tracking needs,
            
            % if a nation cannot afford it, it will have to wait until the
            % next timestep it can afford it to continue manufacturing it
            if strcmp(obj.sensor_con_status,'done') && obj.budget >= (obj.sensor_manu_cost + obj.sensor_oper_cost)
                % if enough time has passed, add the cost of the sensor mfg to
                % the total cost, and increment the number of sensors
                obj.total_cost = obj.total_cost + obj.sensor_manu_cost;
                obj.budget = obj.budget - obj.sensor_manu_cost;
                obj.n_sensors = obj.n_sensors + 1;
                obj.sensor_manu_cost = max(obj.sensor_manu_cost - econParams.sensorDiscount,400);
                
                % add sensor with a random data quality
                sdq = normrnd(obj.tech_cap(1),obj.tech_cap(2));
                obj.sensor_data_quality(end+1) = sdq;
                obj.nation_data_quality = mean(obj.sensor_data_quality);
                obj.sensor_tracking_capacity(end+1) = obj.sensor_capability*sdq;
                
                % reset construction wait counter
                obj.wait_con = 0;
                obj.sensor_con_status = 'na';
                
                if ~license('test','distrib_computing_toolbox')
                    fprintf('Year %.4f: Nation %d added sensor\n',years(days(t)),obj.id);
                end
            end
        end
        
        function obj = gssn_desire(obj, fee, total_objects)
            % nation decides whether to join, leave, or stay in the GSSN
            
            %if an agent doesn't need a sensor, nothing will change here
            %if its current needs are not met, and the agent is not in the
            %gssn already, figure out how much adding a sensor would cost
            %and do a simple compare to the cost of being part of the GSSN
            
            if obj.need_sensor == 1 && ~obj.gssn_member
                %if nation cannot afford the gssn fee, it cannot join
                if obj.budget < fee
                    obj.want_gssn = false;
                else
                    %if it is cheaper to mfg a sensor vs joining gssn, and
                    % building a new sensor will give sufficient tracking
                    % capacity, then nation will choose to build its own
                    if obj.sensor_manu_cost < fee && (obj.tracking_capacity + obj.sensor_capability*obj.tech_cap(1))/total_objects >= 1.2
                        obj.want_gssn = false;
                    else
                        obj.want_gssn = true;
                    end
                end
            elseif obj.need_sensor == 0 && ~obj.gssn_member
                % if the nation already has sufficient tracking capacity on
                % its own, it does not need to join the GSSN and pay the
                % fee
                obj.want_gssn = false;
            elseif obj.need_sensor == 0 && obj.gssn_member
                % if the object doesn't need a sensor and is currently a
                % member, it evaluates if it could still maintain the
                % desired tracking capacity on its own
                if obj.tracking_capacity/total_objects >= 1.2 || obj.budget <= fee
                    obj.want_gssn = false;
                else
                    obj.want_gssn = true;
                end
            else
                % obj needs a sensor and is in the GSSN, so it should stay
                % in the GSSN until its sensor is built (if it can afford
                % to), then re-evaluate
                if obj.budget <= fee
                    obj.want_gssn = false;
                else
                    obj.want_gssn = true;
                end
            end
        end
        
        function obj = update_economic_conditions(obj,t,econParams)
            % updates annually, not each timestep
            if mod(t,365.2425) < obj.timeStep
                obj.econ_updates = obj.econ_updates + 1;
                
                %simulates random fluctuations in the nations budget
                %take the budget, and add or subtract a percentage of the
                %budget based on standard normal distribution
                obj.budget = obj.budget + obj.yearly_budget*econParams.inflation*normrnd(0.5,1);
                obj.sensor_manu_cost = min(obj.sensor_manu_cost+econParams.sensorPenalty,3200)*econParams.inflation;
                obj.sensor_oper_cost = obj.sensor_oper_cost*econParams.inflation;
                obj.sat_oper_cost = obj.sat_oper_cost*econParams.inflation;
                obj.sat_proc_cost = obj.sat_proc_cost*econParams.inflation;
                obj.sat_revenue = obj.sat_revenue*econParams.inflation;
                
                % Can degrade DQ of all sensors yearly. One possible
                % mechanism to incentivise nations to still build sensors
                % even after joining GSSN. [currently disabled]
                obj.sensor_data_quality = obj.sensor_data_quality * 1.00;
            end
        end
        
        function obj = update_costs_and_revenue(obj, tIdx, fee)
            % costs from sensor operation, satellite operation, GSSN
            % membership; revenue from satellite operations. Manufacturing
            % costs applied elsewhere.
            if obj.gssn_member
                obj.budget = obj.budget - fee*obj.timeStep/365.2426;
            end
            
            % sensor operation costs
            currentSensOpCost = obj.n_sensors*obj.sensor_oper_cost*obj.timeStep/365.2425;
            obj.total_cost = obj.total_cost + currentSensOpCost;
            obj.budget = obj.budget - currentSensOpCost;
            
            % satellite operation costs
            currentSatOpCost = obj.satellites*obj.sat_oper_cost*obj.timeStep/365.2425;
            obj.total_cost = obj.total_cost + currentSatOpCost;
            obj.budget = obj.budget - currentSatOpCost;
            
            % satellite operation revenue
            currentSatRev = obj.satellites*obj.sat_revenue*obj.timeStep/365.2425;
            obj.revenue = obj.revenue + currentSatRev;
            obj.budget = obj.budget + currentSatRev;
            
            % update data
            obj.data.curSatOpCost(tIdx) = currentSatOpCost;
            obj.data.curSatOpRev(tIdx) = currentSatRev;
        end
        
        function obj = update_satellites(obj,t)
            % launch/de-orbit satellites
            
            % random draw to determine possible launches
            % nations increase launch rate at +0.05 per year
            if mod(t,365.2425) < obj.timeStep
                obj.launch_rate = obj.launch_rate + obj.launch_rate_increase;
            end
            launchEvents = round(normrnd(obj.launch_rate,0.5));
            if launchEvents < 0
                launchEvents = 0;
            end
            
            % update budget and increase satellite count for each launch
            remainingLaunches = launchEvents;
            while remainingLaunches > 0
                if obj.budget > (obj.sat_proc_cost + obj.sat_oper_cost)
                    obj.satellites = obj.satellites + 1;
                    obj.sat_retire(end+1) = obj.sat_life + t;
                    obj.total_cost = obj.total_cost + obj.sat_proc_cost;
                    obj.budget = obj.budget - obj.sat_proc_cost;
                end
                remainingLaunches = remainingLaunches-1;
            end
            
            % retire satellites that have orbited for their lifetime
            retireEventsIdx = t > obj.sat_retire;
            retireEvents = sum(retireEventsIdx);
            obj.satellites = obj.satellites - retireEvents;
            obj.sat_retire(retireEventsIdx) = [];
        end
        
        function obj = reset_gssn_waits(obj)
            % reset wait time counters when GSSN membership status changes
            obj.gssn_entry_wait = 0;
            obj.gssn_leave_wait = 0;
            obj.gssn_kick_wait = 0;
        end
    end
end