function [linMatrices] = linMat(xhat,model,ik,deltaT)


dOCVdT = interp1(model.SOCs,model.dOCVdT,xhat(1)); 
xhat(1) = min(1.0,max(-0.05,xhat(1)));
zk = xhat(1);   
irk = xhat(2);   
hk = xhat(3);
Tc = xhat(4);
Ts = xhat(5);



temp = Tc-273.15;


R = getParamESC('RParam',temp,model);
RC = getParamESC('RCParam',temp,model);    
eta = getParamESC('etaParam',temp,model);  
Q = getParamESC('QParam',temp,model); 
M = getParamESC('MParam',temp,model); 
M0 = getParamESC('M0Param',temp,model); 
R0 = getParamESC('R0Param',temp,model); 
Rc = model.Rc;
Cc = model.Cc;
Cs = model.Cs;
Ru = model.Ru;

nxhat = length(xhat);
Am = zeros(length(xhat),length(xhat));

zkInd = 1; irkInd = 2;  hkInd = 3; TcInd = 4; TsInd = 5;

n = eta;

A_RC = exp(-deltaT/RC);
A_HK = exp(-abs(ik*n*deltaT/(3600*Q)));

Am(zkInd,zkInd) = 1;
Am(irkInd,irkInd) = A_RC;
Am(hkInd,hkInd) = exp(-abs(ik*n*deltaT/(3600*Q)));

Am(TcInd,irkInd) = (deltaT/Cc)*R*ik;
Am(TcInd,hkInd) = -M*ik*deltaT/Cc;
Am(TcInd,TcInd) = (1 - deltaT/Rc/Cc );
Am(TcInd,TsInd) = deltaT/Rc/Cc;

Am(TsInd,TcInd) = deltaT/Rc/Cc;
Am(TsInd,TsInd) = (1 - deltaT/Rc/Cs - deltaT/Ru/Cs);




Bm = zeros(length(xhat),1);  Bd1 = Bm;  Bd2 = Bm;
Bm(zkInd) = -deltaT*n/(3600*Q);
Bm(irkInd) = 1 - A_RC;  % B_RC
Bm(TcInd) = (deltaT/Cc)*(R*irk +2*R0*ik - M*hk );

Bd1(hkInd) = -abs(deltaT*n/(3600*Q))*A_HK...
              *(1+sign(ik)*hk);
Bd2(TsInd) = deltaT/Ru/Cs;


Bhat = [Bm zeros(length(xhat),2)];
Bhat = [(Bm + Bd1) Bd2 ];


Chat = zeros(2,length(xhat));
dOCVdSOC = dOCVfromSOC(model.SOC,model.OCV0,zk);
Chat(1,:) = [dOCVdSOC, -R, M , 0 , 0];
Chat(2,:) = [0, 0, 0, deltaT/Rc/Cc, (1 - deltaT/Rc/Cs - deltaT/Ru/Cs)];
C_v = [dOCVdSOC, -R, M , 0 , 0];
C_z = [1  0 0 0 0 ];
C_Tc = [0 0 0 1 0 ];

Dhat = 1;
Dv = -R0;
D_Tc = 0;
Dz =0;


linMatrices.A = Am;
linMatrices.B = Bm + Bd1;
linMatrices.Bd1 = Bd1;
linMatrices.Bd2 = Bd2;
linMatrices.Bhat = Bhat;
linMatrices.Chat = Chat;
linMatrices.Dhat = Dhat;
linMatrices.C_v = C_v;
linMatrices.C_z = C_z;
linMatrices.C_Tc = C_Tc;
linMatrices.D_v = Dv;
linMatrices.D_z = Dz;
linMatrices.D_Tc = D_Tc;
linMatrices.dOCVdSOC = dOCVdSOC;

end
