function ContactLineBinaryFluid
    close all;    
    AddPaths('DIBinaryPaper');            

    PhysArea = struct('N',[50,40],'y2Min',0,'y2Max',20,...
                      'L1',7,'IntInterval',[-10,10]);%,'NBorder',[30,200,30,200]);

    PlotArea = struct('y1Min',-15,'y1Max',15,'N1',80,'N2',80);   
    SubArea  = struct('shape','Box','N',[60,60],...
                      'y1Min',-5,'y1Max',5,'y2Min',0,'y2Max',10);   	
                  
    %optsSolv = struct('noIterations',40,'lambda',0.8,'Seppecher_red',1);

    optsNum  = v2struct(PhysArea,PlotArea);                   	

    optsPhys = struct('thetaEq',pi/2,...       
                       'theta',90*pi/180,...
                       'Cak',0.01,'Cn',1,...
                       'UWall',1,...                       
                       'l_diff',0.5,...%'mobility',10,...
                       'nParticles',0);

    parameters.config = v2struct(optsPhys,optsNum);
    parameters.Cak   = [0.005;0.01];%(0.005:0.0025:0.01)';
    parameters.y2Max = 18:2:24;%(16:2:24);            
    parameters.l_d   = 1:0.25:3.0;%0.25:0.25:2.5;                    
	%parameters.l_d   = 2.25:0.25:3.0;%0.25:0.25:2.5;                    

    [dataM,~,res] = DataStorage('NumericalExperiment',@RunNumericalExperiment,parameters,[],[]);
    dataN = Rescale(dataM);clear('dataM');
    
    
    cols = {};%{'g','b','c','k','r'};  
    nocols = 9;%length(cols);
    for iC = 1:nocols
        cols{end+1} = (nocols-iC)/nocols*[1 1 1];
	end
    %cols = {'g','b','c','k','r'};  nocols = length(cols);
	syms = {'<','d','s','o','>'};  nosyms = length(syms);            
    lines = {'-','--',':','.','-.'}; nolines = length(lines);                
    
    %Plot3D(dataN,1,4,parameters.config);
    PlotAsymptoticInterfaceResults(dataN,1,[],struct('i',1,'val','mu'),{'mu_y1'});    
    
    PlotAllAsymptotics({'y2Max'},parameters);
    PlotAllAsymptotics({'Cn'},parameters);
        
    PlotAsymptoticResults(dataN,'d',{'mu_y2'},'$d$ at $y_2 = 0$');    
    SaveFigures(dataN,res,parameters);
     
  %  PlotAsymptoticInterfaceResults(dataN,1,'theta',{'IsoInterface'},'\theta');        
    PlotAsymptoticInterfaceResults(dataN,[],[],'kappa',{'IsoInterface'},'\kappa');    
    PlotAsymptoticInterfaceResults(dataN,1,[],'mu',{'IsoInterface'},'\mu');
    PlotAsymptoticInterfaceResults(dataN,1,[],'mu_ddy2',{'IsoInterface'},'\frac{\partial^2\mu}{\partial y_2^2}');
    PlotAsymptoticInterfaceResults(dataN,1,[],'p',{'IsoInterface'},'p');
    PlotAsymptoticInterfaceResults(dataN,1,[],'kappa_Cakmu',{'IsoInterface'},'\kappa/(Ca_k\mu)');        
	PlotAsymptoticInterfaceResults(dataN,1,[],'mu',{'mu_y2'},'\mu');        
    PlotAsymptoticInterfaceResults(dataN,1,[],'mu_ddy2',{'mu_y2'},'\frac{\partial^2\mu}{\partial y_2^2}');                
    
                    
   % CompareAllData(dataM,1);
   %CompareAllData(dataM,2);
   %CompareAllData(dataM,3);
    
    %dataM{l_diff}(Cak,y2Max)
    
    function Plot3D(dataN,i_Cak,i_y2Max,config)
        config.optsPhys.l_d = 1;
        config.optsNum.PhysArea.y2Max = dataN{1}(i_Cak,i_y2Max).y2Max;
        DI = DiffuseInterfaceBinaryFluid(config);        
        DI.Preprocess();                
        
        Ca = dataN{1}(i_Cak,i_y2Max).Ca;            
        title(['Ca = ',num2str(Ca)]);
        for j0 = 1:length(dataN)
            
            
            %Cn    = dataM{j0}(i_Cak,j2).Cn;            
            DI.IDC.plot(dataN{j0}(i_Cak,i_y2Max).mu);  hold on;          
        end                 
                    
    end
    
    function PlotAllAsymptotics(opts,parameters)
        if(IsOption(opts,'y2Max'))
            plot_func = @PlotAsymptoticResults_Y2Max;
            name = 'y2Max';
        elseif(IsOption(opts,'Cn'))
            plot_func = @PlotAsymptoticResults;
            name = 'Cn';
        end
        
        defaultOpts = {'noLegend','noNewFigure'};
        
        figure('Position',[0 0 1500 1500],'color','white');
        subplot(3,3,1);
        plot_func(dataN,'muMinusInf',defaultOpts);
        subplot(3,3,2);        
        plot_func(dataN,'muPlusInf',defaultOpts);
        subplot(3,3,3);
        plot_func(dataN,'stagnationPointY2',defaultOpts)
        subplot(3,3,4);
        plot_func(dataN,'hatL',[{'IsoInterface'},defaultOpts]);
        subplot(3,3,5);
        plot_func(dataN,'muMaxAbs',defaultOpts);
        subplot(3,3,6);
        plot_func(dataN,'pMin',defaultOpts);
        subplot(3,3,7);
        plot_func(dataN,'pMax',defaultOpts);
        subplot(3,3,8);
        plot_func(dataN,'d',[{'mu_y2'},defaultOpts]);
        
        SaveFigure(['AsymptoticResults_',name],parameters);
    end
   
    function SaveFigures(dataN,res,params) 
        params.comment = 'run by ContactLineBinaryFluid.m';
        [~,fn]   = fileparts(res.Filename);        
        filename = ['NumericalExperiment' filesep fn '_'];
        
        PlotAsymptoticResults(dataN,'mu_max_y20',{'mu_y2','noLegend'});    
        SaveFigure([filename, 'wall_max_mu'],params);      
        
        PlotAsymptoticResults(dataN,'mu_dy1_max_y20_sqrtCn',{'mu_y2','noLegend'});    
        SaveFigure([filename, 'wall_max_mudy1_sqrtCn'],params);        
        
        PlotAsymptoticResults(dataN,'mu_ddy2_max_y20_sqrtCn',{'mu_y2','noLegend'});
        SaveFigure([filename, 'wall_max_muddy2_sqrtCn'],params);        
        
        PlotAsymptoticInterfaceResults(dataN,[],[],'u_n',{'IsoInterface','noLegend'},'u_n');    
        plot([0,24],[0 0],'k--','linewidth',1.5);
        SaveFigure([filename, 'Interface_u_n'],params);        
        
        PlotAsymptoticInterfaceResults(dataN,[],[],'u_t',{'IsoInterface','noLegend'},'u_t');    
        plot([0,24],[0 0],'k--','linewidth',1.5);
        SaveFigure([filename, 'Interface_u_t'],params);        
        
        PlotAsymptoticInterfaceResults(dataN,[],[],'flux_n',{'IsoInterface','noLegend'},'j_n');    
        plot([0,24],[0 0],'k--','linewidth',1.5);
        SaveFigure([filename, 'Interface_flux_n'],params);        
        
        PlotAsymptoticInterfaceResults(dataN,[],[],'flux_t',{'IsoInterface','noLegend'},'j_t');    hold on;
        plot([0,24],[0 0],'k--','linewidth',1.5);
        SaveFigure([filename, 'Interface_flux_t'],params);                
        
        PlotAsymptoticInterfaceResults(dataN,[],[],'mu',{'mu_y2','noLegend'},'\mu');                
        SaveFigure([filename, 'wall_mu'],params);
        
        PlotAsymptoticInterfaceResults(dataN,[],[],'mu_dy1',{'mu_y2','noLegend'},'\frac{\partial\mu}{\partial y_1}');                        
        SaveFigure([filename, 'wall_mu_dy1'],params);
        
        PlotAsymptoticInterfaceResults(dataN,[],[],'mu_ddy2',{'mu_y2','noLegend'},'\frac{\partial^2\mu}{\partial y_2^2}');                        
        SaveFigure([filename, 'wall_mu_ddy2'],params);
        
        PlotAsymptoticResults(dataN,'hatL',{'IsoInterface','noLegend'}); 
        SaveFigure([filename, 'hatL'],params);
                       
        PlotAsymptoticResults(dataN,'stagnationPointY2',{'noLegend'});         
        SaveFigure([filename, 'stagnationPointY2'],params);
        
        PlotAsymptoticInterfaceResults(dataN,[],[],'kappa',{'IsoInterface','noLegend'},'\kappa');    
        SaveFigure([filename, 'Interfacekappa'],params);
                
        PlotAsymptoticInterfaceResults(dataN,[],'mu',{'IsoInterface','noLegend'},'\mu');
        SaveFigure([filename, 'InterfaceMu'],params);
        
        %PlotAsymptoticInterfaceResults(dataN,1,'mu_ddy2',{'IsoInterface'},'\frac{\partial^2\mu}{\partial y_2^2}');
        PlotAsymptoticInterfaceResults(dataN,[],[],'p',{'IsoInterface','noLegend'},'p');
        SaveFigure([filename, 'InterfaceP'],params);        
        
        PlotAsymptoticInterfaceResults(dataN,[],[],'kappa_Cakmu',{'IsoInterface','noLegend'},'\kappa/(Ca_k\mu)');     hold on;
        plot([0,24],[1.5 1.5],'k--','linewidth',1.5);
        ylim([1.2 1.8]);
        SaveFigure([filename, 'Interface_KappaCak_Mu'],params);
    end
    function PlotAsymptoticInterfaceResults(dataM,i_Cak,i_y2Max,value,opts)
        if(nargin < 4)
            opts = {};                        
        end        
        if(ischar(opts))
            opts = {opts};
        end
        legendstr = {};
        
        if(isempty(i_Cak))
            i_Cak =  1:size(dataM{1},1);
        end
        if(isempty(i_y2Max))
            i_y2Max = size(dataM{1},2);
        end
        
        ylabelStr = GetYStr(value,opts,dataM);
                
        figure('Position',[0 0 800 800],'color','white');        
        if(length(i_Cak) == 1)
            title(['Ca = ',num2str(dataM{1}(i_Cak,1).Ca)]);
        end
        
        for j1 = i_Cak
            lin   = lines{mod(j1-1,nolines)+1};
            for j2 = i_y2Max  
                sym = syms{mod(j2-1,nosyms)+1};                
                for j0 = 1:length(dataM)                
                    Cn    = dataM{j0}(j1,j2).Cn;                
                    col   = cols{mod(j0-1,nocols)+1};

                    if(IsOption(opts,'IsoInterface'))
                        val = dataM{j0}(j1,j2).IsoInterface.(value); 
                        y  = dataM{j0}(j1,j2).IsoInterface.y2;
                    elseif(IsOption(opts,'mu_y2'))
                        val = dataM{j0}(j1,j2).mu_y2{1}.(value);
                        y  = dataM{j0}(j1,j2).mu_y2{1}.pts.y1_kv;                                        
                    elseif(IsOption(opts,'mu_y1'))
                        val = dataM{j0}(j1,j2).mu_y1{value.i}.(value.val);
                        y  = dataM{j0}(j1,j2).mu_y1{value.i}.pts.y2_kv;   
                    end

                    if(IsOption(opts,'SC'))
                        plot(y,val,[lin,sym],...
                            'color',col,...
                            'MarkerSize',8,'MarkerFaceColor',col);
                    else
                        plot(y,val,[lin],'color',col,'linewidth',1.5); 
                    end
                    hold on;                                
                    if(size(dataM{1},2)>1)
                        legendstr(end+1) = {['Cn = ',num2str(Cn),' y_{2,Max} = ',num2str(dataM{j0}(j1,j2).y2Max)]};
                    else
                        legendstr(end+1) = {['Cn = ',num2str(Cn)]};
                    end
                end
            end  
        end
        if(~IsOption(opts,'noLegend'))            
            legend(legendstr);
        end
        set(gca,'linewidth',1.5);
        set(gca,'fontsize',20);        
        
        if(IsOption(opts,'mu_y2'))
            xlabel('$y_1$','Interpreter','Latex','fontsize',20);
        else
            xlabel('$y_2$','Interpreter','Latex','fontsize',20);
        end
        ylabel(ylabelStr,'Interpreter','Latex','fontsize',20);  
                
    end        
    function PlotAsymptoticResults(dataM,parameter,opts)        
        
        if(nargin == 2)
            opts = {};                        
        end        
        if(ischar(opts))
            opts = {opts};
        end                
        ylabelStr = GetYStr(parameter);
        
        
        if(~IsOption(opts,'noNewFigure'))            
            figure('Position',[0 0 800 800],'color','white');
        end
        legendstr = {}; 
        for i_Cak = 1:size(dataM{1},1)
            Ca = dataM{1}(i_Cak,1).Ca;
            for j2 = 1:size(dataM{1},2)
                for j0 = 1:length(dataM)
                    Cn(j0)    = dataM{j0}(i_Cak,j2).Cn;
                    if(IsOption(opts,'IsoInterface'))
                        par(j0)      = dataM{j0}(i_Cak,j2).IsoInterface.(parameter);                
                    elseif(IsOption(opts,'mu_y2'))
                        par(j0)      = dataM{j0}(i_Cak,j2).mu_y2{1}.(parameter);                                        
                    else                        
                        par(j0)      = dataM{j0}(i_Cak,j2).(parameter);                
                    end
                end                 
                %col  = cols{mod(j0-1,nocols)+1};                                
                lin = lines{mod(i_Cak-1,nolines)+1};                
                sym = syms{mod(j2-1,nosyms)+1};
                                
                plot(Cn,par,...
                    [lin,sym],'linewidth',1.5,...
                    'MarkerSize',8,'MarkerFaceColor','k'); hold on;                
                
                legendstr(end+1) = {['Ca = ',num2str(Ca),' y_{2,Max} = ',num2str(dataM{1}(i_Cak,j2).y2Max)]};
             end  
        end
        set(gca,'linewidth',1.5);
        set(gca,'fontsize',20);
        if(~IsOption(opts,'noLegend'))            
            legend(legendstr);
        end
        xlabel('Cn','Interpreter','Latex','fontsize',20);        
        ylabel(ylabelStr,'Interpreter','Latex','fontsize',20);                
        
        %ylim([90,100]);        
        %SaveFigure([parameter,'_vs_l_diff']);
    end        
    function PlotAsymptoticResults_Y2Max(dataM,parameter,opts)
        if(nargin == 2)
            opts = {};                        
        end        
        if(ischar(opts))
            opts = {opts};
        end                
        
        if(~IsOption(opts,'noNewFigure'))            
            figure('Position',[0 0 800 800],'color','white');
        end
         
        legendstr = {};
        for j1 = 1:size(dataM{1},1)
            Ca = dataM{1}(j1,1).Ca;
            for j0 = 1:length(dataM)                
                Cn = dataM{j0}(1,1).Cn;
                for j2 = 1:size(dataM{1},2)
                    y2M(j2)  = dataM{j0}(j1,j2).y2Max;                                        
                    if(IsOption(opts,'IsoInterface'))
                        par(j2)      = dataM{j0}(j1,j2).IsoInterface.(parameter);                
                    elseif(IsOption(opts,'mu_y2'))
                        par(j2)      = dataM{j0}(j1,j2).mu_y2{1}.(parameter);                                        
                    else                        
                        par(j2)      = dataM{j0}(j1,j2).(parameter);                
                    end                                        
                end                            
                col  = cols{mod(j0-1,nocols)+1};                
                lin = lines{mod(j1-1,nolines)+1};                
                %sym = syms{mod(j2,nosyms)+1};
                
                plot(y2M,par,...
                    lin,'color',col,'linewidth',1.5,...
                    'MarkerSize',8,'MarkerFaceColor',col); hold on;                
                
                legendstr(end+1) = {['Ca = ',num2str(Ca),' Cn = ',num2str(Cn)]};
             end  
        end
        
        if(~IsOption(opts,'noLegend'))            
            legend(legendstr);
        end
        set(gca,'linewidth',1.5);
        set(gca,'fontsize',20);
        xlabel('$y_{2,max}$','Interpreter','Latex','fontsize',20);       
        ylabel(GetYStr(parameter),'Interpreter','Latex','fontsize',20);        
        %ylim([90,100]);
        %SaveFigure([parameter,'_vs_y2Max']);
    end
    function dataM = RunNumericalExperiment(pars,h)
    
        config = pars.config;
        for k0 = 1:length(pars.l_d)
            
            l_diff                 = pars.l_d(k0);
            config.optsPhys.l_diff = l_diff;    
            
            for j = 1:length(pars.y2Max)            

                config.optsNum.PhysArea.y2Max = pars.y2Max(j)*l_diff;

                DI = DiffuseInterfaceBinaryFluid(config);
                DI.Preprocess();
                for i = 1:length(pars.Cak)

                    DI.SetCak(pars.Cak(i));                
                    DI.IterationStepFullProblem();                    
                    DI.PostProcess();                       

                    dataM{k0}(i,j).config.optsNum    = DI.optsNum;
                    dataM{k0}(i,j).config.optsPhys   = DI.optsPhys;
                    
                    dataM{k0}(i,j).Pts = DI.IDC.Pts;
                    dataM{k0}(i,j).mu  = DI.mu;
                    dataM{k0}(i,j).uv  = DI.uv;
                    dataM{k0}(i,j).p   = DI.p;
                    dataM{k0}(i,j).phi = DI.phi;
                    
                    dataM{k0}(i,j).Ca                = 3/4*pars.Cak(i);                                
                    dataM{k0}(i,j).muMinusInf        = DI.mu(DI.IDC.Ind.left & DI.IDC.Ind.bottom);
                    dataM{k0}(i,j).muPlusInf         = DI.mu(DI.IDC.Ind.right & DI.IDC.Ind.bottom);
                    dataM{k0}(i,j).muMaxAbs          = max(abs(DI.mu));
                    dataM{k0}(i,j).pMax              = max((DI.p));
                    dataM{k0}(i,j).pMin              = min((DI.p));                              
                    dataM{k0}(i,j).IsoInterface      = DI.IsoInterface;                                
                    dataM{k0}(i,j).stagnationPointY2 = DI.StagnationPoint.y2_kv(1);                    

                    y2 = 0:0.5:3;
                    for kk = 1:length(y2)
                        [mu,pts]      = DI.IDC.plotLine(l_diff*[-10 10],l_diff*y2(kk)*[1 1],DI.mu);                    
                        [mu_dy1,pts]  = DI.IDC.plotLine(l_diff*[-10 10],l_diff*y2(kk)*[1 1],DI.IDC.Diff.Dy1*DI.mu);
                        [mu_dy2,pts]  = DI.IDC.plotLine(l_diff*[-10 10],l_diff*y2(kk)*[1 1],DI.IDC.Diff.Dy2*DI.mu);
                        [mu_ddy2,pts] = DI.IDC.plotLine(l_diff*[-10 10],l_diff*y2(kk)*[1 1],DI.IDC.Diff.DDy2*DI.mu);
                        %[v_dy2,pts] = DI.IDC.plotLine(l_diff*[-10 10],l_diff*y2(kk)*[1 1],DI.IDC.Diff.Dy2*DI.uv(1+end/2:end));
                        dataM{k0}(i,j).mu_y2{kk} = struct('mu',mu,...%'v_dy2',v_dy2,...
                                                      'mu_dy1',mu_dy1,...
                                                      'mu_dy2',mu_dy2,...
                                                      'mu_ddy2',mu_ddy2,...
                                                      'pts',pts,'y2',y2(kk));                        
                    end
                    
                    
                    y1 = -2:0.5:3;
                    for kk = 1:length(y2)
                        [mu,pts]      = DI.IDC.plotLine(l_diff*y1(kk)*[1 1],l_diff*[0 10],DI.mu);                    
                        [mu_dy1,pts]  = DI.IDC.plotLine(l_diff*y1(kk)*[1 1],l_diff*[0 10],DI.IDC.Diff.Dy1*DI.mu);
                        [mu_dy2,pts]  = DI.IDC.plotLine(l_diff*y1(kk)*[1 1],l_diff*[0 10],DI.IDC.Diff.Dy2*DI.mu);
                        [mu_ddy2,pts] = DI.IDC.plotLine(l_diff*y1(kk)*[1 1],l_diff*[0 10],DI.IDC.Diff.DDy2*DI.mu);
                        %[v_dy2,pts] = DI.IDC.plotLine(l_diff*[-10 10],l_diff*y2(kk)*[1 1],DI.IDC.Diff.Dy2*DI.uv(1+end/2:end));
                        dataM{k0}(i,j).mu_y1{kk} = struct('mu',mu,...%'v_dy2',v_dy2,...
                                                      'mu_dy1',mu_dy1,...
                                                      'mu_dy2',mu_dy2,...
                                                      'mu_ddy2',mu_ddy2,...
                                                      'pts',pts,'y1',y1(kk));                        
                    end

                    close all;
                end
                clear('DI');
            end
        end        
    end  
    function CompareAllData(dataM,j1)
        thetaEq = dataM{1}(1,1).config.optsPhys.thetaEq;        

        figure('Position',[0 0 800 800],'color','white');
        hatL_M = zeros(size(dataM));
        Sy2_M  = zeros(size(dataM));
        Ca     = 3/4*dataM{1}(j1,1).config.optsPhys.Cak;
        
        for j0 = 1:length(dataM)
            for j2 = 1:size(dataM{j0},2)
                hatL_M(j1,j2) = dataM{j0}(j1,j2).hatL;         
                Sy2_M(j1,j2)  = dataM{j0}(j1,j2).stagnationPointY2;         
                PlotRescaledInterfaceSlope(dataM{j0},j1,j2,cols{mod(j0,nocols)+1},syms{mod(j2,nosyms)+1});
            end                                       
        end       
        
        l_diff    = dataM{end}(j1,j2).config.optsPhys.l_diff;
        y2P       = (1:0.1:max(dataM{end}(j1,j2).y2 - 4*l_diff))'/l_diff;
        hatL      = dataM{end}(j1,j2).hatL/l_diff;
        theta_Ana = GHR_Inv(Ca*log(y2P/hatL)+GHR_lambdaEta(thetaEq,1),1);
        plot(y2P,180/pi*theta_Ana,'m','linewidth',3); hold on;        


        set(gca,'linewidth',1.5);
        set(gca,'fontsize',20);
        xlabel('$y/\ell_{d}$','Interpreter','Latex','fontsize',20);
        ylabel('$\theta[^\circ]$','Interpreter','Latex','fontsize',20);        
        %ylim([90,100]);
        
        SaveFigure(['InterfaceSlope_Ca_',num2str(Ca)],pars);
        
    end
    function PlotData(dataM)
        thetaEq = dataM(1,1).config.optsPhys.thetaEq;
        nocols = 5;
        nosyms = 5;
        cols = {'g','b','m','k','r'};
        syms = {'<','d','s','o','>'};

        figure('Position',[0 0 800 800],'color','white');
        hatL_M = zeros(size(dataM));
        Sy2_M  = zeros(size(dataM));

        for i1 = 1:size(dataM,1)

            Ca          = 3/4*pars.Cak(i1);           

            for i2 = 1:size(dataM,2)
                hatL_M(i1,i2) = dataM(i1,i2).hatL;         
                Sy2_M(i1,i2)  = dataM(i1,i2).stagnationPointY2;         
                PlotInterfaceSlope(dataM,i1,i2,cols{mod(i1,nocols)+1},syms{mod(i2,nosyms)+1});
            end        
            hatL_Av = sum(hatL_M(i1,:)/size(dataM,2));

            y2P       = dataM(i1,i2).y2(2:end);
            theta_Ana = GHR_Inv(Ca*log(y2P/hatL_Av)+GHR_lambdaEta(thetaEq,1),1);
            plot(y2P,180/pi*theta_Ana,cols{mod(i1,nocols)+1},'linewidth',1.5); hold on;        

        end       

        set(gca,'linewidth',1.5);
        set(gca,'fontsize',20);
        xlabel('$y$','Interpreter','Latex','fontsize',20);
        ylabel('$\theta[^\circ]$','Interpreter','Latex','fontsize',20);        
        ylim([90,100]);
        
        
        l_diff = pars.config.optsPhys.l_diff;

        SaveFigure(['InterfaceSlope_l_d_',num2str(l_diff)],pars);
        %print2eps([dirData filesep filename],gcf);
        %saveas(gcf,[dirData filesep filename '.fig']);        
        %disp(['Figures saved in ',dirData filesep filename '.fig/eps']);

        hatL_Av = mean2(hatL_M); 
        Lb =  hatL_Av - min(min(hatL_M));
        Ub =  max(max(hatL_M))-hatL_Av;       
        disp(['hatL/l_diff = ',num2str(hatL_Av/l_diff),' +/- ',num2str(max(Lb,Ub)/l_diff)]);


        av = mean2(Sy2_M); 
        Lb =  av - min(min(Sy2_M));
        Ub =  max(max(Sy2_M))-av;           
        disp(['stagnation point y2/l_diff = ',num2str(av/l_diff),' +/- ',num2str(max(Lb,Ub)/l_diff)]);
    end    
    function PlotRescaledInterfaceSlope(dataM,i1,i2,col,sym)                    
        l_diff = dataM(i1,i2).config.optsPhys.l_diff;
        %hatL   = 0.46*l_diff;%46
        y2     = dataM(i1,i2).y2 /l_diff;
        mark   = (y2 < (max(y2)-4));
        plot(y2(mark),180/pi*dataM(i1,i2).theta(mark),[col,sym],'MarkerSize',5,'MarkerFaceColor',col); hold on;                              
    end   
    function PlotInterfaceSlope(dataM,i1,i2,col,sym)
                    
        y2     = dataM(i1,i2).y2;                          
        hatL   = (dataM(i1,i2).hatL);                        
        
        plot(y2,180/pi*dataM(i1,i2).theta,[col,sym],'MarkerSize',7,'MarkerFaceColor',col); hold on;                
        disp(['hatL = ',num2str(hatL)]);                
    end
    function dataN = Rescale(dataM)
        for k0 = 1:length(dataM)
            for k1 = 1:size(dataM{1},1)
                for k2 = 1:size(dataM{1},2)
                    Cn    = 1/dataM{k0}(k1,k2).config.optsPhys.l_diff;
                    Cak   = dataM{k0}(k1,k2).config.optsPhys.Cak;
                    
                    dataN{k0}(k1,k2).Cn  = Cn;           
                    dataN{k0}(k1,k2).Cak = Cak;
                    dataN{k0}(k1,k2).y2Max  = dataM{k0}(k1,k2).config.optsNum.PhysArea.y2Max*Cn;
                    dataN{k0}(k1,k2).Ca              = dataM{k0}(k1,k2).Ca;                                

                    dataN{k0}(k1,k2).muMinusInf  = dataM{k0}(k1,k2).muMinusInf/(Cn*Cak);
                    dataN{k0}(k1,k2).muPlusInf   = dataM{k0}(k1,k2).muPlusInf/(Cn*Cak);
                    dataN{k0}(k1,k2).muMaxAbs    = dataM{k0}(k1,k2).muMaxAbs/(Cn*Cak);
                    dataN{k0}(k1,k2).pMax        = dataM{k0}(k1,k2).pMax/Cn;
                    dataN{k0}(k1,k2).pMin        = dataM{k0}(k1,k2).pMin/Cn;                                      
                    dataN{k0}(k1,k2).stagnationPointY2 = dataM{k0}(k1,k2).stagnationPointY2*Cn;
                    dataN{k0}(k1,k2).mu          = dataM{k0}(k1,k2).mu/(Cn*Cak);

                    for i = 1:2
                        if(i==1)
                            mu_str = 'mu_y2';
                        elseif(i==2)
                            mu_str = 'mu_y1';
                        end
                            
                        for kk = 1:length(dataM{1}(1,1).(mu_str))
                            dataN{k0}(k1,k2).(mu_str){kk}.mu        = dataM{k0}(k1,k2).(mu_str){kk}.mu/(Cn*Cak);
                            dataN{k0}(k1,k2).(mu_str){kk}.mu_dy1    = dataM{k0}(k1,k2).(mu_str){kk}.mu_dy1/(Cn^2*Cak);
                            dataN{k0}(k1,k2).(mu_str){kk}.mu_ddy2   = dataM{k0}(k1,k2).(mu_str){kk}.mu_ddy2/(Cn^3*Cak);
                            dataN{k0}(k1,k2).(mu_str){kk}.pts.y1_kv = dataM{k0}(k1,k2).(mu_str){kk}.pts.y1_kv*Cn;
                            dataN{k0}(k1,k2).(mu_str){kk}.pts.y2_kv = dataM{k0}(k1,k2).(mu_str){kk}.pts.y2_kv*Cn;
                            
                            if(strcmp(mu_str,'mu_y2'))
                                dataN{k0}(k1,k2).(mu_str){kk}.y2        = dataM{k0}(k1,k2).(mu_str){kk}.y2*Cn;
                            elseif(strcmp(mu_str,'mu_y1'))
                                dataN{k0}(k1,k2).(mu_str){kk}.y1        = dataM{k0}(k1,k2).(mu_str){kk}.y1*Cn;
                            end

                            dataN{k0}(k1,k2).(mu_str){kk}.mu_max_y20             = max(abs(dataN{k0}(k1,k2).(mu_str){kk}.mu));
                            [muMax,i] = max((dataN{k0}(k1,k2).(mu_str){kk}.mu_dy1));
                            [muMin,j] = min((dataN{k0}(k1,k2).(mu_str){kk}.mu_dy1));
                            dataN{k0}(k1,k2).(mu_str){kk}.d                      = dataN{k0}(k1,k2).(mu_str){kk}.pts.y1_kv(i)-dataN{k0}(k1,k2).(mu_str){kk}.pts.y1_kv(j);
                            dataN{k0}(k1,k2).(mu_str){kk}.mu_dy1_max_y20_sqrtCn  = max(abs(dataN{k0}(k1,k2).(mu_str){kk}.mu_dy1))*sqrt(Cn);
                            dataN{k0}(k1,k2).(mu_str){kk}.mu_ddy2_max_y20_sqrtCn = max(abs(dataN{k0}(k1,k2).(mu_str){kk}.mu_ddy2))*sqrt(Cn);
                        end
                    end
                    
                    
                    dataN{k0}(k1,k2).IsoInterface.y2       = dataM{k0}(k1,k2).IsoInterface.y2*Cn;
                    dataN{k0}(k1,k2).IsoInterface.theta    = dataM{k0}(k1,k2).IsoInterface.theta;
                    dataN{k0}(k1,k2).IsoInterface.hatL     = dataM{k0}(k1,k2).IsoInterface.hatL*Cn;
                    dataN{k0}(k1,k2).IsoInterface.mu_ddy2  = dataM{k0}(k1,k2).IsoInterface.mu_ddy2/(Cn^3*Cak);
                    dataN{k0}(k1,k2).IsoInterface.u_n  = dataM{k0}(k1,k2).IsoInterface.u_n;
                    dataN{k0}(k1,k2).IsoInterface.u_t  = dataM{k0}(k1,k2).IsoInterface.u_t;
                    dataN{k0}(k1,k2).IsoInterface.flux_n  = dataM{k0}(k1,k2).IsoInterface.flux_n;
                    dataN{k0}(k1,k2).IsoInterface.flux_t  = dataM{k0}(k1,k2).IsoInterface.flux_t;
                    
                    
                    dataN{k0}(k1,k2).IsoInterface.kappa = dataM{k0}(k1,k2).IsoInterface.kappa/Cn;
                    dataN{k0}(k1,k2).IsoInterface.p     = dataM{k0}(k1,k2).IsoInterface.p/Cn;
                    dataN{k0}(k1,k2).IsoInterface.mu    = dataM{k0}(k1,k2).IsoInterface.mu/(Cak*Cn);
                    dataN{k0}(k1,k2).IsoInterface.kappa_Cakmu       = dataM{k0}(k1,k2).IsoInterface.kappa./dataM{k0}(k1,k2).IsoInterface.mu;
                end
            end
        end
    end
    function str = GetYStr(parameter,opts,data)
        
        if(IsOption(opts,'mu_y1'))
            VarName = parameter.val;
        else
            VarName = parameter;
        end
        
        if(strcmp(VarName,'mu'))
            str = '$\mu$';
        elseif(strcmp(VarName,'muMinusInf'))
            str = '$\mu_{y_1 = -\infty}$';
        elseif(strcmp(VarName,'muPlusInf'))
            str = '$\mu_{y_1 = \infty}$';
        elseif(strcmp(VarName,'stagnationPointY2'))
            str = '$y_{2,S}$';
        elseif(strcmp(VarName,'hatL'))
            str = '$\hat L$';
        elseif(strcmp(VarName,'muMaxAbs'))
            str = '$\max|\mu|$';   
        elseif(strcmp(VarName,'pMin'))
            str = '$\min p$';            
        elseif(strcmp(VarName,'pMax'))
            str = '$\max p$';           
        elseif(strcmp(VarName,'mu_max_y20'))
            str = '$\max|\mu|$ at $y_2 = 0$';
        elseif(strcmp(VarName,'mu_dy1_max_y20_sqrtCn'))
            str = '$\sqrt{Cn}\max|\frac{\partial \mu}{\partial y_1}|$ at $y_2 = 0$';
        elseif(strcmp(VarName,'mu_ddy2_max_y20_sqrtCn'))
            str = '$\sqrt{Cn}\max|\frac{\partial^2 \mu}{\partial y_2^2}|$ at $y_2 = 0$';
        elseif(strcmp(VarName,'d'))
            str = '$d$ at $y_2 = 0$';
        else
            str = VarName;
        end
        
        
        if(IsOption(opts,'mu_y1'))
            str = [str,' at $y_1 = ',num2str(data{1}(1,1).mu_y1{parameter.i}.y1),'$'];
        elseif(IsOption(opts,'mu_y2'))
            str = [str,' at $y_2 = ',num2str(data{1}(1,1).mu_y1{parameter.i}.y2),'$'];                          
        end
        
    end

end

