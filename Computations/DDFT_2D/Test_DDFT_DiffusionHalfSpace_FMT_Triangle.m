function Test_DDFT_DiffusionHalfSpace_FMT_Triangle(doHI)

    if(nargin==0)
        doHI = false;
    end

    Phys_Area = struct('shape','HalfSpace_FMT','N',[20;20],'L1',2,'L2',2, ...
                       'y2wall',0,'N2bound',10,'h',1,'L2_AD',1,'alpha_deg',90);                    
    
    Plot_Area = struct('y1Min',-5,'y1Max',5,'N1',100,...
                       'y2Min',0.5,'y2Max',5,'N2',100);
                   
    Fex_Num   = struct('Fex','FMTRosenfeld_3DFluid',...
                       'Ncircle',10,'N1disc',10,'N2disc',10);
                   
    HI_Num    = struct('N',[10;10],'L',2,'HI11','noHI_2D','HI12','RP12_2D', ...
                      'HIPreprocess', 'RotnePragerPreprocess2D');  
    
    tMax = 0.25;
    
    optsNum = struct('PhysArea',Phys_Area,...
                     'PlotArea',Plot_Area,...
                     'FexNum',Fex_Num,...                    
                     'plotTimes',0:tMax/100:tMax);
    
	sigmaS  = 1;
    sigmaHS = 0.5;
    
    V1       = struct('V1DV1','V1_Triangle',...
                      'V0',0.01,'V0add',3,'tau',0.1,'sigma1Add',0.5,'sigma2Add',0.5, ...
                      'y10',-1,'y20',1.5,'y11',1,'y21',2,'y12',0,'y22',2.5); 

    HI       = struct('sigmaS',sigmaS,'sigmaHS',sigmaHS);
    
    optsPhys = struct('V1',V1,  ...                                            
                      'kBT',1,'mS',1,'gammaS',1, ...
                      'nParticlesS',10,'sigmaS',sigmaS);

    if(doHI)
        optsPhys.HI = HI;
        optsNum.HINum = HI_Num;
    end
                  
    optsPlot.doDDFTPlots=true;
                      
    AddPaths();
    EX     = DDFT_2D(v2struct(optsPhys,optsNum));
    EX.Preprocess();
    EX.ComputeEquilibrium();
    EX.ComputeDynamics();       

end                 

