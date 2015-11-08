function [EX,res] = DDFT_DiffusionPolarInfinity_Case1()        

    Phys_Area = struct('shape','InfDisc','N',[20,20],...
                       'y1Min',0,'y1Max',inf,'L',4,...
                       'y2Min',0,'y2Max',2*pi);

    Plot_Area = struct('y1Min',0,'y1Max',3,'N1',100,...
                       'y2Min',0,'y2Max',2*pi,'N2',100);
	
	V2Num = struct('Fex','Meanfield','N',[20,20],'L',1);                      
    
    optsNum = struct('PhysArea',Phys_Area,...
                     'PlotArea',Plot_Area,...
                     'plotTimes',0:0.2:5,...
                     'V2Num',V2Num);

    V1       = struct('V1DV1','Vext_Cart_2',...
                      'V0',0.1,'grav',2,'a',[0.1,0.1]);
    V2       = struct('V2DV2','Gaussian','alpha',2,'epsilon',-0.06);
    
    optsPhys = struct('V2',V2,'V1',V1,...
                     'kBT',0.7,...
                     'nParticlesS',50);                                          
                 
    AddPaths();
    EX   = DDFT_2D(v2struct(optsPhys,optsNum));
    EX.Preprocess();
    EX.ComputeEquilibrium([],struct('solver','Newton')); 
    EX.ComputeDynamics();
   
    if( (nargin < 3) || ...
        (isfield(optsPlot,'doDDFTPlots') && optsPlot.doDDFTPlots) || ...
        (isfield(optsNum,'doPlots') && optsNum.doPlots) )
        res.fig_handles = EX.PlotDynamics();
    end

	%[EX,res] = DDFTDynamics(optsPhys,optsNum);
end
    