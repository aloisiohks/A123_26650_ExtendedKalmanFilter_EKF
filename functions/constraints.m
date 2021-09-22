function [ M, gamma ] = constraints( dx, linMatrices, mpcData)

    Np = mpcData.Np;
    Nc = mpcData.Nc;
    Sigma = tril(ones(mpcData.Nc,mpcData.Nc));
    model = mpcData.model; 
    
    Am = linMatrices.A;
    Bm = linMatrices.B;
   
    C_v = linMatrices.C_v;
    D_v = linMatrices.D_v;
    C_Tc = linMatrices.C_Tc;
    D_Tc = linMatrices.D_Tc;
    
    
    [Phi_Tc,G_Tc,~] = predMat(Am,Bm,C_Tc,D_Tc,Nc,Np);
    [Phi_v,G_v,~] = predMat(Am,Bm,C_v,D_v,Nc,Np);

    
    M = [ 
                  Sigma;         % i  < i_max
                 -Sigma;         % i  > i_min
                  G_v;         % v  < v_max
                  G_Tc;        % Tc < Tc_max
             
         ] ;
     
    OCV =  OCVfromSOCtemp(dx(1),dx(4),model); 
    u_max=0;
    u_min = - mpcData.const.u;
    gamma = [ 
                 u_max*ones(Nc,1) - mpcData.uk_1*ones(Nc,1);
                 -u_min*ones(Nc,1) + mpcData.uk_1*ones(Nc,1);
                  mpcData.const.v_max*ones(Np ,1) - Phi_v*dx - (OCV)*ones(Np,1) ;
                   mpcData.const.tc_max - Phi_Tc*dx ;


            ];
    

end

