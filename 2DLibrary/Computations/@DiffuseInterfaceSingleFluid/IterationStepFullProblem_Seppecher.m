function IterationStepFullProblem_Seppecher(this,noIterations)
    %Continuitiy: 0 = div(uv)
    %Momentum:    0 = -Grad(p) + (G+s*phi)*grad(phi)/Cak + Lap(uv)
    %Phasefield   0 = m*Lap(G + s*phi) - u*grad(phi)
    %ChemPot      0 = f_w' - s*phi - Cn*Lap(phi) - G
    %
    % 
    % (BC1) uv = uv_BC    
    % (BC2) nu*grad(phi) = 0
    % (BC3) nu*grad(G) = 0
    % (BC4) p = 0  at y1 = +/- infinity
    
    % A*[uv;phi;G;p] = b corresponds to momentum and continuity Eq. for given phasefield phi                           
    if(nargin == 1)
        noIterations = 20;
    end
    
    Cn             = this.optsPhys.Cn;
    Cak            = this.optsPhys.Cak;    
    zeta           = this.optsPhys.zeta;
    phi_m          = this.optsPhys.phi_m;    
    nParticles     = this.optsPhys.nParticles;
    
    PtsCart        = this.IC.GetCartPts();
    Diff           = this.IC.Diff;
    M              = this.IC.M;  
    Ind            = this.IC.Ind;
    IntSubArea     = this.IntSubArea;    
    y2Max          = this.optsNum.PhysArea.y2Max;
    
    IntPathUpLow   = this.IC.borderTop.IntSc - this.IC.borderBottom.IntSc; 
    IntNormalUp    = this.IC.borderTop.IntNormal;
    tauM           = Cak*(Diff.LapVec + (zeta + 1/3)*Diff.gradDiv);
    
    lbC = Ind.left & Ind.bottom;
    rbC = Ind.right & Ind.bottom;

    Z    = zeros(M);
    IBB  = repmat(Ind.bound,2,1);  
    ITT  = repmat(Ind.top,2,1);  
    EYM  = eye(M);  EYMM  = eye(2*M);

    F       = false(M,1);   T       = true(M,1);    
    
    opts = struct('optsNum',this.optsNum,...
                  'optsPhys',this.optsPhys,...
                  'Comments',this.configName);
              
	in = struct('initialGuess',[0;0;pi/2;GetInitialCondition(this)]);
    
    [res,~,Parameters] = DataStorage([],@SolveSingleFluid,...
                    opts,in);
	   
    this.uv       = res.uv;
    this.mu       = res.mu;
    this.phi      = res.phi;
    this.filename = Parameters.Filename;
    this.errors.errorIterations = res.errorHistory;
    
    %     this.errors.errorIterations = res.errorIterations;
    
    
    function res = SolveSingleFluid(conf,in)
        [vec,errHistory] = NewtonMethod(in.initialGuess,@f,1e-6,noIterations,0.4);    
    
        %[uv;phi;mu] 
        res.uv  = vec([T;T;F;F;F]);
        res.phi = vec([F;F;T;F;F]);
        res.mu  = vec([F;F;F;T;F]);
        
        res.errorHistory = errHistory;
    end    
    function [v_full,A_full] = f(z)
        
        %[uv;phi;G;p]         
        a      = z(1);
        deltaX = z(2);
        theta  = z(3);
        
        z      = z(4:end);
        uv  = z([T;T;F;F]);
        phi = z([F;F;T;F]);
        G   = z([F;F;F;T]);        
   
        uvTdiag        = [diag(uv(1:end/2)),diag(uv(end/2+1:end))];        
        [fWP,fW,fWPP]    = DoublewellPotential(phi,Cn);
    

        % Continuity   %[uv;phi;G]
        A_cont         = [diag(phi+phi_m)*Diff.div + [diag(Diff.Dy1*phi),diag(Diff.Dy2*phi)]...
                          diag(Diff.div*uv)+uvTdiag*Diff.grad,...
                          Z];
        v_cont         = Diff.div*(uv.*repmat(phi+phi_m,2,1));

       % Momentum     %[uv;phi;G]       
       A_mom          = [tauM,...
                         -[diag(Diff.Dy1*G);diag(Diff.Dy2*G)],...
                         - diag(repmat(phi+phi_m,2,1))*Diff.grad];

       v_mom         = tauM*uv - repmat(phi+phi_m,2,1).*(Diff.grad*G);
        
       % Chemical Potential %[uv;phi;G]  
       A_mu           = [Z,Z,...
                         diag(fWPP)-Cn*Diff.Lap,...
                         -EYM];
       v_mu           = fWP - Cn*Diff.Lap*phi - G;
        
       %% Boundary conditions [uv;phi;G]
        
       % (BC1) p = 0  at y1 = +/- infinity
       A_cont(Ind.left|Ind.right,:)         = 0;
       A_cont(Ind.left|Ind.right,[F;F;F;T]) = Diff.Dy2(Ind.left|Ind.right,:);
       v_cont(Ind.left|Ind.right,:)         = Diff.Dy2(Ind.left|Ind.right,:)*G;
                               
       A_cont(lbC,:)         = 0;
       A_cont(lbC,[F;F;T;F]) = IntSubArea;
       v_cont(lbC)           = IntSubArea*phi - nParticles;                 
               
       % (BC2) [uv;phi;G]                   
       A_cont(rbC,[T;T;F;F])   = IntPathUpLow*[Diff.Dy2 , Diff.Dy1]*Cak;       
       A_cont(rbC,[F;F;T;F])   = -Cn*IntPathUpLow*(diag(Diff.Dy1*phi)*Diff.Dy2 + diag(Diff.Dy2*phi)*Diff.Dy1);
       
       A_cont(rbC,[F;F;rbC;F]) = A_cont(rbC,[F;F;rbC;F]) + y2Max*(G(rbC) + fWP(rbC));
       A_cont(rbC,[F;F;lbC;F]) = A_cont(rbC,[F;F;lbC;F]) - y2Max*(G(lbC) + fWP(lbC));    
       A_cont(rbC,[F;F;F;rbC]) = A_cont(rbC,[F;F;F;rbC]) + y2Max*(phi(rbC) + phi_m);
       A_cont(rbC,[F;F;F;lbC]) = A_cont(rbC,[F;F;F;lbC]) - y2Max*(phi(lbC) + phi_m);
                    
       v_cont(rbC) = IntPathUpLow*(Cak*[Diff.Dy2 , Diff.Dy1]*uv ...
                              - Cn*((Diff.Dy1*phi).*(Diff.Dy2*phi)))...
                        +y2Max*(((phi(rbC)+phi_m)*G(rbC) + fW(rbC)) - ...
                                ((phi(lbC)+phi_m)*G(lbC) + fW(lbC)));
        
        % (BC3.a) uv = uv_BC    
        %[uvBound,a]            = GetBoundaryCondition(this);%,theta,phi);           
        u_flow      = GetSeppecherSolutionCart([PtsCart.y1_kv - deltaX,...
                                         PtsCart.y2_kv],1,0,0,theta);                  

        
        a_corr                = (1 + a*(phi(lbC)-phi).^2.*(phi(rbC)-phi).^2);
        
        a_corr_phi            = diag(-2*a*(phi(lbC)-phi).*(phi(rbC)-phi).^2 ...
                                     -2*a*(phi(lbC)-phi).^2.*(phi(rbC)-phi));
        a_corr_phi(:,lbC)     =  a_corr_phi(:,lbC) + 2*a*(phi(lbC)-phi).*(phi(rbC)-phi).^2;
        a_corr_phi(:,rbC)     =  a_corr_phi(:,rbC) + 2*a*(phi(rbC)-phi).*(phi(lbC)-phi).^2;
        a_corr_a              = (phi(lbC)-phi).^2.*(phi(rbC)-phi).^2;
        
        uvBound     = u_flow .*repmat(a_corr,2,1);                
        uvBound_phi = diag(u_flow)*repmat(a_corr_phi,2,1);                                 

        A_mom(ITT,:)           = 0;
        A_mom(ITT,[T;T;F;F])   = EYMM(ITT,:);
        A_mom(ITT,[F;F;T;F])   = uvBound_phi(ITT,:);
        
        A_mom_a                = zeros(2*M,1);        
        A_mom_a(ITT)           = -u_flow(ITT).*repmat(a_corr_a(Ind.top),2,1);
        
        A_mom_deltaX           = zeros(2*M,1);
        Dy12 = blkdiag(Diff.Dy1,Diff.Dy1);
        A_mom_deltaX(ITT)      = -(Dy12(ITT,:)*u_flow).*repmat(a_corr(Ind.top),2,1); 
                                    
        
        A_mom_theta = zeros(2*M,1);
        d_theta     = 0.05;
        u_flow_d    = (GetSeppecherSolutionCart([PtsCart.y1_kv - deltaX,...
                          PtsCart.y2_kv],1,0,0,theta+d_theta) - u_flow)/d_theta;
        A_mom_theta(ITT) = u_flow_d(ITT).*repmat(a_corr(Ind.top),2,1);
                
        A_momThree   = [A_mom_a,A_mom_deltaX,A_mom_theta];
        
        v_mom(ITT)          = uv(ITT) - uvBound(ITT);
        
        % (BC3.b)
        u_Wall = [ones(M,1);zeros(M,1)];
        
        A_mom(IBB & ~ITT,:)         = 0;
        A_mom(IBB & ~ITT,[IBB & ~ITT;F;F]) = eye(sum(IBB & ~ITT));
        v_mom(IBB & ~ITT)           = uv(IBB & ~ITT) - u_Wall(IBB & ~ITT);
        
        % (BC4.a) nu*grad(phi) = 0
        A_mu(Ind.bottom,:)           = 0;
        A_mu(Ind.bottom,[F;F;T;F])   = Diff.Dy2(Ind.bottom,:);    
        v_mu(Ind.bottom)             = Diff.Dy2(Ind.bottom,:)*phi;
        
        % (BC4.b) a*grad(phi) = 0
        a_direction               = [cos(theta)*EYM,sin(theta)*EYM];            
        a_direction_theta         = [-sin(theta)*EYM,cos(theta)*EYM];            
        A_mu(Ind.top,:)           = 0;
        A_mu(Ind.top,[F;F;T;F])   = a_direction(Ind.top,:)*Diff.grad;
        
        A_muThree                             = zeros(M,3);
        A_muThree(Ind.top,[false,false,true]) = a_direction_theta(Ind.top,:)*(Diff.grad*phi);
        v_mu(Ind.top)                         = a_direction(Ind.top,:)*(Diff.grad*phi);
        
        % Three extra conditions [uv;phi;G]
        % (EX 1) int((phi+rho_m)*u_y|_y2Max,y1=-infty..infty) = 2*y2Max
        A_a            = zeros(1,4*M);        
        A_a([F;F;T;F]) = IntNormalUp*[diag(uvBound(1:end/2));diag(uvBound(1+end/2:end))] ...
                       + IntNormalUp*(diag(repmat(phi+phi_m,2,1))*uvBound_phi);
        A_a([F;F;rbC;F]) = A_a([F;F;rbC;F]) + y2Max;
        A_a([F;F;lbC;F]) = A_a([F;F;lbC;F]) - y2Max;
        
        A_a_a      =  IntNormalUp*(repmat(phi+phi_m,2,1).*u_flow.*repmat(a_corr_a,2,1));        
        
        A_a_deltaX =  IntNormalUp*(repmat(phi+phi_m,2,1).*...
                                    ((Dy12*u_flow).*repmat(a_corr,2,1)));
        A_a_theta  = IntNormalUp*(repmat(phi+phi_m,2,1).*u_flow_d.*repmat(a_corr,2,1));
        A_a        = [A_a_a,A_a_deltaX,A_a_theta,A_a];
        
        v_a        = IntNormalUp*(repmat(phi+phi_m,2,1).*uvBound) + (phi(rbC)-phi(lbC))*y2Max;
        
        % (EX 2) phi(y2Max/tan(theta) + deltaX,y2Max) = 0
        InterpMatchPos       = this.IC.SubShapePtsCart(...
                                struct('y1_kv',deltaX + y2Max/tan(theta),...
                                       'y2_kv',y2Max));
        A_deltaX             = zeros(1,4*M);
        A_deltaX([F;F;T;F])  = InterpMatchPos;
        A_deltaX_deltaX      = InterpMatchPos*(Diff.Dy1*phi);
        A_deltaX_theta       = -(1/sin(theta))^2*InterpMatchPos*(Diff.Dy1*phi);
        A_deltaX             = [0,A_deltaX_deltaX,A_deltaX_theta,...
                                A_deltaX];    
        v_deltaX             = InterpMatchPos*phi;
        
        % (EX 3) mu(y1=-infty) = 0
        A_theta              = zeros(1,4*M);
        A_theta([F;F;F;lbC]) = 1;
        A_theta              = [0,0,0,A_theta];
        v_theta              = G(lbC);
                                                
        
        A = [A_mom;A_mu;A_cont];
        v = [v_mom;v_mu;v_cont];    
        
        A_three = [A_momThree;A_muThree;zeros(M,3)];
        
        A_full  = [A_a;...
                   A_deltaX;...
                   A_theta;...
                   [A_three,A]];
      
        v_full  = [v_a;...
                   v_deltaX;...
                   v_theta;...
                   v];                
        
        DisplayError(v_full);
    end    
    function DisplayError(errorFull)
        
        PrintErrorPos(errorFull(1),'consistent mass influx');
        PrintErrorPos(errorFull(2),'zero density at interface');        
        PrintErrorPos(errorFull(3),'chemical potential at -inf');
        
        error = errorFull(4:end);
        PrintErrorPos(error([F;F;F;T]),'continuity equation',this.IC.Pts);
        PrintErrorPos(error([T;F;F;F]),'y1-momentum equation',this.IC.Pts);
        PrintErrorPos(error([F;T;F;F]),'y2-momentum equation',this.IC.Pts);                                    
        PrintErrorPos(error([F;F;T;F]),'mu equation',this.IC.Pts);
    end

end