function dVdT = entropyvariation(soc)

load entropy.mat

dVdT = interp1(SOCs,dOCVdT,soc);

end