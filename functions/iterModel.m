function [v,x,OCV] = iterModel(x, ik,Tfk, model,deltaT)
    % Load constants

temp = x(4) ; % Core temperature   Tc[k-1]    

R = getParamESC('RParam',temp,model);
RC = getParamESC('RCParam',temp,model);    
eta = getParamESC('etaParam',temp,model);  
Q = getParamESC('QParam',temp,model); 
M = getParamESC('MParam',temp,model); 
M0 = getParamESC('M0Param',temp,model); 
R0 = getParamESC('R0Param',temp,model);
Rc = model.Rc;
Ru = model.Ru;
Cc = model.Cc;
Cs = model.Cs;

 
ik(ik<0) = eta*ik(ik<0); % compensate for coulombic efficiency

zk = x(1);
ir = x(2);
hk = x(3);
temp = x(4);  % Core temperature   Tc[k]   
dOCVdT = entropyvariation(zk);
OCV = OCVfromSOCtemp(zk,temp,model);
v = OCV + M*hk -M0*sign(ik) - R*ir - R0*ik;

A_RC = exp(-deltaT/RC);
A_HK = exp(-abs(ik*eta*deltaT/(3600*Q)));

A = [1 0 0  0 0 ;...
     0 A_RC 0 0 0;...
     0 0 A_HK 0 0;...
     0 0  0 (1-deltaT/Rc/Cc+(deltaT/Cc)*(ik*dOCVdT))  (deltaT/Rc/Cc);...
     0 0 0 (deltaT/Rc/Cs)     (1 - deltaT/Rc/Cs - deltaT/Ru/Cs)];



B = [-deltaT/(3600*Q) 0  0; ...
    (1-A_RC) 0 0; ...
    0 (A_HK-1) 0;...
    (-M*hk + M0*sign(ik) + R*ir + R0*ik)*deltaT/Cc 0 0;...
    0  0  deltaT/Ru/Cs];
    
x = A*x + B*[ik;sign(ik);Tfk];


    
    
    
end  
    
    
    
    
