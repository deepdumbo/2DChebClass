function [optsNum,optsPhys] = DDFT_DiffusionBox_2Phase_Sat_2()
    
    Phys_Area = struct('shape','Box','N',[30,40],...
                       'y1Min',0,'y1Max',10,...
                       'y2Min',-10,'y2Max',10);
    
    Plot_Area = struct('y1Min',0,'y1Max',10,'N1',100,...
                       'y2Min',-10,'y2Max',10,'N2',100);
        
    Sub_Area = struct('shape','Box','N',[20,20],...
                      'y1Min',0,'y1Max',5,...
                      'y2Min',-10,'y2Max',10);
                  
    FexNum = struct('Fex','Meanfield');                  
        
    optsNum = struct('PhysArea',Phys_Area,...
                     'PlotArea',Plot_Area,...
                     'SubArea',Sub_Area,...
                     'V2Num',FexNum,...
                     'plotTimes',0:0.5:75);                     

    V1 = struct('V1DV1','Vext_Cart_Capillary_3',...
                      'V0',0.0,'epsilon_w',1,'y10',10,'y20',0,'tau',1,...
                      'epsilon_w_end',0.0);
                  
    V2 = struct('V2DV2','Phi2DLongRange','epsilon',1);                 

    optsPhys = struct('V1',V1,'V2',V2,...
                      'HSBulk','CarnahanStarling',...
                      'kBT',0.7,'Dmu',0);
    
    AddPaths();
    EX     = DDFT_2D(v2struct(optsPhys,optsNum));
    EX.Preprocess();
    EX.ComputeEquilibrium(EX.optsPhys.rhoLiq_sat);
    EX.ComputeDynamics();    
end                 

