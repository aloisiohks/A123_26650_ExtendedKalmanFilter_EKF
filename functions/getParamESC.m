function theParam = getParamESC(paramName,temp,model)
% function theParam = getParam(paramName,temperature,model)
%
% This function returns the values of the specified ESC cell-model
% parameter 'paramName' for the temperatures in 'temperature' for the 
% cell model data stored in 'model'.  'paramName' may be one of:
%    'QParam', 'RCParam', 'RParam', 'R0Param', 'MParam' or 'GParam' 
% (not case sensitive).

temp = min(temp,max(model.temps)); % prohibit NaNs!
temp = max(temp,min(model.temps));
if length(model.temps)>1,
  ind = find(model.temps == temp);
  if ~isempty(ind), % avoid call to (slow) interp1 whenever possible
    switch upper(paramName)
    case 'QPARAM',
      theParam = model.QParam(ind);
    case 'RCPARAM',
      theParam = model.RCParam(ind,:);
    case 'RPARAM',
      theParam = model.RParam(ind,:);
    case 'R0PARAM',
      theParam = model.R0Param(ind);
    case 'MPARAM',
      theParam = model.MParam(ind);
    case 'M0PARAM',
      theParam = model.M0Param(ind);
    case 'GPARAM',
      theParam = model.GParam(ind);
    case 'ETAPARAM',
      theParam = model.etaParam(ind);
    otherwise
      error('Bad argument to "paramName"');
    end
  else    
    switch upper(paramName) % okay, we've got to call (slow) interp1
      case 'QPARAM',
        theParam = interp1(model.temps,model.QParam,temp,'spline');
      case 'RCPARAM',
        theParam = interp1(model.temps,model.RCParam,temp,'spline');
      case 'RPARAM',
        theParam = interp1(model.temps,model.RParam,temp,'spline');
      case 'R0PARAM',
        theParam = interp1(model.temps,model.R0Param,temp,'spline');
      case 'MPARAM',
        theParam = interp1(model.temps,model.MParam,temp,'spline');
      case 'M0PARAM',
        theParam = interp1(model.temps,model.M0Param,temp,'spline');
      case 'GPARAM',
        theParam = interp1(model.temps,model.GParam,temp,'spline');
      case 'ETAPARAM',
        theParam = interp1(model.temps,model.etaParam,temp,'spline');
      otherwise
        error('Bad argument to "paramName"');
    end
  end
else
  switch upper(paramName)
  case 'QPARAM',
    theParam = model.QParam;
  case 'RCPARAM',
    theParam = model.RCParam;
  case 'RPARAM',
    theParam = model.RParam;
  case 'R0PARAM',
    theParam = model.R0Param;
  case 'MPARAM',
    theParam = model.MParam;
  case 'M0PARAM',
    theParam = model.M0Param;
  case 'GPARAM',
    theParam = model.GParam;
  case 'ETAPARAM',
    theParam = model.etaParam;
  otherwise
    error('Bad argument to "paramName"');
  end
end
