function CheckMeanfieldConvolution(this)
    %Test Convolution at infinity      
    global PersonalUserOutput
    
     M         = this.IDC.M;    
     R         = this.IDC.R;       
     fMF       = str2func(this.optsPhys.V2.V2DV2);
     [h1,h2,a] = fMF(1,this.optsPhys.V2);

     %Convolution profile
     if(isa(this,'HalfSpace'))
         
        marky2Inf = (this.IDC.Pts.y2_kv == inf);
        PrintErrorPos(this.IntMatrV2.Conv(marky2Inf,:)*ones(M,1)- 2*a,'convolution at y2 = infinity',this.IDC.Pts.y1_kv(marky2Inf));          
         
         if(strcmp(this.optsPhys.V2.V2DV2,'Phi2DLongRange'))
             y0R = PtsCart.y2_kv-R;
             h   = conv_Phi2DLongRange(y0R);
             PrintErrorPos(h-this.IntMatrV2.Conv*ones(M,1),'Phi2DLongRange*1',this.IDC.GetCartPts);
         elseif(strcmp(this.optsPhys.V2.V2DV2,'BarkerHenderson_2D'))                 
             conv  = this.IntMatrV2.Conv(this.IDC.Pts.y1_kv==inf,:);
             y2_h  = this.IDC.GetCartPts.y2_kv(this.IDC.Pts.y1_kv==inf) - R;
             check = conv_BarkerHenderson2D(y2_h);

             PrintErrorPos(conv*ones(M,1) - check','convolution at y1 = infinity',y2_h);                 
         else
             disp('CheckMeanfieldConvolution: Case not yet implemented');
         end  
     elseif(isa(this.IDC,'InfCapillary'))
         if(PersonalUserOutput)
             figure('Position',[0 0 800 500]);
             title('Convolution of Barker-Henderson potential with rho=1');
             marky1Inf = (this.IDC.Pts.y1_kv == inf); 
             convOne   = this.IntMatrV2.Conv*ones(M,1);
             this.IDC.doPlotFLine([0 0],[this.IDC.y2Min this.IDC.y2Max],convOne); hold on;
             
             %analytical comparison
             y2_h  = this.IDC.GetCartPts.y2_kv(this.IDC.Pts.y1_kv==inf) - this.IDC.y2Min;
             check  = conv_BarkerHenderson_IC(y2_h);
             
            if(strcmp(this.optsPhys.V2.V2DV2,'BarkerHenderson_2D'))                
                plot(y2_h,check,'g','linewidth',2);                 
                PrintErrorPos(convOne - conv_BarkerHenderson_IC(this.IDC.Pts.y2_kv),'convolution',this.IDC.Pts.y2_kv);     
            else(strcmp(this.optsPhys.V2.V2DV2,'Phi2DLongRange'))
                 disp('CheckMeanfieldConvolution: Case not yet implemented');
            end
         end
     else
         disp('CheckMeanfieldConvolution: Case not yet implemented');
     end
     
    function z = conv_Phi2DLongRange(y2)
         z = this.optsPhys.V2.epsilon*(- pi^2/2 + ...
                                      + pi*atan(-y2)+...
                                      - pi*(y2)./(1+y2.^2));
    end
    function C = conv_BarkerHenderson_IC(y2)        
        C = zeros(size(y2));
        y2Min = this.IDC.y2Min;
        y2Max = this.IDC.y2Max;
        d = 2*R;
        
        mark1    = (y2 <= y2Min + d);
        C(mark1) = -6/5*pi*(y2(mark1)+d-y2Min) + ...
                   BH_Int(y2Max - y2(mark1)) - BH_Int(d);
        
        mark2    = ((y2 > y2Min + d) & (y2 < y2Max - d));
        C(mark2) = -6/5*pi*2*d + ...
                    BH_Int(y2Max-y2(mark2)) - BH_Int(d) + ...
                    BH_Int(y2(mark2)-y2Min) - BH_Int(d);
                
        mark3    = (y2 >= y2Max - d);
        C(mark3) = -6/5*pi*(y2Max-y2(mark3)+d) + ...                    
                    + BH_Int(y2(mark3)-y2Min) - BH_Int(d);                

        C = C*this.optsPhys.V2.epsilon;
    end

    function z = conv_BarkerHenderson2D(y2_h)
        Psi(y2_h < 1)  = -16/9*pi +6/5*pi*y2_h(y2_h < 1);         
        Psi(y2_h >= 1) = 4*pi*(1./(45*y2_h(y2_h >= 1).^9) - 1./(6*y2_h(y2_h >= 1).^3));
        z              = 2*a-this.optsPhys.V2.epsilon*Psi;                
    end

    function v = BH_Int(z)
        v = 2*pi/5*(-2./(9*z.^9) + 5./(3*z.^3));
    end
end