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
        function obj = GlobalSSAModel() % TODO: inputs to initialize debris model
            % initialize model
            obj.nations = {};
            obj.n_nations = 0;
            obj.n_members = 0;
            obj.n_nonmembers = 0;
            
            % initialize GSSN object
            obj.gssn = GSSNObject();
            
            % initialize LEO satellite/debris model
            obj.leo_environment = LEOModel(); %TODO: hook in Joe's debris model
            
        end
        
        
        function obj = add_nation(obj, nation_agent)
            % Adds an nation agent object
            
        end
    
        function obj = timestep(obj,t)
            % commands the model to advance a time step
            
            % execute environment object, nation agent, and GSSN object updates
            
        end
    end
end