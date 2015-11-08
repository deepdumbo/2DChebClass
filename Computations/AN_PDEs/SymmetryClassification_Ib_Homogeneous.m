function SymmetryClassification_Ib_Homogeneous()
%%  Solution I.b for a linear shear flow

%% ODE to solve
% 
% $$k(k-1)f+2y(1-k)f'+(1-y^2)f''=h(y-t)$$
%

    global dirData
    AddPaths();
    ChangeDirData([dirData filesep 'SymmetryClassification'],'ORG');

    %% Parameters
    k  = 1.;
    %% Initialization
    %     
        
    shapeBox = struct('y1Min',-0.5,'y1Max',0.5,'N',[50,50],...
                      'y2Min',0.1,'y2Max',1);
    plotBox  = shapeBox;
    plotBox.N = [100,100];
    BX        = Box(shapeBox);
    Geometry = struct('R_in',0.,'R_out',2,...
                      'th1',0,'th2',pi,'N',[10,20]);
    
    BX        = Wedge(Geometry);
    BX.ComputeAll();
    BX.ComputeInterpolationMatrix((-1:0.02:1)',(-1:0.02:1)',true,true);
    Pts = BX.GetCartPts();
    x   = Pts.y1_kv;  y = Pts.y2_kv;    
   % BX.plot(p,'contour',struct('clabel',false,'linecolor','k'));    pbaspect([1 1 1]);  
  %  u = BX.Diff.Dy2;
  %  v = -BX.Diff.Dy1;
  
  
    if(k==0)
        psi = atan(x./y);        
        u = -x./(x.^2+y.^2);
        v = -y./(x.^2+y.^2);
    else
        A1 = 1; A2 = 0;
        psi = real(A1*(x+1i*y).^k + A2*(x-1i*y).^k);
        u   = real( A1*1i*k*(x+1i*y).^(k-1) -  A2*1i*k*(x-1i*y).^(k-1)  );
        v   = real( -A1*k*(x+1i*y).^(k-1) +  A2*k*(x-1i*y).^(k-1)  );        
        u(isnan(u))  = 0;
        v(isnan(v))  = 0;
    end
    psi = y.*erf(x./y);    
    psi(y==0) = 0;
    u         = erf(x./y) - 2/sqrt(pi)*x./y.*exp(-(x./y).^2);
    v         = -2/sqrt(pi)*exp(-(x./y).^2);
    
    
    f1 = figure('Position',[0 0 800 450],'color','white');
    BX.plotFlux([u;v],[],[],2,'k');%'contour',struct('clabel',false,'linecolor','k'));  
    hold on;
    BX.plot(psi,'contour',struct('clabel',false,'linecolor','k'));    
    xlim([-2,2]);
    ylim([0,2]);
    pbaspect([2 1 1]);  
   
    xlabel('$x$','Interpreter','Latex','fontsize',25);
    ylabel('$y$','Interpreter','Latex','fontsize',25);      
    
    print2eps([dirData filesep 'SelfSimilarSolution_Ib_Hom'],f1);
    saveas(f1,[dirData filesep 'SelfSimilarSolution_Ib_Hom.fig']);
    
    %% ****************************************************************
    shapeBox = struct('y1Min',-5,'y1Max',5,'N',[50,70],...
                      'y2Min',0.0,'y2Max',10);
    plotBox  = shapeBox;
    plotBox.N = [100,100];
                                    
    %BX       = Box(shapeBox);    
    %[PtsBx]  = BX.ComputeAll(plotBox);
    
    shapeHS  = struct('L1',3,'L2',3,'N',[50,70]);
    HS       = HalfSpace(shapeHS);
    [PtsHS]  = HS.ComputeAll(plotBox);
    
    y1       = PtsHS.y1_kv;
    y2       = PtsHS.y2_kv;
    
    F = RHS(y1,y2);
    HS.plot(F,'SC');
    
   
          
    %% Right hand side of ODE    
end
