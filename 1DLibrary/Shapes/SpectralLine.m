classdef SpectralLine < Spectral
    
    properties
        yMin
        yMax
    end
    
    methods
        function this = SpectralLine(Geometry)
            this@Spectral(Geometry.N);
            this.yMin = Geometry.yMin;
            this.yMax = Geometry.yMax;
            
            this.polar = 'cart';
            
            InitializationPts(this);  
        end
        
    end
    
    
   methods (Access = public)
        function [y,dy,dx,ddx,dddx,ddddx] = PhysSpace(this,x)
            [y,dy,dx,ddx,dddx,ddddx] = LinearMap(x,this.yMin,this.yMax);
        end
        function xf = CompSpace(this,y)
            xf  = InvLinearMap(y,this.yMin,this.yMax);
        end        
        
        
        function M_conv = ComputeConvolutionMatrix(this,f,shapeParams,parent)
            %{
            Strategy:
            We wish to compute \int_D(x) f(x-y) g(y) dy, for some domain D
            (e.g. disc, annulus) centred at x.
            Let z = y-x then dy = dz, y = x + z and 
            y \in D(x) => z + x \in D(x) or z \in D(0) and we get
            \int_D(0) f(-z) g(x+z) dz
            
            In matlab this is
            M_conv = Int_D(0) .* f(-z) .* IP_D(x)
            %}
            
            if((nargin == 4) && parent)
                M_conv = ComputeConvolutionMatrix@Spectral(this,f);
                return;
            end
            
            disp('Computing Convolution matrices...'); 
            
            if(isfield(shapeParams,'yMin') && isfield(shapeParams,'yMax'))
                % two closed intervals
                nSubShapes = 2;
                factor = [-1;1];

                yMin = shapeParams.yMin;
                yMax = shapeParams.yMax;

                geom1.N = shapeParams.N;
                geom1.yMin = -yMin;
                geom1.yMax = -yMax;
                subShape(1) = SpectralLine(geom1);

                geom2.N = shapeParams.N;
                geom2.yMin = yMin;
                geom2.yMax = yMax;
                subShape(2) = SpectralLine(geom2);

                %xRange   = (-1:0.05:1)';
                
            elseif(isfield(shapeParams,'yMax'))
                       
                % one closed interval
                nSubShapes = 1;
                factor = 1;
                
                geom.N    = shapeParams.N;
                geom.yMin = -abs(shapeParams.yMax);
                geom.yMax = abs(shapeParams.yMax);
                subShape  = SpectralLine(geom);

                %xRange    = (-1:0.05:1)';
                
            else
                
                % whole interval
                M_conv = ComputeConvolutionMatrix@Spectral(this,f);
                return;
                
            end
            
            
            % initialize matrix
            fP = f(-subShape(1).Pts.y);

            nDim = length(size(fP));
            if(nDim>2)
                fP_old = fP;
                fP = reshape(fP,size(fP,1),[]);
            end

            nf = size(fP,2);
            M_conv = zeros(this.N,this.N,nf);  
           
            for iSubShape = 1:nSubShapes
             
                % Integration and interpolation on D(0)
                Int_i    = subShape(iSubShape).ComputeIntegrationVector();
                
                % f(-z)
                fP = f(-subShape(iSubShape).Pts.y);
                
                if(nDim>2)
                    fP_old = fP;
                    fP = reshape(fP,size(fP,1),[]);
                end
                IntRep = Int_i(ones(1,nf),:);
                

                %hw = waitbar(0,'Computing Convolution matrices...');

                for i=1:this.N

                 %   waitbar(i/this.N,hw);

                    Y0 = this.Pts.y(i); 

                    % Compute points in D(x) = D(y0))
                    subConvShapePts.y = subShape(iSubShape).Pts.y+Y0;
                    
                    % and the interpolation onto D(x) from the full domain
                    IP          = SubShapePts(this,subConvShapePts);
                   
                    IntFTemp = (IntRep.*fP.')*IP;

                    if(size(IntFTemp,1)>1)
                        IntFTemp = IntFTemp.';
                    end
                    
                    M_conv(i,:,:) = squeeze(M_conv(i,:,:)) + factor(iSubShape)*IntFTemp;

                end

                %close(hw);
                
                M_conv(isnan(M_conv)) = 0;
                            
                if(nDim>2)
                    nfTemp = size(fP_old);
                    nfTemp = nfTemp(2:end);
                    M_conv = reshape(M_conv,[ this.N, this.N, nfTemp ]);
                end

            end % subshape loop
                
        end % convolution

        
        
        function Eta = ComputeFMTMatrices(this,opts)
            y = this.Pts.y;
            
            sigma = opts.sigma;
            
            % FIX THIS FOR MULTIPLE SPECIES
            sigma = sigma(1);
            
            if(isfield(opts,'N'))
                N = opts.N;
            else
                N = 100;
            end
                
            F = zeros(this.N,this.N);
            B = zeros(this.N,this.N);
            
            for iY = 1:length(y)
                
                % forwards integration
                geom.yMin = y(iY); geom.yMax = min(y(iY)+sigma,this.yMax); geom.N = N;
                
                aLine = SpectralLine(geom);
                Int  = aLine.ComputeIntegrationVector;
                
                x = this.CompSpace(aLine.Pts.y);
                
                Interp = this.ComputeInterpolationMatrix(x,false);
                InterPol = Interp.InterPol;
                InterPol(InterPol==inf) = 0;
                
                F(iY,:) = Int*InterPol;
                
                % backwards integration
                geom.yMin = max(y(iY)-sigma, this.yMin); geom.yMax = y(iY); geom.N = N;
                
                aLine = SpectralLine(geom);
                Int  = aLine.ComputeIntegrationVector;
                
                x = this.CompSpace(aLine.Pts.y);
                
                Interp = this.ComputeInterpolationMatrix(x,false);
                InterPol = Interp.InterPol;
                InterPol(InterPol==inf) = 0;
                
                B(iY,:) = Int*InterPol;
                
            end
            
            Eta.F = F;
            Eta.B = B;
                
        end

        
        
    end
    
end