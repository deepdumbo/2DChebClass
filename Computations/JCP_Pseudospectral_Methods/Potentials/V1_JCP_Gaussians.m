function [VBack_S,VAdd_S,VGeom_S]=V1_JCP_Gaussians(y1S,y2S,t,optsPhys)

V0=optsPhys.V0;
y10=optsPhys.y10;
y20=optsPhys.y20;

tau=optsPhys.tau;

%--------------------------------------------------------------------------   

VBack        = zeros(size(y1S));

DVBackDy1    = zeros(size(y1S));
DVBackDy2    = zeros(size(y1S));

VBack_S = struct('V',VBack,...
            'dy1',DVBackDy1,'dy2',DVBackDy2,...
            'grad',[DVBackDy1;DVBackDy2]);

%--------------------------------------------------------------------------
        
t = t/tau;

tSwitch = exp(-t^2);

VAdd        = V0.*((y1S-y10*tSwitch).^2 + (y2S-y20*tSwitch).^2);

VAdd(abs(y1S)==inf | abs(y2S)==inf) = 0;

DVAddDy1    = 2*V0.*(y1S-y10*tSwitch);
DVAddDy2    = 2*V0.*(y2S-y20*tSwitch);

DVAddDy1(abs(y1S)==inf | abs(y2S)==inf) = 0;
DVAddDy2(abs(y1S)==inf | abs(y2S)==inf) = 0;

VAdd_S  = struct('V',VAdd, ...
            'dy1',DVAddDy1,'dy2',DVAddDy2,...
            'grad',[DVAddDy1;DVAddDy2]);

VGeom_S = V1_Box(y1S,y2S,t,optsPhys);

end