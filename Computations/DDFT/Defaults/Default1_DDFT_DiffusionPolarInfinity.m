function [optsNum,optsPhys] = Default1_DDFT_DiffusionPolarInfinity()        

    Phys_Area = struct('y1Min',0,'y1Max',inf,'L1',4,'N1',20,...
                       'y2Min',0,'y2Max',2*pi,'N2',20);

    Plot_Area = struct('y1Min',0,'y1Max',3,'N1',100,...
                       'y2Min',0,'y2Max',2*pi,'N2',100);
    
    optsNum = struct('PhysArea',Phys_Area,...
                     'PlotArea',Plot_Area,...
                     'plotTimes',0:0.2:5,...
                     'DDFTCode','DDFT_DiffusionPolarInf');

    V1       = struct('V1DV1','Vext_Pol_1','V0',0.1,'grav',2);
    V2       = struct('V2DV2','Gaussian','alpha',2,'epsilon',-0.06);
    optsPhys = struct('V2',V2,'V1',V1,...
                     'kBT',0.7,...
                     'nParticlesS',50);                                          
    AddPaths();
    f = str2func(optsNum.DDFTCode);
    f(optsPhys,optsNum);                 
end
    