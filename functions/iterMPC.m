function [uk, mpcData] = iterMPC(ref,xk_1,mpcData)


    % Load MPC data
    Np = mpcData.Np;
    Nc = mpcData.Nc;
    Ref = ref*ones(Np,1)/100;
    Tf = mpcData.Tf;
    if mpcData.k == 2
        mpcData.uk_1 = -mpcData.const.u;           % u[k-1]
    end
    uk_1 = mpcData.uk_1;
    
    % Obtain matrices from Kalman Filter
    linMatrices = linMat(xk_1,mpcData);
    Az = linMatrices.A;
    Bz = linMatrices.B;
    Cz = linMatrices.C_z;
    Dz = linMatrices.D_z;
    mpcData.linMatrices = linMatrices;

    % Augmented state vector
    dx = [xk_1; Tf ;1; sign(uk_1);uk_1 ];
    
   % Y = Phi*x + G*U
   %Compute SOC prediction matrices
   [Phi,G,Aug_matrices]  = predMat(Az,Bz,Cz,Dz,Nc,Np);
   mpcData.Aug_matrices = Aug_matrices;

   F = -G'*(Ref - Phi*dx );
   
   %Adaptive control weighting
   [~,S,~] = svd(G'*G);
   [m,n] = size(S);
   Ru = (norm(F,2)/(2*mpcData.const.du_max*sqrt(Nc)))-(S(m,n)); mpcData.Ru_ = Ru;
   E = (G'*G + Ru*eye(Nc,Nc));
   DU = -0.5*E\F;

  
   
   [M,gamma] = constraints(dx,linMatrices,mpcData);
   


   Kmpc = inv(G'*G + Ru)*G'*Phi;
   Kmpc = Kmpc(1,:);
   CL = (Aug_matrices.A - Aug_matrices.B*Kmpc);
   [~,poles] = eig(CL);
   poles = diag(poles);
   mpcData.poles = poles;
   mpcData.sv = svd(CL);
   

    if sum(M*DU - gamma > 0) > 0
        [DU,~,m] = hildreth(E,F,M,gamma,[],150);
        mpcData.Hiter=m;
    else
        mpcData.Hiter=0;
    end
    
    du = DU(1);
    uk = du + uk_1;
    
    
    mpcData.Ru = Ru;
    mpcData.uk_1 = uk;
    mpcData.DUk_1 = DU;
    mpcData.E = E;
    mpcData.F = F;
    mpcData.M = M;
    mpcData.gamma = gamma;
    mpcData.J = (Ref - Phi*dx - G*DU)'*(Ref - Phi*dx - G*DU) + DU'*Ru*DU;

end

