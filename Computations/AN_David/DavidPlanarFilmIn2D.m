function DavidPlanarFilmIn2D

    AddPaths();
    %Numerical Parameters    
    Phys_Area = struct('shape','HalfSpace_FMT','N',[1,50],...
                       'L1',4,'L2',5,...                   
                       'y2wall',0.,...
                       'alpha_deg',90,...
                       'h',1);
                       %'N2bound',24,
                       %%'L2_AD',5.,...
    
    Plot_Area = struct('y1Min',-7.5,'y1Max',7.5,'N1',100,'N2',100,...
                       'y2Min',0.5,'y2Max',15.5);
        
    Sub_Area = struct('shape','Box','y1Min',-1,'y1Max',1,'N',[20,20],...
                      'y2Min',0,'y2Max',2);
                                                        
	V2Num   = struct('Fex','SplitDisk','L',2,'L2',1.,'N',[20,20]);
        
    optsNum = struct('PhysArea',Phys_Area,...
                     'PlotArea',Plot_Area,'SubArea',Sub_Area,...
                     'plotTimes',0:0.1:6,...
                     'V2Num',V2Num,...
                     'maxComp_y2',20);                                           
    
    V1 = struct('V1DV1','Vext_BarkerHenderson_HardWall','epsilon_w',2.4);
    V2 = struct('V2DV2','BarkerHenderson_2D','epsilon',1,'LJsigma',1); 
    
                 
    optsPhys = struct('V1',V1,'V2',V2,...
                      'HSBulk','CarnahanStarling',...
                      'kBT',0.7,...                      
                      'Dmu',0.0,...
                      'sigmaS',1);
                  
    CL = ContactLineHS(v2struct(optsPhys,optsNum));    
    CL.Preprocess();

    plot1D_data_in2D(CL.rho1D_wg,'wg');        

    %***************
    CL.ComputeAdsorptionIsotherm(500);
    plot1D_data_in2D(CL.AdsorptionIsotherm.rho(end,:)','film');

%     optss            = CL.optsPhys;   
%     optss.Dmu = -0.01;
%     Fex_Num          = CL.optsNum.FexNum;                        
% 
%     optss.rho_iguess = CL.optsPhys.rhoLiq_sat;
%     [rho1D,params] = FMT_1D(CL.IDC,CL.IntMatrFex,optss,Fex_Num,CL.IntMatrV2.Conv);
% 
%     CL.x_eq = CL.optsPhys.kBT*log(rho1D)+CL.Vext;
%     CL.IDC.plot(CL.GetRhoEq,'contour');
% 
%     rho1D_wl         = rho1D;    
        
    function plot1D_data_in2D(rho_1D,filename)
        CL.x_eq = CL.optsPhys.kBT*log(rho_1D)+CL.Vext;
        
        figure('Position',[0 0 600 600],'color','white');
        CL.IDC.plot(CL.GetRhoEq,'contour');
        SaveFigure([filename,'_contour']);
        
        figure('Position',[0 0 600 600],'color','white');
        CL.IDC.plot(CL.GetRhoEq);
        SaveFigure([filename]);
    end
                  
end