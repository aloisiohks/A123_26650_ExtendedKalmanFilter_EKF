%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This software contains the extended Kalman filter algorithm  
% for SOC and temperature estimation for a cylindrical 
% cell A123 26650 2.5 Ah (LPF chemistry)
%
% Copyright (c) 2021 by Aloisio Kawakita de Souza of the
% University of Colorado Colorado Springs (UCCS). This work is licensed
% under a MIT license. It is provided "as is", without express or implied
% warranty, for educational and informational purposes only.
%
% This file is provided as a supplement to: 
%
% [1] Kawakita de Souza, A. (2020). Advanced Predictive Control Strategies for 
% Lithium-Ion Battery Management Using a Coupled Electro-Thermal Model 
% [Master thesis, University of Colorado, Colorado Springs].ProQuest Dissertations Publishing.
% 
% [2] A. K. de Souza, G. Plett and M. S. Trimboli, "Lithium-Ion Battery Charging Control Using 
% a Coupled Electro-Thermal Model and Model Predictive Control," 2020 IEEE Applied Power 
% Electronics Conference and Exposition (APEC), 2020, pp. 3534-3539, 
% doi: 10.1109/APEC39645.2020.9124431.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

clear; close all;
addpath('./functions');

% Load model
load('A123CETmodel.mat');

% Load dataset
load('LabDataset');
time = Data.time'; 
voltage = Data.voltage'; 
current = Data.current'; 
Ts = Data.Ts' + 273.15; 
Tf = Data.Tf' + 273.15; 
tinit = 1; t1 = time(tinit);  t2 = time(end);
deltaT = time(tinit+1) - time(tinit);
t = (t1:deltaT:t2) - t1;
K = 273.15;
current = interp1(time,current,t1:deltaT:t2);
voltage = interp1(time,voltage,t1:deltaT:t2);
Ts = interp1(time,Ts,t1:deltaT:t2);
Tf = interp1(time,Tf,t1:deltaT:t2);


% Initialize EKF
SOC0 =  90;    % Initial SOC guess [%] 
T0 = 25 + 273.15;    % Initial temperature guess [K]
% Covariance matrices
SigmaX0 = diag([1e-3  1e-8 1e-7 1e-6 1e-4 ]);
SigmaV = diag([1e-3 1e-4]);
SigmaW = diag([2e-7 1.6576e-5 ]);
ir0 = 0; hk0 = 0; Tc0 = T0;  Ts0 = T0; 
xhat = [SOC0/100 ir0 hk0 Tc0 Ts0]';
[linMatrices,xekf,ekfData] = initEKF(xhat,SigmaX0,SigmaV,SigmaW,model,deltaT);


% Allocate memory for data storage
N = length(t);
SOC_store = zeros(N,1);
SOC_bounds = zeros(N,1);
vhat_store = zeros(N,1);
voltage_bounds = zeros(N,1);
Tc_store = zeros(N,1);
Ts_store = zeros(N,1);
zkbounds = zeros(N,1);
theta_store = zeros(N,1);
Tcbounds = zeros(N,1);
thetabounds = zeros(N,1);
% Iterate for N seconds
for k = 1:N
        
    % EKF
    [varEkf, xekf, ekfData, vhat] = iterEKF(voltage(k),Ts(k),current(k),Tf(k),xekf,model,ekfData);
    

    SOC_store(k) = xekf(1);
    Tc_store(k) = xekf(4);
    Ts_store(k) = xekf(5);
    vhat_store(k) = vhat;
    
    
    zkbounds(k) = ekfData.soc_bounds;
    Tcbounds(k) = ekfData.Tc_bounds;
    
    
    if(mod(k,100) == 0)
        fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\bProgress: %2d%%\n',round(100*k/N));
    end
end
clc;


figure();
plot(t,current,'linewidth',1.1);
title('Input Current - UDDS');
grid on;
xlim([t(1),t(end)]); ylabel('Current (A)'); xlabel('Time (s)');
plotFormat;


figure();
plot(t,voltage,'linewidth',1.1);grid on;
title('cell voltage');
xlim([t(1),t(end)]); ylabel('Voltage (V)'); xlabel('Time (s)');
plotFormat;



figure();
plot(t,Tc_store-K','linewidth',1.1);hold on;
plot(t,Tc_store+Tcbounds - K,'--r','linewidth',1.1);hold on;
plot(t,Tc_store-Tcbounds - K,'--r','linewidth',1.1);grid on;
legend('Core Temp. - EKF','Error Bounds','location','northwest');
xlim([t(1),t(end)]);
ylabel ('Temperature ({\circ}C)');
xlabel ('Time (s)');title('Core Temperature Estimate')
plotFormat;

figure();
plot(t,100*SOC_store,'linewidth',1.1);
hold on;grid on;
plot(t,100*(SOC_store+zkbounds),'--r','linewidth',1.1);hold on;
plot(t,100*(SOC_store-zkbounds),'--r','linewidth',1.1);
legend('SOC - EKF','Error Bounds');
xlim([t(1),t(end)]);
ylim([0,100]);
xlabel ('Time (s)');
ylabel ('State of charge (%)');
title('State of Charge estimation');
plotFormat;


