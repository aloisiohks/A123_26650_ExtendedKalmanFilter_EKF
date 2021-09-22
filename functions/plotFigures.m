

time = time;


hFig = figure();
set(hFig, 'Position', [623   215   560   735])

%Charging Current
subplot(411)
plot(time,u_store,'lineWidth',2);hold on;
plot(time,-mpcData.const.u*ones(1,length(time)),'--r','lineWidth',2);
legend('Charging Current','Constraint','Location','Northeast');
xlim([time(1) time(end)]);
grid on; title('Charging Current','fontsize',14);
xlabel('Time [s]','fontsize',14);
ylabel('Current [A]','fontsize',14);


% Voltage
subplot(412)
plot(time,voltage_store,'lineWidth',2);hold on;
plot(time,mpcData.const.v_max*ones(1,length(time)),'--r','lineWidth',2);
legend('Cell Voltage','Constraint');
xlim([time(1) time(end)]);
grid on; title('Voltage','fontsize',14);xlabel('Time [s]','fontsize',14);ylabel('Voltage [V]','fontsize',14);


% SOC
subplot(413)
plot(time,x_store(1,:),'lineWidth',2);hold on;
plot(time,mpcData.const.z_max*ones(1,length(time)),'--r','lineWidth',2);
ylabel('SOC [%]','fontsize',14);
legend('SOC','Constraint');
grid on; title('SOC','fontsize',14);xlabel('Time [s]','fontsize',14);
hold on;
xlim([time(1) time(end)]); ylim([0 mpcData.const.z_max+0.1])


% Temperature
subplot(414)
plot(time,x_store(4,:),'lineWidth',2);
hold on;
plot(time,x_store(5,:),'lineWidth',1.1);hold on;
plot(time,mpcData.const.tc_max*ones(1,length(time)),'--r','lineWidth',2);
xlabel('Time [s]','fontsize',14);ylabel('Temperature [{\circ}C]','fontsize',14);
grid on; title('Cell Temperature','fontsize',14);
legend('Tc - Core Temperature','Ts - Surface temperature','Constraint','location','best');
xlim([time(1) time(end)]);
set(gcf,'color','w');
    