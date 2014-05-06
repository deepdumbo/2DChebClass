clear all

%--------------------------------------------------------------------------
% Set up necessary paths
%--------------------------------------------------------------------------

AddPaths();

%--------------------------------------------------------------------------
% Choose input file
%--------------------------------------------------------------------------

inputFile='APS12HS50';

%--------------------------------------------------------------------------
% Get parameters from input file
%--------------------------------------------------------------------------

eval(inputFile);

%--------------------------------------------------------------------------
% Combine all variables in workspace into a structure for easy access
%--------------------------------------------------------------------------

vars = evalin('base','whos');
for iVar = 1:length(vars)
    optsStruct.(vars(iVar).name) = evalin('base',vars(iVar).name);
end

%--------------------------------------------------------------------------
% Run the preprocessor
%--------------------------------------------------------------------------

optsStruct=preProcess(optsStruct);

if (~optsStruct.anyStoc && ~optsStruct.anyDDFT)
    error('dynamicsComparison:noCalculations', ...
            'No calculations to be run!')
end

%--------------------------------------------------------------------------
% Collate physical information
%--------------------------------------------------------------------------

[optsPhys,optsPhysDDFT] = getOptsPhys(optsStruct);

%--------------------------------------------------------------------------             
% Collate options for stochastic and DDFT calculations
%--------------------------------------------------------------------------

optsStoc = getOptsStoc(optsStruct);

optsNumDDFT = getOptsDDFT(optsStruct);

%--------------------------------------------------------------------------
% Collate options for plotting
%--------------------------------------------------------------------------
   
[optsPlot,optsPlotParticles] = getOptsPlot(optsStruct);

%--------------------------------------------------------------------------
% Stochastic calculation
%--------------------------------------------------------------------------

if(~isempty(optsStoc))  
    stocStruct = doStochastics(optsPhys,optsStoc);
else
    stocStruct = struct([]);
end

%--------------------------------------------------------------------------
% DDFT calculation
%--------------------------------------------------------------------------

if(~isempty(optsNumDDFT))
    DDFTStruct = doDDFTs(optsNumDDFT,optsPhysDDFT,optsPlot);
else
    DDFTStruct = struct([]);
end

%--------------------------------------------------------------------------
% Plotting
%--------------------------------------------------------------------------

%oldPath = path;
% if(~isempty(optsNumDDFT))
%     DDFTDir= ['DDFT' filesep optsNumDDFT(1).DDFTDir];
%     % add DDFTDir and all subfolders to path
%     addpath(genpath(DDFTDir))
%     rmpath(['DDFT' filesep optsNumDDFT(1).DDFTDir filesep 'Potentials']);
% end

% in case doPlots is a variable from anything
if(exist('doPlots','var'))    
    clear('doPlots');
end

if(optsStruct.anyPlots || optsStruct.anyPlotsP)
   doPlots(stocStruct,DDFTStruct,optsStoc,optsNumDDFT,optsPlot,optsPlotParticles,optsPhys);
end

%doPlots(stocStruct,DDFTStruct,optsPlot,optsPlotParticles,fileStruct,optsStruct,optsPhys);

%path(oldPath);

%--------------------------------------------------------------------------
% Restore path
%--------------------------------------------------------------------------

%rmPaths();
