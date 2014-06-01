classdef InfCapillary < InfCapillaryGeneral

	methods        
        function this = InfCapillary(Geometry)
            this@InfCapillaryGeneral(Geometry);
        end
    end
    
    methods (Access = public)
        function [y1,dy1,dx,ddx,dddx,ddddx] = PhysSpace1(this,x1)
            [y1,dy1,dx,ddx,dddx,ddddx] = SqrtMap(x1,this.L1,inf);            
            y1 =  this.y10 + y1; 
        end
        function xf = CompSpace1(this,y1)            
            xf  = InvSqrtMap(y1 - this.y10,this.L1,inf);
        end    
    end
end