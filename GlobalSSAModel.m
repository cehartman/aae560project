classdef GlobalSSAModel
    
    properties

        %time
    
    end
    
    methods
        function obj = GlobalSSAModel()
            % initialize model
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