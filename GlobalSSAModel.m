classdef GlobalSSAModel
    
    properties
        leo_environment
        nations
        n_nations
        n_members % may be better suited as a GSSN object property
        n_nonmembers % may be better suited as a GSSN object property
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
        
        
        function obj = add(obj, object)
            % Adds an object
            obj = obj.add(object);
        end
    
        function obj = step(obj,t)
            % command the model to advance a time step
            obj = obj.step(t);
        end
    end
end