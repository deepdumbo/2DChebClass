classdef InfCapillary_FMT < InfCapillary
    properties
        R
        AD %Check how to handle multiple Species!        
        InterpFull
    end
    
    methods
        function this = InfCapillary_FMT(Geometry,R)                        
            
            shapeHS       = Geometry;
            shapeHS.y2Min = Geometry.y2Min+R;
            shapeHS.y2Max = Geometry.y2Max-R;            
            this@InfCapillary(shapeHS);
            this.R        = R;            
            this.AD = InfCapillary_AD_FMT(Geometry);                        
        end                          
        
        function [dataCircle] = AverageCirclePt(this,y20,r,Ncircle) 
            %Computes Data of the intersection of a circle with radius r
            % and centered at (x,y20) with the domain
            
            shapeLine.N = Ncircle;
            shapeLine.R = r;            
            
            %Get Shape for Line
            if((y20 >= this.y2Min + r) && (y20 <= this.y2Min - r))
                line               = Circle(shapeLine);                                                
            elseif((y20 < (this.y2Max + r)) && ...
                   (y20 >= (this.y2Max - r)))               
                th                 = acos((y20 - this.y2Max)/r);
                shapeLine.th1      = -pi/2 + th;
                shapeLine.th2      = 3/2*pi-th;
                
                line               = Arc(shapeLine);
                dataCircle.pts     = Pol2CartPts(line.Pts);                
            elseif((y20 < (this.y2Min + r)) && ...
                   (y20 >= (this.y2Min - r)))               
                th                 = acos((y20 - this.y2Min)/r);
                shapeLine.th1      = -pi/2 + th;
                shapeLine.th2      = 3/2*pi-th;
                
                line               = Arc(shapeLine);
                dataCircle.pts     = Pol2CartPts(line.Pts);
            else
                exc = MException('HalfSpace_FMT:AverageDisk','case not implemented');
                throw(exc);                
            end
            
            dataCircle.pts       = Pol2CartPts(line.Pts);   
            dataCircle.pts.y2_kv = dataCircle.pts.y2_kv + y20;
            dataCircle.ptsPolLoc = line.Pts;            
            
            [dataCircle.int,dataCircle.area] = line.ComputeIntegrationVector();                                                   
            
            scatter(dataCircle.pts.y1_kv,dataCircle.pts.y2_kv,'.');            
        end        
        function dataDisk = AverageDiskPt(this,y20,r,N,sphere)
            %Computes Data of the intersection of a disk with radius r
            % and centered at (x,y20) with the domain
            
            shape.N  = N;
            shape.R  = r;     
            if((nargin == 5) && strcmp(sphere,'sphere'))
                shape.sphere = true;
            end
                        
            %1. find points of disk in HalfSpace            
            if((y20 >= this.y2Min + r) && (y20 <= this.y2Max - r))
                %1a. if full disk is in HalfSpace                
                area               = Disc(shape); 
                dataDisk.pts       = Pol2CartPts(area.Pts);
                
            elseif((y20 <= this.y2Max) && (y20 > this.y2Max - r))
                shape.h         = y20 - this.y2Max;
                shape.InOut     = 'Out';
                                
                area            = BigSegment(shape);                
                dataDisk.pts    = area.Pts;
                             
            elseif((y20 < this.y2Min + r) && (y20 >= this.y2Min))
                %1b. if part of disk is in HalfSpace  (>= half)
                %1b1. Integrate over segment in HalfSpace
                %shape.Origin    = [0,y20];
                shape.h         = y20 - this.y2Min;
                shape.InOut     = 'Out';
                                
                area               = BigSegment(shape);                
                dataDisk.pts       = area.Pts;                         

            elseif( (y20 <= this.y2Max + r) && (y20 > this.y2Max))                
                shape.h         = this.y2Max - y20;
                
                area            = Segment(shape);                
                dataDisk.pts    = area.Pts;                                   
                
            elseif( (y20 < this.y2Min) && (y20 >= this.y2Min - r))                
                shape.h         = this.y2Min - y20;
                
                area               = Segment(shape);                
                dataDisk.pts       = area.Pts;                                                
            %1c. if part of disk is in HalfSpace  (< half)    
            else
                exc = MException('HalfSpace_FMT:AverageDisk','case not implemented');
                throw(exc);                
            end            
            
            %Shift in y2-direction
            dataDisk.ptsPolLoc = Cart2PolPts(area.Pts);            
            dataDisk.pts.y2_kv = dataDisk.pts.y2_kv + y20;
                        
            [dataDisk.int,dataDisk.area] = area.ComputeIntegrationVector();
                                   
            scatter(dataDisk.pts.y1_kv,dataDisk.pts.y2_kv,'.');            
        end     
        function dataBall = AverageBallPt(this,y20,r,N)
            shape.N  = N;
            shape.R  = r;     
                        
            %1. find points of disk in HalfSpace            
            if((y20 >= this.y2Min + r) && (y20 <= this.y2Max - r))
                %1a. if full disk is in HalfSpace                
                shape.theta1 = 0;
                shape.theta2 = pi;                                             
            elseif((y20 > (this.y2Max - r)) && (y20 <= (this.y2Max + r)))
                %1b. if part of disk is in HalfSpace  (>= half)
                %1b1. Integrate over segment in HalfSpace
                %shape.Origin    = [0,y20];
                th                = acos((y20 - this.y2Max)/r);
                shape.theta1      = pi-th;
                shape.theta2      = pi;  
            elseif((y20 < (this.y2Min + r)) && (y20 >= (this.y2Min - r)))
                %1b. if part of disk is in HalfSpace  (>= half)
                %1b1. Integrate over segment in HalfSpace
                %shape.Origin    = [0,y20];
                th                = acos((y20 - this.y2Min)/r);
                shape.theta1      = 0;
                shape.theta2      = pi-th;                                                
            %1c. if part of disk is in HalfSpace  (< half)    
            else
                exc = MException('HalfSpace_FMT:AverageDisk','case not implemented');
                throw(exc);                
            end            
            
            area               = Ball(shape); 
            dataBall.pts       = area.GetCartPts();   %PtsCart;
            
            %Shift in y2-direction
            dataBall.ptsPolLoc = Cart2PolPts(area.GetCartPts());%PtsCart);            
            dataBall.pts.y2_kv = dataBall.pts.y2_kv + y20;
                        
            [dataBall.int,dataBall.area]     = area.ComputeIntegrationVector();
                                   
            scatter(dataBall.pts.y1_kv,dataBall.pts.y2_kv,'.');            
        end                        

        %[AD,AAD] = GetAverageDensities(this,area,weights);%r,N,discCircle,weights);
        function [AD,AAD] = GetAverageDensities(this,r,N,discCircle,weights)
            %AD  - Average densities to get average densities
            %AAD - average the average densities to compute free energy
            
            %A - Loop through all points in Box
            %The first N2 iterations loop through y2. Here, we save the Pts
            %and the integration weights 
                                    
            M   = this.N1*this.N2;
            noW = size(weights,1);

            %**********************************************************
            %Integration 
            % Origin: in Box
            % Integrate: in Box      
            [refpts,ptsy2] = this.AD.GetRefY2Pts();
            shape.N                = N;
            shape.R                = r;
            
            if(strcmp(discCircle,'disc'))
                checkAAD = pi*r^2*ones(M,1);
                
                area                   = Disc(shape);
                [dataS.int,dataS.area] = area.ComputeIntegrationVector();
                dataS.pts              = Pol2CartPts(area.Pts);
                dataS.ptsPolLoc        = area.Pts;
                
                for iPts = 1:length(ptsy2)
                    dataAD(iPts) = AverageDiskPt(this,ptsy2(iPts),r,N);
                end
             elseif(strcmp(discCircle,'sphere'))
                checkAAD = 4/3*pi*r^3*ones(M,1);
                
                shape.sphere           = true;
                area                   = Disc(shape);
                [dataS.int,dataS.area] = area.ComputeIntegrationVector();
                dataS.pts              = Pol2CartPts(area.Pts);
                dataS.ptsPolLoc        = area.Pts;
                        
                for iPts = 1:length(ptsy2)
                    dataAD(iPts) = AverageDiskPt(this,ptsy2(iPts),r,N,'sphere');
                end                                

             elseif(strcmp(discCircle,'ball'))
                checkAAD = 4*pi*r^2*ones(M,1);
                
                shape.theta1    = 0;
                shape.theta2    = pi;                             

                area            = Ball(shape); 
                dataS.pts       = area.GetCartPts();%PtsCart;
            
                %Shift in y2-direction
                dataS.ptsPolLoc         = Cart2PolPts(area.GetCartPts()); %PtsCart);   
                [dataS.int,dataS.area]  = area.ComputeIntegrationVector();
                 
                for iPts = 1:length(ptsy2)
                    dataAD(iPts) = AverageBallPt(this,ptsy2(iPts),r,N);
                end
 
            else
                exc = MException('HalfSpace_FMT:GetAverageDensities','case not implemented');
                throw(exc);
            end
            
            AAD = this.AD.InterpolateAndIntegratePtsOrigin(this.Pts,dataS,weights);           
            [AD,checkAD] = InterpolateAndIntegratePtsOrigin(this,this.AD.Pts,refpts,dataS,dataAD,weights);            
            
            %**********************************************************            
            %**********************************************************
            
            %Test:
            [errAD,ierrAD] = max(abs(checkAD - sum(AD(:,:,1),2)));
            if(ierrAD <= M)
                y1err = this.Pts.y1_kv(ierrAD);
                y2err = this.Pts.y2_kv(ierrAD);
            else
                y1err = bound.Pts.y1_kv(ierrAD-M);
                y2err = bound.Pts.y2_kv(ierrAD-M);
            end
            disp(['Max. Error in AD: ', num2str(errAD),...
                          ' at y_1= ', num2str(y1err),...
                          ' at y_2= ', num2str(y2err)]);
                      
            [errAAD,ierrAAD] = max(abs(checkAAD - sum(AAD(:,:,1),2)));
            disp(['Max. Error in AAD: ', num2str(errAAD),...
                         ' at y_1= ', num2str(this.Pts.y1_kv(ierrAAD)),...
                         ' at y_2= ', num2str(this.Pts.y2_kv(ierrAAD))]);                      

            %**********************************************************                       
             
        end       
        function [X,checkSum] = InterpolateAndIntegratePtsOrigin(this,ptsOr,refpts,dataDisk,dataAD,weights)
            
            m        = length(ptsOr.y1_kv );
            mThis    = length(this.Pts.y1_kv);
            noW      = size(weights,1);
            
            X        = zeros(m,mThis,noW+1);%always include unity weight
            checkSum = zeros(m,1);
            %Go through all points in box
            for iPts = 1:m
                
                j = refpts(iPts);
                
                if(j == - 1)
                    data            = dataDisk;
                    data.pts.y2_kv  = data.pts.y2_kv + ptsOr.y2_kv(iPts);                                        
                else
                    data = dataAD(j);
                end
                
                %j   = mod(iPts,ptsOr.N2);
                %if(j==0) 
                %    j = ptsOr.N2; 
                %end 
                %*******************************
                % Origin:    in Box
                % Integrate: in Box
                %Get element of saved vector the distance corresponds with                
                if(data.area ~= 0)
                    pts = data.pts;

                    %center the new points aroung Pts.yi_kv(iPts)
                    pts.y1_kv = pts.y1_kv + ptsOr.y1_kv(iPts);

                    %Interpolate onto the new set of points
                    IP    = SubShapePts(this,pts);

                    %Finally get correct integration weight
                    X(iPts,:,1)       = data.int*IP;
                    for k = 1:noW
                        f = str2func(weights(k,:));
                        X(iPts,:,1+k) = (data.int.*f(data.ptsPolLoc.y2_kv)')*IP;                
                    end
                    checkSum(iPts)  = data.area;                                
                end
            end
        end
    end
    
    
end