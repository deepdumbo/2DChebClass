function HI = JeffreyOnishi12(r,optsPhys)

    sigmaH  = optsPhys.sigmaHS;
    lambda  = optsPhys.lambda;
    fx      = optsPhys.fx;
    nMax    = optsPhys.nMax;
    
    r = abs(r);
    
    rInv    = r.^(-1);
    
    HI=zeros(size(r));
    for n=1:2:nMax
        HI = HI - fx(n)*(sigmaH/2)^n*(1+lambda)^(-n)*rInv.^n;
    end
    
end