% function soc = SOCfromOCVtemp(ocv,temp,model)
%
% Computes an approximate state of charge from the fully rested open-
% circuit voltage of a cell at a given temperature point. This is NOT an
% exact inverse of the OCVfromSOCtemp function due to how the computations
% are done, but it is "fairly close."
%
% Inputs: ocv = scalar or matrix of cell open circuit voltages
%        temp = scalar or matrix of temperatures at which to calc. OCV
%       model = data structure produced by processDynamic
% Output: soc = scalar or matrix of states of charge -- one for every
%               soc and temperature input point

% Copyright (c) 2015 by Gregory L. Plett of the University of Colorado 
% Colorado Springs (UCCS). This work is licensed under a Creative Commons 
% Attribution-NonCommercial-ShareAlike 4.0 Intl. License, v. 1.0.
% It is provided "as is", without express or implied warranty, for 
% educational and informational purposes only.
%
% This file is provided as a supplement to: Plett, Gregory L., "Battery
% Management Systems, Volume I, Battery Modeling," Artech House, 2015.

function soc=SOCfromOCVtemp(ocv,temp,model)
  ocvcol = ocv(:); % force ocv to be column vector
  OCV = model.OCV(:); % force to be column vector
  SOC0 = model.SOC0(:); % force to be column vector
  SOCrel = model.SOCrel(:); % force to be column vector
  if isscalar(temp), % replicate a scalar temperature for all ocvs
    tempcol = temp*ones(size(ocvcol)); 
  else % force matrix temperature to be column vector
    tempcol = temp(:); 
    if ~isequal(size(tempcol),size(ocvcol)),
      error(['Function inputs "ocv" and "temp" must either have same '...
        'number of elements, or "temp" must be a scalar']);
    end    
  end
  diffOCV=OCV(2)-OCV(1); % spacing between OCV points - assume uniform
  soc=zeros(size(ocvcol)); % initialize output to zero
  I1=find(ocvcol <= OCV(1)); % indices of ocvs below model-stored data
  I2=find(ocvcol >= OCV(end)); % and of ocvs above model-stored data
  I3=find(ocvcol > OCV(1) & ocvcol < OCV(end)); % the rest of them
  I6=isnan(ocvcol); % if input is "not a number" for any locations

  % for ocvs lower than lowest voltage, extrapolate off low end of table
  if ~isempty(I1),
    dz = (SOC0(2)+tempcol.*SOCrel(2)) - (SOC0(1)+tempcol.*SOCrel(1));
    soc(I1)= (ocvcol(I1)-OCV(1)).*dz(I1)/diffOCV + ...
             SOC0(1)+tempcol(I1).*SOCrel(1);
  end
  
  % for ocvs higher than highest voltage, extrapolate off high end of table
  if ~isempty(I2),
    dz = (SOC0(end)+tempcol.*SOCrel(end)) - ...
         (SOC0(end-1)+tempcol.*SOCrel(end-1));
    soc(I2) = (ocvcol(I2)-OCV(end)).*dz(I2)/diffOCV + ...
              SOC0(end)+tempcol(I2).*SOCrel(end);
  end
  
  % for normal ocv range, manually interpolate (10x faster than "interp1")
  I4=(ocvcol(I3)-OCV(1))/diffOCV; % using linear interpolation
  I5=floor(I4); I45 = I4-I5; omI45 = 1-I45;
  soc(I3)=SOC0(I5+1).*omI45 + SOC0(I5+2).*I45;
  soc(I3)=soc(I3) + tempcol(I3).*(SOCrel(I5+1).*omI45 + SOCrel(I5+2).*I45);
  soc(I6) = 0; % replace NaN OCVs with zero SOC
  soc = reshape(soc,size(ocv)); % output is same shape as input