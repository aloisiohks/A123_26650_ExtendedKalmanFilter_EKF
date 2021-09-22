function [x,lambda,m] = hildreth(E,F,M,gamma,lambda,maxHild)
% Implementation of Hildreth's quadratic algorithm

    % J = 1/2*x'*E*x + x'*F + lambda'*(M*x-gamma)
    % x = -E\(F+M_act'*lambda_act)
    % J = -1/2*lambda'*H*lambda - lambda'*K-1/2*F'*E\F
    % where:
    %    H = M*E\M'
    %    K = gamma + M*E\F
    % System of equations: H*lambda+K=0

    epsilon = 1e-4;

    H = M*(E\M');
    K = (gamma + M*(E\F));
    

    Nconst = length(gamma); % number of contraints
    
    if isempty(lambda)
        lambda = zeros(length(gamma),1);
    else
        old_lambda = lambda;
    end

    for m=1:maxHild
%         m
        
        for i=1:Nconst
%             i
            w = (-1/H(i,i))*(H(i,:)*lambda - H(i,i)*lambda(i) + K(i));
            if w==Inf
                w = 0;
            end
            old_lambda(i) = lambda(i);
            lambda(i) = max(0,w);
        end

        % termination condition
        if(norm(lambda - old_lambda')/norm(lambda) < epsilon)
            break;
        end
    end
    
    active = find(lambda>0);
    x = 0.5*(-E\F - (E\M(active,:)')*lambda(active));
    
end