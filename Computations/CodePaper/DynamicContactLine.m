function DynamicContactLine()

    AddPaths('CodePaper');            
    
    PhysArea = struct('N',[20,20],...
                      'L1',4,'L2',2,'L2_AD',2.,...
                      'y2wall',0.,...
                      'N2bound',10,'h',1,... %max(10,2*round(n(i)/6));
                      'alpha_deg',90);
                  
    PlotAreaCart = struct('y1Min',-10,'y1Max',10,...
                          'y2Min',0.5,'y2Max',10,...
                          'N1',100,'N2',100);
	SubArea      = struct('shape','Box','y1Min',-2,'y1Max',2,...
                          'y2Min',0.5,'y2Max',2.5,...
                          'N',[20,20]);
                      
    V2Num    = struct('Fex','SplitAnnulus','N',[80,80]);
    V2       = struct('V2DV2','BarkerHendersonCutoff_2D','epsilon',1,'LJsigma',1,'r_cutoff',5);     

    FexNum   = struct('Fex','FMTRosenfeld_3DFluid',...
                       'Ncircle',1,'N1disc',50,'N2disc',50);

    optsNum = struct('PhysArea',PhysArea,...
                     'FexNum',FexNum,'V2Num',V2Num,...
                     'PlotAreaCart',PlotAreaCart,'SubArea',SubArea,...
                     'maxComp_y2',20,...
                     'y1Shift',0,...
                     'plotTimes',0:0.05:5);

    V1 = struct('V1DV1','Vext_BarkerHenderson_HardWall','epsilon_w',0.94,...
                'tau',1,'epsilon_w_max',1.2);    

    optsPhys = struct('V1',V1,'V2',V2,...
                      'kBT',0.75,...                                               
                      'Dmu',0.0,'nSpecies',1,...
                      'sigmaS',1);

    config = v2struct(optsNum,optsPhys);                                
    
    N = 20:10:70;
    
    for i = 1:length(N)
        config.optsNum.PhysArea.N = N(i)*[1,1];
        
        CL = ContactLineHS(config);
        CL.Preprocess(); 
        CL.ComputeEquilibrium();              
        CL.ComputeDynamics();
        CL.PostprocessDynamics();

       % CL.PlotDynamics();
        
        close all;
        clear all;
    end

end