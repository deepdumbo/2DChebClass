function params = RotnePragerPreprocess(params)

    % these should be nSpecies x nSpecies
    sigma  = params.sigma;
    
    sigmaII = diag(sigma);
    sigmaII = sigmaII(:);
    
    nSpecies = length(sigmaII);
    
    sigma1  = repmat(sigmaII,1,nSpecies);
    sigma2  = sigma1.';
    
    lambda  = max(sigma1,sigma2)./min(sigma1,sigma2);
    
    alpha   = (1+lambda.^2)./(1+lambda).^2;
    
    params.alpha = alpha;
    params.yMin  = sigma; 

    params.yMax = 50;
    
end