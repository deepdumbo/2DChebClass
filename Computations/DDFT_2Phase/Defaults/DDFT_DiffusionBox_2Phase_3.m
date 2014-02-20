function [optsNum,optsPhys] = DDFT_DiffusionBox_2Phase_3()

    %Numerical Parameters    
    Phys_Area = struct('y1Min',0,'y1Max',10,'N',[20,20],...%60
                       'y2Min',0,'y2Max',10);%30
    
    Plot_Area    = Phys_Area; 
    Plot_Area.N1 = 100; Plot_Area.N2 = 100;
    
    %Sub_Area  = Phys_Area;
    Sub_Area = struct('y1Min',5,'y1Max',10,'N',[35,35],...
                      'y2Min',0,'y2Max',5);    
        
    optsNum = struct('PhysArea',Phys_Area,...
                     'PlotArea',Plot_Area,'SubArea',Sub_Area,...
                     'DDFTCode','DDFT_DiffusionBox_2Phase',...
                     'plotTimes',0:0.2:3);                            
                 
    V1 = struct('V1DV1','Vext_Cart_2Species_1',...
                      'V0',0.02,'grav',2,'y10',5,'y20',5,'tau',1,...
                     'epsilon_w1',1,'epsilon_w1_end',0,...
                     'epsilon_w2',0,'epsilon_w2_end',1);
                 
    V2 = struct('V2DV2','Phi2DLongRange','alpha',2,'epsilon',1);
                      
    optsPhys = struct('V1',V1,'V2',V2,...
                     'kBT',0.7,...
                     'HSBulk','MuCarnahanStarling',...                     
                     'nParticlesS',40);

    %Run File
    AddPaths();
    f = str2func(optsNum.DDFTCode);
    f(optsPhys,optsNum);                 
                 
end                 

