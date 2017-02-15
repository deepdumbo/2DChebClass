  function JCP_639_2017_Fig6_DFT_vs_MD    
  
	AddPaths('JCP_639_2017');    
    close all;  
    
    Phys_Area = struct('shape','HalfSpace_FMT',...
                       'N',[1;60],'L1',4,'L2',2.,'y2wall',0.,...
                       'N2bound',16,'h',1,'L2_AD',2.,...
                       'alpha',pi/2);
    Plot_Area = struct('y1Min',-5,'y1Max',5,'N1',100,...
                       'y2Min',0.5,'y2Max',6,'N2',100);
    Fex_Num   = struct('Fex','FMTRosenfeld_3DFluid',...
                       'Ncircle',1,'N1disc',34,'N2disc',34);    
    optsNum   = struct('PhysArea',Phys_Area,...
                       'PlotArea',Plot_Area,...
                       'FexNum',Fex_Num);

    optsPhys = struct('V1',struct('V1DV1','zeroPotential'),...
                      'kBT',1,...
                      'eta',0.7151*pi/6,...
                      'sigmaS',1,... 
                      'nSpecies',1);
         
    EX = DDFT_2D(v2struct(optsPhys,optsNum));
    EX.Preprocess();    
	optsPhys.rho_iguess = optsPhys.eta*6/pi;        
    FMT_1D_Iter(EX.IDC,EX.IntMatrFex,optsPhys,optsNum.FexNum,[],{'plot','NumericsManuscript','NoCollPts','Newton','plotTex'});
    %FMT_1D_Iter(EX.IDC,EX.IntMatrFex,optsPhys,optsNum.FexNum,[],{'plot','NumericsManuscript','NoCollPts','Picard','plotTex'});
    SaveFigure('JCP_639_2017_Fig6_DFT_vs_MD');        
end