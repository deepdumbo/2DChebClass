classdef (Abstract) Interval < handle
    
    properties (Access = public)
        Pts
        Diff
        Int
        Ind
        Interp
        Conv
        
        N
        polar = 'undefined';
    end
    
    methods (Abstract=true, Access=public)
        [y,J,dH,ddH] = PhysSpace(this,x);
        [x]      = CompSpace(this,y);
        
        Ind    = ComputeIndices(this);
        Diff   = ComputeDifferentiationMatrix(this);
        Interp = ComputeInterpolationMatrix(this,interp,saveBool);           
        Int    = ComputeIntegrationVector(this);
        M_conv = ComputeConvolutionMatrix(this,f,saveBool);
    end
    
    methods
        function this = Interval(N)
            this.N=N;
        end
    end
    
    methods (Access = public)
        
        function d  = GetDistance(this,pts_y1,pts_y2)                         
            d       = abs(pts_y1 - pts_y2);            
        end        
        function [Pts,Diff,Int,Ind,Interp,Conv] = ComputeAll(this,PlotRange,f)
            Ind  = ComputeIndices(this);
            Diff = ComputeDifferentiationMatrix(this);
            Int  = ComputeIntegrationVector(this);
                        
            Pts    = this.Pts;            
            
            if(nargin >= 2)
                Interp = InterpolationPlot(this,PlotRange,true);  
            end
            
            if(nargin >= 3)
                    Conv = ComputeConvolutionMatrix(this,f,true);
            end
        end                
        function [IP,yPlot] = InterpolationPlot(this,PlotRange,saveBool)
            
            xMin = CompSpace(this,PlotRange.yMin);
            xMax = CompSpace(this,PlotRange.yMax);
            xPlot = GetArray(xMin,xMax,PlotRange.N);

            yPlot = PhysSpace(this,xPlot);
            
            if(nargin == 3)            
                IP = ComputeInterpolationMatrix(this,xPlot,saveBool);           
            else
                IP = ComputeInterpolationMatrix(this,xPlot,false);           
            end
        end                         
        function InitializationPts(this)
            this.Pts.N = this.N;
            this.Pts.y = PhysSpace(this,this.Pts.x);
        end              
        function doPlots(this,V,options)
            
            nSpecies = size(V,2);
            
            if(nSpecies==1)
                nCol = 1;
            else
                nCol = 2;
            end
            
            nRows = ceil(nSpecies/nCol);
            
            for iSpecies = 1:nSpecies
                if(nSpecies>1)
                    subplot(nRows,nCol,iSpecies)
                end
                
                if( (size(V,1) == length(this.Interp.pts))  ...
                        && (length(this.Interp.pts) ~= length(this.Pts.y)) )
                    VI = V(:,iSpecies);
                else
                    VI = this.Interp.InterPol*V(:,iSpecies);
                end
                
                h = plot(this.Interp.pts,VI);
                
                if(nargin>2)                    
                    if(isfield(options,'linecolor'))
                        set(h,'Color',options.linecolor);
                    end
                    if(isfield(options,'linestyle'))
                        set(h,'LineStyle',options.linestyle);
                    end
                end
                hold on;
                plot(this.Pts.y,V,'o','MarkerEdgeColor','k','MarkerFaceColor','g');
                
                xlabel('$y$','Interpreter','Latex','fontsize',25);
                xlim([min(this.Interp.pts) max(this.Interp.pts)]);
                if(nSpecies > 1)
                    title(['Species ' num2str(iSpecies)]);
                end
                
                set(gca,'fontsize',20);
                set(gca,'linewidth',1.5);                       
            end
        end        
        function PlotGrid(this)
            hold on
            yRange = get(gca,'YLim');
            h = plot(this.Pts.y, yRange(1),'og');
            set(h,'MarkerEdgeColor','k','MarkerFaceColor','g');
            hold off
        end        
        function IP   = InterpolationMatrix_Pointwise(this,yP)
            IP = zeros(length(yP),this.N);            
            for i =1:length(yP)
                x       = CompSpace(this,yP(i));
                h       = ComputeInterpolationMatrix(this,x,false);
                IP(i,:) = h.InterPol;
            end                                
        end        
        function IP = SubShapePts(this,a_shapePts)                   
            IP = InterpolationMatrix_Pointwise(this,a_shapePts.y);                           
        end      
        function IntM = IntegrationY(this)
            
            y    = this.Pts.y;
            IntM = zeros(length(y));
            vh   = zeros(1,length(y));
            for i = 2:length(y)
                %Matrix for integral int(v(y),y=y1..Y)
                h           = y(i) - y(i-1);
                if(h == inf)   
                    h = 0; %assume value to be integrated is zero, if h = inf
                end
                vh([i-1,i]) = vh([i-1,i]) + h/2;
                
                IntM(i,:) = vh;
            end
            

        end
    end
    
    
end