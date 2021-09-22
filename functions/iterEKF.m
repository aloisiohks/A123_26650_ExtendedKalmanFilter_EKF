% function [linMatrices, xhat_plus, bounds, ekfData] = iterEKF(voltage, uk, xhat_plus, tk, model, cellConfig, ekfData)
%INTEREKF Summary of this function goes here
%   Detailed explanation goes here
function [linMatrices, xhat_plus, ekfData,vhat] = iterEKF(voltage,Tsk, uk,Tfk, xhat_plus, model,ekfData)
    % Obtain model-blended state-space matrices
%     tic
    uk_1 = ekfData.uk_1;
    
    OCV_1 = ekfData.OCV_1;
    v_1 = ekfData.v_1;
    deltaT = ekfData.deltaT;
    
   [linMatrices] = linMat(xhat_plus,model,uk_1,deltaT);
    Ahat = linMatrices.A; Bhat = linMatrices.Bhat; 
    Chat = linMatrices.Chat;  Dhat = linMatrices.Dhat;  
     
%     obs = obsv(Ahat(1:3,1:3),Chat(1,1:3));
%     cond = rcond(obs);
    
    SigmaX = ekfData.SigmaX;
    SigmaW = ekfData.SigmaW;
    SigmaV = ekfData.SigmaV;
    
    % Step 1a: State estimate time update
    [xhat_minus,vhat,OCV] = est_state(xhat_plus,model,uk,uk_1,Tfk,OCV_1,v_1,deltaT); 
        
    % Step 1b: Error covariance time update
    SigmaX = Ahat*SigmaX*Ahat' + Bhat*SigmaW*Bhat';
    SigmaX = makePositive(SigmaX);
    
    % Step 1c: Output prediction
    % Computed in Step 1a
    
    % Step 2a: Kalman gain calculation
    
    SigmaY = Chat*SigmaX*Chat' + Dhat*SigmaV*Dhat';
    
    L = SigmaX*Chat'/SigmaY;

    % Step 2b: State estimate measurement update
    residual = [voltage - vhat;Tsk-xhat_minus(5)];

    xhat_plus = xhat_minus + L*residual;
    
    % Step 2c: Error covariance measurement update
    SigmaX = SigmaX - L*SigmaY*L';
    SigmaX = makePositive(SigmaX);

%     % Step 3a: Compute bounds
%     [bounds,variables] = computeBounds(Chat,Dhat,tk,SigmaX,model,...
%         cellConfig,ekfData,variables);
    
    % Update ekf related variables
    ekfData.uk_1 = uk;
    ekfData.Tf_1 = Tfk;
    ekfData.prior_SOC = xhat_plus(1);
    ekfData.SigmaX = SigmaX;
    ekfData.OCV_1 = OCV;
    ekfData.v_1 = vhat;
    ekfData.vkbounds = 3*sqrt(Chat(1,:)*SigmaX*Chat(1,:)' + Dhat*SigmaV(1,1)*Dhat');
    ekfData.soc_bounds = 3*sqrt(SigmaX(1,1));
    ekfData.Tc_bounds = 3*sqrt(SigmaX(4,4));
    ekfData.Ts_bounds = 3*sqrt(SigmaX(5,5));

%     toc
%     disp('iterEKF')
end

function y = makePositive(x)
    % Make sure x is neither NaN nor Inf
    if all(isfinite(x))
        [~,S,V] = svd(x);
        HH = V*S*V';
        y = (x + x' + HH + HH')/4;
    else
        y = x;
    end
end
