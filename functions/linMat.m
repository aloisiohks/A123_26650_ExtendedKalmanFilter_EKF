function [linMatrices] = linMat(xhat,mpcData)

xhat(1) = min(1.0,max(-0.05,xhat(1)));
zk = xhat(1);   
irk = xhat(2);   
hk = xhat(3);
temp = xhat(4) ;

model = mpcData.model;
ik = mpcData.uk_1;
deltaT = mpcData.deltaT;
% sgn = mpcData.sgn;

R = getParamESC('RParam',temp,model);
RC = getParamESC('RCParam',temp,model);    
eta = getParamESC('etaParam',temp,model);  
Q = getParamESC('QParam',temp,model); 
M = getParamESC('MParam',temp,model); 
M0 = getParamESC('M0Param',temp,model); 
R0 = getParamESC('R0Param',temp,model); 
Rc = model.Rc;
Ru = 1.4;
Cc = model.Cc;
Cs = model.Cs;



nxhat = length(xhat);
Am = zeros(length(xhat),length(xhat));

zkInd = 1; irkInd = 2;  hkInd = 3; TcInd = 4; TsInd = 5;
n = eta;

A_RC = exp(-deltaT/RC);
A_HK = exp(-abs(ik*n*deltaT/(3600*Q)));

Am(zkInd,zkInd) = 1;             % SOC 
Am(irkInd,irkInd) = A_RC;        % RC pair state
Am(hkInd,hkInd) = exp(-abs(ik*n*deltaT/(3600*Q)));  % Hysteresis state
% 
Am(TcInd,irkInd) = (deltaT/Cc)*R*ik;   % Contribuition of diffusion voltage to temperature
Am(TcInd,hkInd) = -M*ik*deltaT/Cc;     % Contribuition of diffusion voltage to hysteresis
Am(TcInd,TcInd) = (1 - deltaT/Rc/Cc);  % Core temperature state
Am(TcInd,TsInd) = deltaT/Rc/Cc;        % Contribuition of core temperature to surface temperature

Am(TsInd,TcInd) = deltaT/Rc/Cc;        % Contribuition of surafe temperature to core temperature
Am(TsInd,TsInd) = (1 - deltaT/Rc/Cs - deltaT/Ru/Cs);  % Sruface temperature state

B_ik = zeros(length(xhat),1);  
B_ik(zkInd) = -deltaT/(3600*Q);
B_ik(irkInd) = 1 - A_RC;  % B_RC

B_ik(hkInd) = -abs(deltaT*n/(3600*Q))*A_HK...
              *(1+sign(ik)*hk);
B_ik(TcInd) = (deltaT/Cc)*(R*irk +2*R0*ik - M*hk + M0*sign(ik));

B_Tf = zeros(length(xhat),1);  
B_Tf(TsInd) = deltaT/Ru/Cs;

B_Tc = zeros(length(xhat),1);  
B_Tc(TcInd) = -(deltaT/Cc)*(R0*ik^2);

B_hk = zeros(length(xhat),1);  
% B_hk(hkInd) = 1- A_HK;
B_hk(TcInd) = (deltaT/Cc)*(M0)*ik;

Bm = [B_Tf B_Tc B_hk  B_ik];


C_v = [0, -R, M , 0 , 0];
C_z = [1  0 0 0 0];
C_Tc = [0 0 0 1 0];


Dv = [0 0 -M0 -R0];
D_Tc = [0 0 0 0];
Dz =[0 0 0 0];


linMatrices.A = Am;
linMatrices.B = Bm;
linMatrices.C_v = C_v;
linMatrices.C_z = C_z;
linMatrices.C_Tc = C_Tc;
linMatrices.D_v = Dv;
linMatrices.D_z = Dz;
linMatrices.D_Tc = D_Tc;


end
