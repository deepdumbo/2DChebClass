function [EX,res] = DDFT_DiffusionWedge_Case1()
    %Numerical Parameters    
    Phys_Area = struct('shape','Wedge','N',[40,30],...
                       'y1Min',0,'y1Max',6,'L1',2,...
                       'y2Min',-pi*2/3,'y2Max',pi*2/3);
                   
    Plot_Area       = Phys_Area; 
    Plot_Area.N1    = 100; 
    Plot_Area.N2    = 100; 
    Plot_Area.y1Max = 3;
    
    Sub_Area = struct('shape','Wedge','N',[20 20],...    
                      'y1Min',1,'y1Max',3,...
                      'y2Min',-pi*1/3,'y2Max',pi*1/3);

    V2Num = struct('Fex','Meanfield','N',[20,20],'L',1);                                        
        
    optsNum = struct('PhysArea',Phys_Area,...
                     'PlotArea',Plot_Area,'SubArea',Sub_Area,...
                     'V2Num',V2Num,...
                     'plotTimes',0:0.1:2);
                 
    V1       = struct('V1DV1','Vext_Cart_2','V0',0.1,'grav',-1,...
                       'a',[0.1,0.1],'b',[1 0],'y10',1,'y20',0);
    
    V2 = struct('V2DV2','Gaussian','alpha',2,'epsilon',-0.06);
                      
    optsPhys = struct('V1',V1,'V2',V2,...
                     'kBT',0.7,'nParticlesS',50);

    
	[EX,res] = DDFTDynamics(optsPhys,optsNum);

end