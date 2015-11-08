function [VBack_S,VAdd_S]=V1_Test_Disc_Cart(x,y,t,optsPhys)

% stoc: inputs are (x,[],t,optsPhys)
% ddft: inputs are (r,theta,t,optsPhys)

    [~,r] = cart2pol(x,y);

    V0   = optsPhys.V0;
    grav = optsPhys.grav;


    VBack        = V0*r.^2;

    DVBackDy1    = 2*V0*x;
    DVBackDy2    = 2*V0*y;

    VBack_S = struct('V',VBack,...
                    'dy1',DVBackDy1,'dy2',DVBackDy2,...
                    'grad',[DVBackDy1;DVBackDy2]);

    VAdd           = -grav*x*(1-exp(-t^2));
    VAdd(r == inf) = 0;
    VAdd_S         = struct('V',VAdd);

end