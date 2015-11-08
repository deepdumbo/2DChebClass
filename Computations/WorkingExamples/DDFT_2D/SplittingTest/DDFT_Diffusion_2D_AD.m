function [data,optsPhys,optsNum,optsPlot] = DDFT_Diffusion_2D_AD(optsPhys,optsNum,optsPlot)
%************************************************
%  define mu_s = kBT*log(rho) + int(rho(r')*Phi2D(r-r'),dr') + V_ext - mu
% Equilibrium:
% (EQ 1)  mu_s      = 0
% (EQ 2)  int(rho)  = noParticles
% Dynamics:
% (DYN 1) drho/dt = div(rho*grad(mu_s))
% (BC 1)  n*grad(rho) = 0
%************************************************
    if(nargin == 0)
        [data,optsNum,optsPhys,optsPlot] =Test_DDFT_Diffusion_MF();
        return;
    end

    disp(['** ',optsNum.DDFTCode,' **']);
 
    %************************************************
    %***************  Initialization ****************
    %************************************************
    PhysArea    = optsNum.PhysArea;
    N1          = PhysArea.N(1);  N2 = PhysArea.N(2);  
    kBT         = optsPhys.kBT;
    nParticlesS = optsPhys.nParticlesS;
    nSpecies    =length(nParticlesS);
      
    mS = optsPhys.mS;
    gammaS = optsPhys.gammaS;
    gamma  = bsxfun(@times,gammaS',ones(N1*N2,nSpecies));
    m  = bsxfun(@times,mS',ones(N1*N2,nSpecies));
    D0 = 1./(gamma.*m);
    
    plotTimes    = optsNum.plotTimes;

    if(isfield(optsPhys,'HSBulk'))
        HS_f       = str2func(optsPhys.HSBulk);  
    elseif(isfield(optsNum,'HSBulk'))
        HS_f       = str2func(optsNum.HSBulk); 
    else
        HS_f       = @ZeroMap;
    end   
    
    getFex = str2func(['Fex_',optsNum.FexNum.Fex]);
    
    if(nargin<3)
        optsPlot.lineColourDDFT={'r','b','g','k','m'};
        optsPlot.doDDFTPlots=true;
    end

    shape        = PhysArea;
    shape.Conv   = optsNum.FexNum;
   
    shapeClass = str2func(optsNum.PhysArea.shape);
    IDC                   = shapeClass(shape);
    
    [Pts,Diff,Int,Ind,~]  = IDC.ComputeAll(optsNum.PlotArea);
    
    %************************************************
    %****************  Preprocess  ****************
    %************************************************  
        
    tic
    fprintf(1,'Computing Fex matrices ...');   
    paramsFex.V2      = optsPhys.V2;
    paramsFex.kBT     = optsPhys.kBT;
    paramsFex.FexNum  = optsNum.FexNum;
    paramsFex.Pts     = IDC.Pts;
    paramsFex.nSpecies = nSpecies;   
    
    FexFun         = str2func(['FexMatrices_',optsNum.FexNum.Fex]);    
	IntMatrFex     = DataStorage(['FexData' filesep class(IDC)],FexFun,paramsFex,IDC);   
        
    fprintf(1,'done.\n');
    t_fex = toc;
    disp(['Fex computation time (sec): ', num2str(t_fex)]);

    if(isfield(optsNum,'HINum') && ~isempty(optsNum.HINum))
        doHI = true;
    else
        doHI = false;
    end
    
    if(doHI)        
        tic
        fprintf(1,'Computing HI matrices ...');   
        paramsHI.optsPhys.HI       = optsPhys.HI;
        paramsHI.optsNum.HINum     = optsNum.HINum;
        paramsHI.optsNum.Pts       = IDC.Pts;    
        paramsHI.optsNum.Polar     = 'cart';
        paramsHI.optsPhys.nSpecies = nSpecies;
        IntMatrHI     = DataStorage(['HIData' filesep class(IDC)],@HIMatrices2D_AD,paramsHI,IDC);      
        fprintf(1,'done.\n');
        t_HI = toc;
        display(['HI computation time (sec): ', num2str(t_HI)]); 
    end
    
    y1S     = repmat(Pts.y1_kv,1,nSpecies); 
    y2S     = repmat(Pts.y2_kv,1,nSpecies);
    
    [Vext,Vext_grad]  = getVBackDVBack(y1S,y2S,optsPhys.V1);  

    I       = eye(N1*N2);            
    eyes    = [I I];
    
    doSubArea = isfield(optsNum,'SubArea');
    
    if(doSubArea)    
        subshapeClass = str2func(optsNum.SubArea.shape);
        subArea       = subshapeClass(optsNum.SubArea);
        IP            = IDC.SubShapePts(subArea.Pts);
        Int_of_path   = subArea.IntFluxThroughDomain(100)*blkdiag(IP,IP);
    end
                                    
    %****************************************************************
    %**************** Solve for equilibrium condition   ************
    %****************************************************************    

    tic
    
    VAdd0=getVAdd(y1S,y2S,0,optsPhys.V1);
    x_ic0 = getInitialGuess(VAdd0);
    
    paramsIC.optsPhys.V1          = optsPhys.V1;
    paramsIC.optsPhys.V2          = optsPhys.V2;
    paramsIC.optsPhys.mS          = optsPhys.mS;
    paramsIC.optsPhys.kBT         = optsPhys.kBT;
    paramsIC.optsPhys.nParticlesS = optsPhys.nParticlesS;

    paramsIC.optsNum.FexNum   = optsNum.FexNum;
    paramsIC.optsNum.PhysArea = optsNum.PhysArea;
    
    fsolveOpts=optimset('Display','off');
    paramsIC.fsolveOpts = fsolveOpts;
    
    fprintf(1,'Computing initial condition ...');        
    eqStruct = DataStorage(['EquilibriumData' filesep class(IDC)],@ComputeEquilibrium,paramsIC,x_ic0);
    fprintf(1,'done.\n');
    
    x_ic = eqStruct.x_ic;
    flag = eqStruct.flag;
    
    if(flag<0)
        fprintf(1,'fsolve failed to converge\n');
        pause
    else
        fprintf(1,'Found initial equilibrium\n');
    end
    
    mu      = x_ic(1,:);
    x_ic    = x_ic(2:end,:);
    
%     if(~isfield(optsNum,'doPlots') ...
%             || (isfield(optsNum,'doPlots') && optsNum.doPlots) )
%         figure
%         rho_ic  = exp((x_ic-Vext)/kBT);
%         IDC.plot(rho_ic,'',optsPlot.lineColourDDFT);        
%     end

    t_eqSol = toc;
    disp(['Equilibrium computation time (sec): ', num2str(t_eqSol)]);
    
    
    %****************************************************************
    %****************  Compute time-dependent solution   ************
    %****************************************************************
    
    tic
    
    mM            = ones(N1*N2,1);
    mM(Ind.bound) = 0;
    mM            = repmat(mM,nSpecies,1);
    
    fprintf(1,'Computing dynamics ...'); 

    opts = odeset('RelTol',10^-8,'AbsTol',10^-8,'Mass',diag(mM));
    [~,X_t] =  ode15s(@dx_dt,plotTimes,x_ic,opts);
        
    fprintf(1,'done.\n');
    
    t_dynSol = toc;
    
    disp(['Dynamics computation time (sec): ', num2str(t_dynSol)]);
    
    %************************************************
    %****************  Postprocess  ****************
    %************************************************        

    nPlots = length(plotTimes);
    
    X_t = X_t';
    
    rho_t     = exp((X_t-Vext(:)*ones(1,nPlots))/kBT);
    
    X_t       = reshape(X_t,N1*N2,nSpecies,nPlots);
    rho_t     = reshape(rho_t,N1*N2,nSpecies,nPlots);
    flux_t    = zeros(2*N1*N2,nSpecies,nPlots);
    V_t       = zeros(N1*N2,nSpecies,nPlots);
    
    if(doSubArea)
        accFlux   = zeros(nPlots,1);
    end
    
    for i = 1:length(plotTimes)
        if(doHI)
            flux_t(:,:,i) = GetFlux_HI(X_t(:,:,i),plotTimes(i));        
        else
            flux_t(:,:,i) = GetFlux(X_t(:,:,i),plotTimes(i));        
        end    
        V_t(:,:,i)    = Vext + getVAdd(y1S,y2S,plotTimes(i),optsPhys.V1);
        if(doSubArea)
            accFlux(i) = Int_of_path*flux_t(:,:,i);
        end
    end
                           
    data       = v2struct(IntMatrFex,X_t,rho_t,mu,flux_t,V_t);
    data.shape = IDC;
    if(doSubArea) 
        data.Subspace = v2struct(subArea,accFlux);
    end
    
    if(~isfield(optsNum,'doPlots') ...
            || (isfield(optsNum,'doPlots') && optsNum.doPlots) )
        figure
        PlotDDFT(v2struct(optsPhys,optsNum,data));  
    end
               
    %***************************************************************
    %   Physical Auxiliary functions:
    %***************************************************************         
    function y = f(x)
        %solves for T*log*rho + Vext                
        mu_s         = x(1,:);
        x            = x(2:end,:);       
        rho_full     = exp((x-Vext)/kBT);
        y            = GetExcessChemPotential(x,0,mu_s); 
        y            = [Int*rho_full - nParticlesS';y];
        y            = y(:);
    end

    function y0 = getInitialGuess(VAdd)
        
      if(~isfield(optsPhys,'HSBulk') && ~isfield(optsNum,'HSBulk'))
        % initial guess for mu doesn't really matter
        muInit=zeros(1,nSpecies);

        % however, require relatively good guess for rho

        % rho without interaction ie exp(-(VBack+VAdd )/kBT)
        rhoInit = exp(-(Vext+VAdd)/kBT);
        
        % inverse of normalization coefficient
        normalization = repmat( Int*rhoInit./nParticlesS' , size(rhoInit,1) ,1);

        %rho     = exp((x-Vext)/kBT) = N exp((-Vadd - Vext)/kBT
        %x/kBT - Vext/kBT = log(N) - Vadd/kBT - Vext/kBT
        %x = kBT log(N) - Vadd
        
        y0=-kBT*log(normalization) -VAdd;
        
        y0 = [muInit; y0];
      else
          y0 = zeros(1+N1*N2,nSpecies);
      end
    
    end

    function dxdt = dx_dt(t,x)
        
        x        = reshape(x,N1*N2,nSpecies);
        
        mu_s     = GetExcessChemPotential(x,t,mu);
        mu_s(Ind.infinite,:) = 0;
        
        h_s      = Diff.grad*x - Vext_grad;
        h_s([Ind.infinite;Ind.infinite],:) = 0;
        
        dxdt     = kBT*Diff.Lap*mu_s + eyes*(h_s.*(Diff.grad*mu_s));  
        
        if(doHI)
            rho_s = exp((x-Vext)/kBT);
            rho_s = [rho_s;rho_s];
            gradMu_s = Diff.grad*mu_s;
            HI_s = ComputeHI(rho_s,gradMu_s,IntMatrHI);
            
            dxdt = dxdt + kBT*Diff.div*HI_s + eyes*( h_s.*HI_s );  
        end
        
        flux_dir             = Diff.grad*mu_s;
        dxdt(Ind.finite,:)     = Ind.normalFinite*flux_dir;
        dxdt(Ind.infinite,:)   = x(Ind.infinite,:) - x_ic(Ind.infinite,:);

        dxdt = D0.*dxdt;
        
        dxdt = dxdt(:);
        
    end
    
    function mu_s = GetExcessChemPotential(x,t,mu_offset)
        rho_s = exp((x-Vext)/kBT);
        mu_s  = getFex(rho_s,IntMatrFex,kBT);
                       
        for iSpecies=1:nSpecies
           mu_s(:,iSpecies) = mu_s(:,iSpecies) - mu_offset(iSpecies);
        end

        mu_s = mu_s + x + HS_f(rho_s,kBT) + getVAdd(y1S,y2S,t,optsPhys.V1);
                   
    end

    function flux = GetFlux(x,t)
        rho_s = exp((x-Vext)/kBT);       
        mu_s  = GetExcessChemPotential(x,t,mu); 
        flux  = -[rho_s;rho_s].*(Diff.grad*mu_s);                                
    end

    function flux = GetFlux_HI(x,t)
        rho_s = exp((x-Vext)/kBT);  
        rho_s = [rho_s;rho_s];
        mu_s  = GetExcessChemPotential(x,t,mu); 
        gradMu_s = Diff.grad*mu_s;
        HI_s =  ComputeHI(rho_s,gradMu_s,IntMatrHI);
        flux  = -rho_s.*(gradMu_s + HI_s);                                  
    end

    %***************************************************************
    %Auxiliary functions:
    %***************************************************************
    
    function eqStruct = ComputeEquilibrium(params,y0)      
        [y,status]   = fsolve(@f,y0,params.fsolveOpts);
        eqStruct.x_ic = y;
        eqStruct.flag = status;
    end

    function [muSC,fnCS] = ZeroMap(~,~)
        muSC = 0;
        fnCS = 0;
    end

end