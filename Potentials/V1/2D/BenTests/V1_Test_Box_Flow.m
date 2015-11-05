function [VBack_S,VAdd_S]=V1_Test_Box_Flow(y1S,y2S,t,optsPhys)

V0=optsPhys.V0;
y10=optsPhys.y10;
y20=optsPhys.y20;

L2 = optsPhys.L2;

epsilon = optsPhys.epsilon0;
alpha   = optsPhys.alphaWall;

tau=optsPhys.tau;

%--------------------------------------------------------------------------   

VWall1      = epsilon.*exp(-(y2S.^2)./(alpha.^2));
VWall2      = epsilon.*exp(-((y2S-L2).^2)./(alpha.^2));

DVWall1     = -2*y2S./(alpha.^2).*VWall1;
DVWall2     = -2*(y2S-L2)./(alpha.^2).*VWall2;


VBack        =  VWall1 + VWall2;

DVBackDy1    = zeros(size(y1S));
DVBackDy2    = DVWall1 + DVWall2;

VBack_S = struct('V',VBack,...
            'dy1',DVBackDy1,'dy2',DVBackDy2,...
            'grad',[DVBackDy1;DVBackDy2]);

%--------------------------------------------------------------------------
        
t = t/tau;

tSwitch = exp(-t^2);

%VAdd        = tSwitch*V0.*((y1S-y10).^2 + (y2S-y20).^2);
VAdd        = tSwitch*V0.*((y1S-y10).^2);

VAdd(abs(y1S)==inf | abs(y2S)==inf) = 0;

DVAddDy1    = tSwitch*2*V0.*(y1S-y10);
DVAddDy2    = zeros(size(y2S));

DVAddDy1(abs(y1S)==inf | abs(y2S)==inf) = 0;
DVAddDy2(abs(y1S)==inf | abs(y2S)==inf) = 0;

VAdd_S  = struct('V',VAdd, ...
            'dy1',DVAddDy1,'dy2',DVAddDy2,...
            'grad',[DVAddDy1;DVAddDy2]);

%VGeom_S = V1_Box(y1S,y2S,t,optsPhys);

end