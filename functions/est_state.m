
function [xhat,vhat,OCV] = est_state(xhat,model,ik,ik_old,Tfk,OCV_1,v_1,deltaT) 


temp = xhat(4) -273.15; 

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

zk = xhat(1);
irk = xhat(2);
hk = xhat(3);
% Compute output equation
OCV = OCVfromSOCtemp(zk,temp,model);
vk = OCV - irk*R - ik_old*R0 + M*hk - M0*sign(ik_old);


A_RC = exp(-deltaT/RC);
A_HK = exp(-abs(ik_old*eta*deltaT/(3600*Q)));

A = [1 0 0  0 0 ;...
     0 A_RC 0 0 0 ;...
     0 0 A_HK 0 0 ;...
     0 0  0 (1-deltaT/Rc/Cc)  (deltaT/Rc/Cc) ;...
     0 0 0 (deltaT/Rc/Cs)     (1 - deltaT/Rc/Cs - deltaT/Ru/Cs) ;...
     ];

B = [-deltaT*eta/(3600*Q), 0,  0; ...
    (1-A_RC), 0, 0; ...
    0, (A_HK-1), 0;...
    (OCV-vk)*deltaT/Cc, 0, 0;...
    0,  0 , deltaT/Ru/Cs;...
   ];
    
xhat = A*xhat + B*[ik_old;sign(ik_old);Tfk];

zkhat = xhat(1);
irhat = xhat(2);
hk = xhat(3);

OCV = OCVfromSOCtemp(zkhat,xhat(4) -273.15,model);
vhat = OCV + M*hk  - R*irhat - R0*ik - M0*sign(ik);

end