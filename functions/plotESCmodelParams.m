

    figure(1);
    theXlim = [min(model.temps) max(model.temps)];
    subplot(2,4,1); plot(model.temps,model.QParam,'linewidth',1.5)
                    title('Capacity (Ah)'); xlabel('Temperature  [ºC]');
                    grid on; xlim(theXlim)
    subplot(2,4,2); plot(model.temps,1000*model.R0Param,'linewidth',1.5)
                    title('Resistance (m\Omega)');xlabel('Temperature  [ºC]');
                    grid on;  xlim(theXlim)
    subplot(2,4,3); plot(model.temps,1000*model.M0Param,'linewidth',1.5)
                    title('Hyst Magnitude M0 (mV)');xlabel('Temperature  [ºC]');
                    grid on;     xlim(theXlim)
    subplot(2,4,4); plot(model.temps,1000*model.MParam,'linewidth',1.5)
                    title('Hyst Magnitude M (mV)');xlabel('Temperature  [ºC]');
                    grid on;  xlim(theXlim)
    subplot(2,4,5); plot(model.temps,getParamESC('RCParam',...
                    model.temps,model),'linewidth',1.5)
                    title('RC Time Constant (tau)');xlabel('Temperature  [ºC]');
                    grid on;  xlim(theXlim)
    subplot(2,4,6); plot(model.temps,1000*getParamESC('RParam',...
                    model.temps,model),'linewidth',1.5)
                    title('R in RC (m\Omega)');xlabel('Temperature  [ºC]');
                    grid on;  xlim(theXlim)
    subplot(2,4,7); plot(model.temps,abs(model.GParam),'linewidth',1.5) ;xlabel('Temperature  [ºC]');
                    title('Gamma');    
                    grid on;  xlim(theXlim)