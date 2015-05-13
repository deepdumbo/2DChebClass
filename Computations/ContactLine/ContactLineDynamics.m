%function ContactLineDynamics()

    AddPaths('CodePaper');            
    close all;
    
    PhysArea = struct('N',[40,40],...
                      'L1',4,'L2',2,'L2_AD',2.,...                                            
                      'y2wall',0.,...
                      'N2bound',14,'h',1,... %max(10,2*round(n(i)/6));
                      'alpha_deg',90);
                  
	SubArea      = struct('shape','Box','y1Min',-2,'y1Max',2,...
                          'y2Min',0.5,'y2Max',2.5,...
                          'N',[40,40]);

    PlotAreaCart =     struct('y1Min',-5,'y1Max',5,...
                              'y2Min',0.5,'y2Max',10.5,...
                              'N1',100,'N2',100);                              
                      
    V2Num    = struct('Fex','SplitAnnulus','N',[80,80]);
    V2       = struct('V2DV2','BarkerHendersonCutoff_2D','epsilon',1,'LJsigma',1,'r_cutoff',5);     

    FexNum   = struct('Fex','FMTRosenfeld_3DFluid',...
                       'Ncircle',1,'N1disc',50,'N2disc',50);
                   
	plotTimes = struct('t_int',[0,5],'t_n',50);

    optsNum = struct('PhysArea',PhysArea,...
                     'PlotAreaCart',PlotAreaCart,...
                     'FexNum',FexNum,'V2Num',V2Num,...
                     'SubArea',SubArea,...%'PlotAreaCart',PlotAreaCart,
                     'maxComp_y2',20,...
                     'y1Shift',0,...
                     'plotTimes',plotTimes);%0:0.05:5);

    V1 = struct('V1DV1','Vext_BarkerHenderson_HardWall','epsilon_w',0.94);%,...
                %'tau',5,'epsilon_w_end',1.0);
            
    %optsViscosity = struct('etaC',1,'zetaC',0);    
    optsViscosity = struct('etaL1',2,'zetaC',1);
    optsViscosity = struct('etaLiq',5,'etaVap',1,'zetaC',1);
    %BCwall        = struct('bc','sinHalf','tau',1);
	BCwall        = struct('bc','exp','tau',1,'u_max',0.2);

    optsPhys = struct('V1',V1,'V2',V2,...
                      'kBT',0.75,...                                               
                      'Dmu',0.0,'nSpecies',1,...
                      'sigmaS',1,...
                      'Inertial',true,'gammaS',0,...%4% 'Fext',[-1,0],...%);%,...
                      'BCWall_U',BCwall,...%);
                      'viscosity',optsViscosity);	

    config = v2struct(optsNum,optsPhys);                                    
        
    CL = ContactLineHS(config);
    CL.Preprocess(); 
    CL.ComputeEquilibrium();              
    CL.ComputeDynamics();            
    CL.PostprocessDynamics();
    
    %***********************    
    CL.optsPhys.V1.tau           = 5;
    %CL.optsPhys.V1.epsilon_w_max = 1;%epsilon_w_end
    CL.optsPhys.V1.epsilon_w_end = 1.5;%epsilon_w_end
    CL.optsNum.plotTimes.t_int(2) = 40;
    
    CL.optsPhys                  = rmfield(CL.optsPhys,'BCWall_U');
    CL.ComputeDynamics();
    CL.PostprocessDynamics();
    
    %***********************    
    CL.optsNum.plotTimes.t_int(2) = 100;
    CL.optsPhys.V1             = struct('V1DV1','Vext_BarkerHenderson_HardWall','epsilon_w',0.94);
    CL.optsPhys.ModifyEq_to_IC = struct('Mode','expY2','a0',3,'a1',3);
    CL.ComputeDynamics();
    CL.PostprocessDynamics();    
                
%end