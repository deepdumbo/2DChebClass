%--------------------------------------------------------------------------
% compulsory physical constants
%--------------------------------------------------------------------------

geom='planar2D';

% dimension in which to do the stochastic calculations
stocDim=2;
% dimension in which to do the DDFT calculations (=1), but we need to know
% it's one in certain places
DDFTDim=2;

%nParticlesS=20;
nParticlesS=25;

kBT=1;          % temperature
mS=1;

gammaS=1;
D0S=kBT./mS./gammaS;

%--------------------------------------------------------------------------
% V1 parameters
%--------------------------------------------------------------------------

V1DV1='V1_Well_Move_HalfInf';

% appropriate physical parameters for potentials in V1DV1
V0S        = 0.01;
V0addS     = 2.5;
tauS       = 0.1;

sigma1AddS = 8;
sigma2AddS = 2;

y10aS       = 0;
y20aS       = 2;
y10bS       = 0;
y20bS       = 0;

% form into structure to make it easy to pass arbitrary parameters to
% potentials
potParamsNames = {'V0','V0add','tau','sigma1Add','sigma2Add',...
                  'y10a','y20a','y10b','y20b'};
              
%--------------------------------------------------------------------------
% V2 parameters
%--------------------------------------------------------------------------

V2DV2='hardSphere';

sigmaS = 1;

potParams2Names={'sigma'};

%--------------------------------------------------------------------------
% HI parameters
%--------------------------------------------------------------------------

sigmaHS = 0.5;

HIParamsNames={'sigmaH'};

%--------------------------------------------------------------------------
% Save time setup
%--------------------------------------------------------------------------

% end time of calculation
%tMax=0.25;
tMax = 0.3;
%tMax = 5;
%tMax = 8;
%tMax = 15;


%--------------------------------------------------------------------------
% Stochastic setup
%--------------------------------------------------------------------------

% number of samples to take of the initial and final equilibrium
% distributions goverened by the second and third arguments of V1DV1 above
% only relevant if fixedInitial=false or sampleFinal=true

%burnin = 20000;
%nSamples = 2000000;  
 
nSamples = 1000000;

initialGuess='makeGridPos';

% number of runs of stochastic dynamics to do, and average over

%nRuns = 20000;
nRuns=100000;

% number of cores to use in parallel processing
poolsize=16;
%poolsize=1;

% type of calculation, either 'rv'=Langevin or 'r'=Ermak-MCammon
stocType={'r','r','r'};

% whether to include hydrodynamic interactions
stocHI={false,false,true};
% HI interaction matrices
stocHIType={[],'RP','OseenPlusWall2D'};

% names for stochastic calculations -- used as legend text
stocName={'noHI','RP','OseenWall'};

% whether to do Langevin and Brownian dynamics
doStoc={false,false,false};

% whether to load saved data for Langevin and Brownian dynamics
loadStoc={true,true,true};

% number of time steps
%tSteps={2*10^4,10^3,10^3};
tSteps={10^4,10^3,10^3};

% whether to save output data (you probably should)
saveStoc={true,true,true};

stocColour = {{'g'},{'g'},{'b'}};

%--------------------------------------------------------------------------
% DDFT setup
%--------------------------------------------------------------------------

% Phys_Area = struct('shape','HalfSpace_FMT','N',[20;20],'L1',2,'L2',2, ...
%                        'y2wall',0,'N2bound',10,'h',1,'L2_AD',1,'alpha_deg',90); 

Phys_Area = struct('shape','HalfSpace_FMT','N',[40;40],'L1',3,'L2',3, ...
                       'y2wall',0,'N2bound',10,'h',1,'L2_AD',1,'alpha_deg',90); 


Sub_Area = struct('shape','Box','y1Min',-10,'y1Max',10,'N',[20,20],...
                      'y2Min',0.5,'y2Max',1);
                   
% Plot_Area = struct('y1Min',-3,'y1Max',3,'N1',50,...
%                        'y2Min',0.5,'y2Max',10,'N2',50);


Plot_Area = struct('y1Min',-3,'y1Max',3,'N1',30,...
                       'y2Min',0.5,'y2Max',4,'N2',30);
                   
% Fex_Num   = struct('Fex','FMTRosenfeld',...
%                        'Ncircle',10,'N1disc',10,'N2disc',10);

Fex_Num   = struct('Fex','FMTRoth',...
                       'Ncircle',20,'N1disc',20,'N2disc',20);


% Fex_Num   = struct('Fex','FMTRosenfeld_3DFluid',...
%                        'Ncircle',10,'N1disc',10,'N2disc',10);

%eq_Num    = struct('eqSolver','Newton','NewtonLambda1',0.7,'NewtonLambda2',0.7);
eq_Num = struct('eqSolver','fsolve');
                   
PhysArea = {Phys_Area, Phys_Area, Phys_Area, Phys_Area, Phys_Area};

SubArea  = {Sub_Area, Sub_Area, Sub_Area, Sub_Area, Sub_Area};

PlotArea = {Plot_Area, Plot_Area, Plot_Area, Plot_Area, Plot_Area};

FexNum   = {Fex_Num, Fex_Num, Fex_Num, Fex_Num, Fex_Num};

V2Num    = {[],[],[],[],[]};

eqNum    = {eq_Num,eq_Num,eq_Num,eq_Num,eq_Num};

HINum    = {[], ...
            struct('N',[20;20],'L',2,'HI11','noHI_2D','HI12','Oseen_2D_noConv', ...
                      'HIPreprocess', 'RotnePragerPreprocess2D', ...
                      'HIWallFull',true,'doConv',false,...
                      'Wall','SelfWallTermZero'), ...
            struct('N',[20;20],'L',2,'HI11','noHI_2D','HI12','FullWallHI_2D_noConv', ...
                      'HIPreprocess', 'RotnePragerPreprocess2D',...
                      'HIWallFull',true,'doConv',false,...
                      'Wall','SelfWallTermKN'), ...
            struct('N',[20;20],'L',2,'HI11','noHI_2D','HI12','noHI_2D', ...
                      'HIPreprocess', 'RotnePragerPreprocess2D',...
                      'HIWallFull',true,'doConv',false,...
                      'Wall','SelfWallTermKN'), ...
            struct('N',[20;20],'L',2,'HI11','noHI_2D','HI12','Oseen_2D_noConv', ...
                      'HIPreprocess', 'RotnePragerPreprocess2D',...
                      'HIWallFull',true,'doConv',false,...
                      'Wall','SelfWallTermKN'), ...
           };

DDFTCode = {'DDFTDynamics', 'DDFTDynamics', 'DDFTDynamics', 'DDFTDynamics', 'DDFTDynamics'};
        
doPlots = false;

DDFTParamsNames = {{'PhysArea','SubArea','PlotArea','FexNum','V2Num','eqNum','doPlots'}, ...
                   {'PhysArea','SubArea','PlotArea','FexNum','V2Num','HINum','eqNum','doPlots'}, ...
                   {'PhysArea','SubArea','PlotArea','FexNum','V2Num','HINum','eqNum','doPlots'}, ...
                   {'PhysArea','SubArea','PlotArea','FexNum','V2Num','HINum','eqNum','doPlots'}, ...
                   {'PhysArea','SubArea','PlotArea','FexNum','V2Num','HINum','eqNum','doPlots'}};

HIParamsNamesDDFT={'sigmaH','sigma'};               
               
DDFTName={'No HI','Just Oseen','Full HI','Just Wall','Oseen + Wall'};


% type of DDFT calculations, either 'rv' to include momentum, or 'r' for
% the standard position DDFT
DDFTType={'r','r','r','r','r'};

% whether to do DDFT calculations
%doDDFT={true,true,true,true,false};
doDDFT={true,false,true,false,false};

% do we load and save the DDFT data
loadDDFT={true,true,true,true,true};
%loadDDFT={false,false};

DDFTColour = {{'r'},{'b'},{'g'},{'m'},{'c'}};

%--------------------------------------------------------------------------
% Plotting setup
%--------------------------------------------------------------------------

plotType = 'surf';

viewPoint = [-56;7];

% x axis for position and velocity plots
rMin=[-3;0];
%rMax=[3;20];
rMax=[3;4];
pMin=rMin;
pMax=rMax;

% y axis for position and velocity plots
RMin=0;
RMax=0.75;

PMin=[-1;-1];
PMax=[1;1];

% y axis for mean position and velocity plots
RMMin=[-3;5];
RMMax=[3;7];
PMMin=[-1;-1];
PMMax=[1;1];

% number of bins for histograming of stochastic data
nBins=[40;40];

% determine which movies/plots to make
% distribution movies/plots
doMovieGif     = false;          % .gif movie
doMovieAvi     = false;
doPdfs         = true;
doInitialFinal = false;
doMeans        = false;
doEquilibria   = false;

sendEmail = false;
