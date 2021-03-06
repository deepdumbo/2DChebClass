function [z,dz,dx,ddx,dddx,ddddx] = QuadMapAB(x,L,zMin,zMax)
%sqrt(1/2) -> hS12
%1  -> zMin
%-1 -> zMax
%
% Map1: SqrtMap: [-1,1] -> [-L,L]
% Map2: f      : [-L,L] -> [zMin,zMax],  f(z) = (zMin+zMax)/2 + z

    if( ((zMin == -inf) && (zMax ~= inf)) || ((zMin ~= -inf) && (zMax == inf)))
        err = MException('SqrtMapAB:zMinMaxOutofRange', ...
                    'zmin or zmax are inf, but not both');
        throw(err);
    end

    LD                        = (zMax - zMin)/2;
    [z1,dz,dx,ddx,dddx,ddddx] = QuadMap(x,L/2,LD);
    
    if( (zMin == -Inf) && (zMax == Inf) )
        z  = z1;
    else
        z  = (zMax + zMin)/2 + z1;
    end

end