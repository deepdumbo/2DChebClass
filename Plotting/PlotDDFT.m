function fig_h = PlotDDFT(input,Bool_Record)
    
    global QuickOutput dirData

    if((nargin < 2) && ~QuickOutput) 
        Bool_Record = false;
        gifFile = [];
    else
        if(isfield(input,'filename'))
            gifFile = [dirData,'\Dynamics\',input.filename,'.gif'];
        elseif(ischar(Bool_Record))
            gifFile = [Bool_Record,'.gif'];
        else
            gifFile = getMovieFile('Movie');    
        end        
    end
    
    %*****************************
    %Initialization of Data     
    v2struct(input);
    v2struct(data);
    
%     if(isfield(optsNum.PhysArea,'N'))
%         N1 = optsNum.PhysArea.N(1);
%         N2 = optsNum.PhysArea.N(2);
%     else
%         N1 = optsNum.PhysArea.N1; N2 = optsNum.PhysArea.N2;
%     end
    plotTimes  = optsNum.plotTimes;          
    
    if(isfield(data,'Subspace'))
        v2struct(Subspace);        
        IP            = shape.SubShapePtsCart(subArea.GetCartPts());
        Int_SubOnFull = subArea.ComputeIntegrationVector()*IP;
        bool_subSp = true;
    else
        bool_subSp = false;
    end
    
    if(size(rho_t,3) == 1)
        %X_s(:,1,:)   = X_t;  X_t = X_s;
        rho_s(:,1,:)   = rho_t;  rho_t = rho_s;
        flux_s(:,1,:)  = flux_t; flux_t = flux_s;        
    end
    nSpecies = size(rho_t,2);
    nRows    = ceil(nSpecies/2)+1;
           
    rho_ic = rho_t(:,:,1);

    fl_norm = 0.1*max(max(max(abs(flux_t))));    
    
    if(exist('optsPlot','var') && isstruct(optsPlot) && isfield(optsPlot,'lineColourDDFT'))
        lineColour=optsPlot.lineColourDDFT;
    else
        lineColour={'r','b','g','k','m'};
    end
    cornerColour=cell(nSpecies,1);
    for iSpecies=1:nSpecies
        cornerColour{iSpecies}='m';
    end        
    
    %**************************************
    %Initialization of figure and screen, and movie
    close all;
    figure       
            
    %*****************************
    if(~isempty(gifFile))%QuickOutput || (islogical(Bool_Record) && Bool_Record) || ischar(Bool_Record))
        
        %(a) Plot Snapshots        
        PlotDDFT_SnapshotsShape(input,[gifFile(1:end-4) '_Snapshots']); 
        fig_h{1} = gcf;
        
        %(b1) Plot Mass evolution
        figure('Color','white','Position', [0 0 800 800]); %Set background color                
        for iSpecies=1:nSpecies            
            rho     = permute(rho_t(:,iSpecies,:),[1 3 2]);
            rho_diff = rho-rho_ic(:,iSpecies)*ones(1,length(plotTimes));
            plot(plotTimes,shape.Int*rho_diff,'Color',lineColour{iSpecies},'linewidth',1.5); hold on; 
            %plot(plotTimes,shape.Int*rho_diff,'o','Color',lineColour{iSpecies}); hold on; 
            if(bool_subSp)
                plot(plotTimes,Int_SubOnFull*rho_diff+accFlux(:,iSpecies)','m','linewidth',1.5);                
                legend('Full Domain','Subdomain','location','NorthWest');
            end
        end
         grid on;
         xlabel('t','fontsize',20);
         ylabel('Mass error','fontsize',20);         
         set(gca,'fontsize',20);                        
         set(gca,'linewidth',1.5);      
                  
         print2eps([gifFile(1:end-4) , '_Mass'],gcf);
         saveas(gcf,[gifFile(1:end-4) , '_Mass.fig']);         
         
        if(QuickOutput)
            return;
        end
         
        %(b2) Plot Mass in Subbox
        if(bool_subSp)
            figure('Color','white','Position', [0 0 800 800]); %Set background color        
            rho     = permute(rho_t(:,1,:),[1 3 2]);
            for iSpecies=1:nSpecies                 
                plot(plotTimes,Int_SubOnFull*rho,'m','linewidth',1.5);                
            end
            grid on;
            xlabel('t','fontsize',20);
            ylabel('Mass','fontsize',20);         
            set(gca,'fontsize',20);                        
            set(gca,'linewidth',1.5);      

            print2eps([gifFile(1:end-4) , '_Mass_SubArea'],gcf);
            saveas(gcf,[gifFile(1:end-4) , '_Mass_SubArea.fig']); 
        end        
         
        %(c) Plot Movie        
        figure('Color','white','Position', [0 0 1500 1000]); %Set background color        
        k = 1; fileNames = [];
        dT = ceil(length(plotTimes)/20);
        T_n_Max = length(plotTimes);
        %for i=1:dT:T_n_Max
        for i=1:T_n_Max
            
            t       = plotTimes(i);

            %Plot Interpolation
            hold off;
            %shape.plot(rho,'contour');  hold on;
            %shape.plotFlux(flux_t(:,1,i),~shape.Ind.bound,fl_norm,0.5,'k'); hold on;            
            for iSpecies=1:nSpecies    
                rho     = rho_t(:,iSpecies,i);
                
                shape.plotFlux(flux_t(:,iSpecies,i),~shape.Ind.bound,fl_norm,0.5,lineColour{iSpecies}); hold on;           

                if(nSpecies > 1)
                    optsPlot.linecolor = lineColour{iSpecies}; 
                else
                    optsPlot.nContours = 5;
                                        
                    drho = optsPhys.rhoLiq_sat - optsPhys.rhoGas_sat;
                    
                    optsPlot.nContours = optsPhys.rhoGas_sat + 0.1*drho;
                    optsPlot.linecolor = 'b';
                    optsPlot.linestyle = '--';
                    shape.plot(rho,'contour',optsPlot);  hold on;  
        
                    optsPlot.nContours = optsPhys.rhoGas_sat + 0.5*drho;
                    optsPlot.linecolor = [0 0.75 0];
                    shape.plot(rho,'contour',optsPlot);  hold on;  
        
                    optsPlot.nContours = optsPhys.rhoGas_sat + 0.9*drho;
                    optsPlot.linecolor = 'r';
                    shape.plot(rho,'contour',optsPlot);  hold on;  
                end                
               % shape.plot(rho,'contour',optsPlot); hold on;                                         

%                  if(nSpecies > 1)
%                      optsPlot.linecolor = lineColour{iSpecies}; 
%                      shape.plot(rho,'contour',optsPlot); hold on;                                         
%                  else
%                                      
%                     optDetails.clabel      = false;  
%                     optDetails.linewidth   = 3;%1.4;  
% 
%                     rhoLiq_sat    = optsPhys.rhoLiq_sat;
%                     rhoGas_sat    = optsPhys.rhoGas_sat;
% 
%                     %optDetails.nContours = [0.1,0.2,0.3,0.4,0.5,0.6,0.7];        
%                     drho = rhoLiq_sat - rhoGas_sat;
% 
%                     optDetails.nContours = rhoGas_sat + 0.1*drho;
%                     optDetails.linecolor = 'b';
%                     optDetails.linestyle = '--';
%                     shape.plot(rho,'contour',optDetails);  hold on;  
% 
%                     optDetails.nContours = rhoGas_sat + 0.5*drho;
%                     optDetails.linecolor = [0 0.75 0];
%                     shape.plot(rho,'contour',optDetails);  hold on;  
% 
%                     optDetails.nContours = rhoGas_sat + 0.9*drho;
%                     optDetails.linecolor = 'r';
%                     shape.plot(rho,'contour',optDetails);  hold on;  
% 
%                  end                                

            end
            %plot([0;0],[i;i]);
            title(['t = ', num2str(round(t))]);               
            set(gca,'fontsize',30);
            set(gca,'linewidth',3);
            %view([2,5,2]);
            
            h = get(gca,'xlabel'); set(h,'fontsize',35);
            h = get(gca,'ylabel'); set(h,'fontsize',35);
            h = get(gca,'title');  set(h,'fontsize',35);
        
            %For gif-recording
            Record(i,gifFile);
            
            %for swf Recording
            fileName = getPDFMovieFile('Movie1',k);
            %fileName = ['Movie1',num2str(k),'.pdf'];
            save2pdf(fileName,gcf);
            k = k+1;
            fileNames = [fileNames,' ',fileName];
        end
        
        disp(['Gif Movie` saved in: ',gifFile]);
        
        str         = gifFile(1:end-4);
        allPdfFiles = [str,'.pdf'];
        swfFile     = [str,'.swf'];

        system(['C:\pdftk.exe ', fileNames ,' cat output ',allPdfFiles]);    
        system(['C:\pdf2swf.exe -s framerate=5 -o ',swfFile,' ', allPdfFiles]);
        system(['copy ',getPDFMovieFile('Movie1',1),' ',str,'POSTER.pdf']);
        system(['del ',fileNames]);       
        disp(['Swf Movie` saved in: ',swfFile]);
        
        return;
    end           
    
    dT = ceil(length(plotTimes)/100);
    for i=1:dT:length(plotTimes)                
        rho     = rho_t(:,:,i);
        t       = plotTimes(i);
                
        %Plot Fluxes
        h1 = subplot(nRows,2,1);    
        cla(h1);
        for iSpecies=1:nSpecies
             optsPlot.linecolor = lineColour{iSpecies}; 
             shape.plotFlux(flux_t(:,iSpecies,i),shape.Ind.bound,fl_norm,1.5,lineColour{iSpecies}); hold on;                  
             shape.plotFlux(flux_t(:,iSpecies,i),~shape.Ind.bound,fl_norm,0.5,lineColour{iSpecies}); hold on;           
             shape.plot(rho(:,iSpecies),'contour',optsPlot); hold on;            
             if(bool_subSp)
                subArea.PlotBorders();
             end                
        end
        title(['t = ', num2str(t),' max(flux) = ',num2str(max(max(abs(flux_t(:,:,i)))))]);
        
%       Check mass conservation
        subplot(nRows,2,2)   
         hold on;
         for iSpecies=1:nSpecies
            rho_diff = (rho(:,iSpecies)-rho_ic(:,iSpecies));
            plot(t,shape.Int*rho_diff,'o','Color',lineColour{iSpecies}); hold on;                                    
            if(bool_subSp)
                plot(t,Int_SubOnFull*rho_diff+accFlux(i,iSpecies),'om');
                legend('Full Domain','Subdomain');
            end
         end
         xlabel('t');
         title(['Mass in the full system: ',num2str(shape.Int*rho)]);                
         
 %         Plot Density profiles         
         hold off;
         for iSpecies=1:nSpecies
            subplot(nRows,2,2+iSpecies);
            shape.plot(rho(:,iSpecies),'SC');
            %view([-2,5,2]);     
            view([2,-5,2]);     
            title(['Species ' num2str(iSpecies)]);
         end

         pause(0.05);        

        
        pause(0.02);        
    end          
    
end