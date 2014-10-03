function EX = Test_DDFT_DiffusionHalfSpace_FMT_HIWall(doHI,doHIWall)

    if(nargin<1)
        doHI     = false;
        doHIWall = false;
    elseif(nargin<2)
        doHIWall = false;
    end

    Phys_Area = struct('shape','HalfSpace_FMT','N',[20;20],'L1',2,'L2',2, ...
                       'y2wall',0,'N2bound',10,'h',1,'L2_AD',1,'alpha_deg',90);                    
    
    Plot_Area = struct('y1Min',-5,'y1Max',5,'N1',100,...
                       'y2Min',0.5,'y2Max',5,'N2',100);
                   
    Fex_Num   = struct('Fex','FMTRosenfeld_3DFluid',...
                       'Ncircle',10,'N1disc',10,'N2disc',10);
                   
    HI_Num    = struct('N',[20;20],'L',2,'HI11','noHI_2D','HI12','RP12_2D', ...
                      'HIPreprocess', 'RotnePragerPreprocess2D');  
    
    tMax = 0.15;
    
    optsNum = struct('PhysArea',Phys_Area,...
                     'PlotArea',Plot_Area,...
                     'FexNum',Fex_Num,...                    
                     'plotTimes',0:tMax/100:tMax);
    
	sigmaS  = 1;
    sigmaHS = 0.5;
    
    V1       = struct('V1DV1','V1_Triangle',...
                      'V0',0.01,'V0add',3,'tau',0.1,'sigma1Add',0.5,'sigma2Add',0.5, ...
                      'y10',-1,'y20',1.5,'y11',1,'y21',2,'y12',0,'y22',2.5); 

    HI       = struct('sigmaS',sigmaS,'sigmaHS',sigmaHS,'wallPos',Phys_Area.y2wall);
    
    optsPhys = struct('V1',V1,  ...                                            
                      'kBT',1,'mS',1,'gammaS',1, ...
                      'nParticlesS',20,'sigmaS',sigmaS);

    if(doHI || doHIWall)
        optsPhys.HI = HI;
    end
    
    if(doHI)
        optsNum.HINum = HI_Num;
    end
    
    if(doHIWall)
        optsNum.HINum.Wall = 'DiffusionCoefficientWall';
        %optsNum.HINum.Wall = 'NoDiffusionCoefficientWall';
    end
                  
    optsPlot.doDDFTPlots=true;

    EX = DDFTDynamics(optsPhys,optsNum,optsPlot);
    
end                 


