clear all; close all;

R      = 1;
bottom = 0;

figure('color','white','Position',[0 0 800 500]);
shape = struct('y2Min',bottom,'N',[10,10],'L1',1,'L2',2);
HS    = HalfSpace(shape);
plot([-10,10],[bottom,bottom],'b--','LineWidth',2);

xlim([-5,5])
ylim([-1.3 2])
ylim([bottom-R,bottom+3*R])
xlabel('$x$','Interpreter','Latex','fontsize',20);
ylabel('$y$','Interpreter','Latex','fontsize',20);
axis equal
set(gca,'fontsize',20);


[y10,y20] = ginput(1);   
while(y20 > bottom - R)
    
    Origin = [y10,y20];
    N      = [10,10];
    sphere = true;
    DC     = Disc(v2struct(Origin,R,N,sphere));   

    hold on
    area = Intersect(HS,DC);
    
    disp(['Area is: ',num2str(area.area),' with error from integration vector ',num2str(sum(area.int)-area.area)]);
    %disp(['Area from Int is: ',num2str(sum(area.int))]);

    if(~isempty(area))                       
        scatter(area.pts.y1_kv,area.pts.y2_kv,'r');
        %DC.PlotGrid();
    end
    
	xlim([-5,5])
    ylim([-1.3 2])
    ylim([bottom-R,bottom+3*R])
    xlabel('$x$','Interpreter','Latex','fontsize',20);
    ylabel('$y$','Interpreter','Latex','fontsize',20);
    set(gca,'fontsize',20);
    axis equal

    [y10,y20] = ginput(1);   
end
ylim([-1 3]);
print2eps(['HalfSpaceVsDisc_CollocationPoints'],gcf);        
saveas(gcf,['HalfSpaceVsDisc_CollocationPoints.fig']);   