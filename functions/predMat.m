function [G,Phi,augMatrices] = predMat(Am,Bm,Cm,D,Nc,Np)
% tic
% n = number of rows
% m = number of columms;

[nA,mA] = size(Am);
[nB,mB] = size(Bm);
[nC,mC] = size(Cm);
[nD,mD] = size(D);

A = zeros(nA+mB,mA+mB);
A(1:nA,1:mA) = Am;
A(1:nA,nA+1:nA+mB)=Bm;
A(nA+1:end,mA+1:end)=eye(mB);
B = zeros(nA+mB,1);
B(nA+mB,end) = 1;

C = zeros(1,mA+mB);
C(1,1:mC) = Cm;
C(1,mA+1:end) = D;

G = C*A;

for k=2:Np
    G = [G; C*A^(k)];
end


ry = zeros(1,Nc);
ry(1,1) = C*B;

cy = C*B;

for powers_2 = 1:Np-1
   
    cy = [cy; C*(A^powers_2)*B];
end

Phi = toeplitz(cy,ry);

%     G = G(2:end,:);
%     Phi = Phi(2:end,:);

augMatrices.A = A;
augMatrices.B = B;
augMatrices.C = C;
% toc
% disp('predMat')
end
