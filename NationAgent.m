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

        end
        
        function obj = update(obj)
            % execute nation decisions for current time step
        end
        
        function obj = assess_sensor_population(obj)
            % nation compares tracking capacity against its current sensor
            % population to determine whether a new sensor should be added
        end
        
        function obj = add_sensor(obj)
            % nation starts or continues to build a new sensor
        end
        
        function obj = assess_gssn_membership(obj)
            % nations decides whether to join, leave, or stay in the GSSN
            
            % should joining/leaving GSSN take more than one timestep?
        end
        
%         function obj = fuzzing_decision(obj)
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