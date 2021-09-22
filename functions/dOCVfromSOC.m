% Find dOCV/dz at SOC = z from {SOC,OCV} data
function dOCVz = dOCVfromSOC(SOC,OCV,z)
dZ = SOC(2) - SOC(1); % Find spacing of SOC vector
dUdZ = diff(OCV)/dZ; % Scaled forward finite difference
dOCV = ([dUdZ(1) dUdZ] + [dUdZ dUdZ(end)])/2; % Avg of fwd/bkwd diffs
dOCVz = interp1(SOC,dOCV,z); % Could make more efficient than this...