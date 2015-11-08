function Check_FMT_SumRule()

    AddPaths();

    PhysArea = struct('N',[1,80],...
                      'L1',5,'L2',4,'L2_AD',4,...
                      'y2wall',0.,...
                      'N2bound',14,'h',1,...
                      'alpha_deg',90);

    %V2Num   = struct('Fex','SplitDisk','N',[40,40]); 
    %V2 = struct('V2DV2','BarkerHenderson_2D','epsilon',1,'LJsigma',1);     
    %V2 = struct('V2DV2','ExponentialDouble','epsilon',1,'LJsigma',1); %'lambda',1
    
    V2Num   = struct('Fex','SplitAnnulus','N',[50,50]); 
    %V2      = struct('V2DV2','BarkerHendersonCutoff_2D','epsilon',1,'LJsigma',1,'r_cutoff',5); 
    %V2 = struct('V2DV2','BarkerHendersonHardCutoff_2D','epsilon',1,'LJsigma',1,'r_cutoff',5); 
    V2 = struct('V2DV2','BarkerHenderson_2D','epsilon',1,'LJsigma',1,'r_cutoff',2.5); 

    Fex_Num   = struct('Fex','FMTRosenfeld_3DFluid',...
                       'Ncircle',1,'N1disc',50,'N2disc',50);                   
 
    optsNum = struct('PhysArea',PhysArea,...
                     'FexNum',Fex_Num,...
                     'V2Num',V2Num,...
                     'maxComp_y2',-1,...
                     'y1Shift',0);

    V1 = struct('V1DV1','Vext_BarkerHenderson_HardWall','epsilon_w',0.9);%1.3);%1.375);%1.25)s;
    
    
%    V2 = struct('V2DV2','Exponential','epsilon',1.5,'LJsigma',1); 

    optsPhys = struct('V1',V1,...
                      'V2',V2,'Dmu',0.0,...    
                      'kBT',0.75,'eta',0.4257,...%'kBT',0.75,'Dmu',0.0,...
                      'nSpecies',1,...
                      'sigmaS',1);      

    config = v2struct(optsNum,optsPhys);                            
    
    config.optsPhys.V1.epsilon_w = 0.855;
    CheckConfig(config);
    
 %   config.optsNum.V2Num  = struct('Fex','SplitAnnulus','N',[80,80]); 
%    config.optsPhys.V2    = struct('V2DV2','BarkerHenderson_2D','epsilon',1,'LJsigma',1,'r_cutoff',2.5); 
%    CheckConfig(config);
    
    config.optsNum.V2Num  = struct('Fex','SplitAnnulus','N',[80,80]); 
    %config.optsPhys.V2    = struct('V2DV2','BarkerHendersonCutoff_2D','epsilon',1,'LJsigma',1,'r_cutoff',2.5); 
    config.optsPhys.V2    = struct('V2DV2','BarkerHendersonCutoff_2D','epsilon',1,'LJsigma',1,'r_cutoff',5.0); 
    CheckConfig(config);
            
	config.optsNum.V2Num  = struct('Fex','SplitDisk','N',[80,80]); 
    config.optsPhys.V2    = struct('V2DV2','BarkerHenderson_2D','epsilon',1,'LJsigma',1); 
    CheckConfig(config);
    
    config.optsNum.V2Num   = struct('Fex','ConstShortRange','N',[30,30]);
	config.optsPhys.V2     = struct('V2DV2','ConstShortRange','epsilon',1,'LJsigma',1,'lambda',1.5);                                 
    CheckConfig(config);
    
    config.optsNum.V2Num   = struct('Fex','ConstShortRange','N',[30,30]);
	config.optsPhys.V2     = struct('V2DV2','ConstShortRange','epsilon',1,'LJsigma',1,'lambda',1.5);                                 
    CheckConfig(config);
    
    
    %epw = 0.9;%[0.75,0.8,0.85,0.9,0.95];
%    config.optsPhys.V1.epsilon_w = 0.9;%    1.0;%1.25;%0.55;% 1.375; %0.7;%1.25;%375;%25; %375;%47;%1.25;
                
%    N  = 100;%:10:50;
%    NS = 100;%10:10:40;   
%    res = DataStorage([],@ComputeErrorContactDensityMatrix,v2struct(N,NS,config),[]);
    
    function res = ComputeErrorContactDensityMatrix(in,h)
        config = in.config;
        N      = in.N;
        NS     = in.NS;
        
        error_wg    = zeros(length(N),length(NS));
        error_wl    = zeros(length(N),length(NS));
        
        res.N  = repmat(N',1,length(NS));
        res.NS = repmat(NS,length(N),1);

        for i = 1:length(N)
            config.optsNum.PhysArea.N = [1,N(i)];
            for j = 1:length(NS)
                config.optsNum.V2Num.N       = [NS(j),NS(j)];
                config.optsNum.FexNum.N1disc = NS(j);
                config.optsNum.FexNum.N2disc = NS(j);

                [error_wl(i,j),error_wg(i,j)] = CheckConfig(config);                

                clear('CL');
            end
        end
        res.error_wl = error_wl;
        res.error_wg = error_wg; 
    end     
    function [error_wl,error_wg] = CheckConfig(config)
        CL = ContactLineHS(config);        
        CL.Preprocess();    

        [~,~,params] = CL.Compute1D('WL');
        error_wl = params.contactDensity_relError;

        [~,~,params] = CL.Compute1D('WG');
        error_wg = params.contactDensity_relError;
    end
    
end