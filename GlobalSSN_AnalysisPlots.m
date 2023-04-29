function [finalCollisions, finalDebris] = GlobalSSN_AnalysisPlots(gssa_model,timeVec)

cumulativeCollisions = cumsum(gssa_model.leo_environment.data.totalCollisions);
finalCollisions = cumulativeCollisions(end);
finalDebris = gssa_model.leo_environment.data.totalDebris(end);

% Analysis plots
xData = years(days(timeVec));

% Total Debris and Tracking Capacity
figure('Color','w'); hold on; box on; grid on;
plot(xData,gssa_model.leo_environment.data.totalDebris,'LineWidth',2);
plot(xData,gssa_model.gssn.data.tracking_capacity,'LineWidth',2);
for iNation = 1:length(gssa_model.nations)
    plot(xData,gssa_model.nations{iNation}.data.trackingCapacity);
end
ax = gca; ax.XLim = round([xData(1) xData(end)]); ax.YLim(1) = 0;
ax.YAxis.Exponent = 0;
title('Tracking');
xlabel('Time (Years)','FontWeight','Bold');
ylabel('Objects','FontWeight','Bold');
lgdStr = strcat({'Nation '},strsplit(num2str(1:length(gssa_model.nations))),{' Tracking Capacity'});
legend([{'Debris','GSSN Tracking Capacity'},lgdStr]);

% Total Debris
figure('Color','w'); hold on; box on; grid on;
plot(xData,gssa_model.leo_environment.data.totalDebris);
ax = gca; ax.XLim = round([xData(1) xData(end)]);
ax.YAxis.Exponent = 0;
title('Total Number of Debris');
xlabel('Time (Years)','FontWeight','Bold');
ylabel('Debris Objects','FontWeight','Bold');

% Total Collisions
figure('Color','w'); hold on; box on; grid on;
plot(xData,cumulativeCollisions);
ax = gca; ax.XLim = round([xData(1) xData(end)]);
xlabel('Time (Years)','FontWeight','Bold');
title('Total Number of Collisions');
ylabel('Collisions','FontWeight','Bold');

% Total Sensors
figure('Color','w'); hold on; box on; grid on;
plot(xData,gssa_model.gssn.data.combined_sensors,'LineWidth',2);
for iNation = 1:length(gssa_model.nations)
    plot(xData,gssa_model.nations{iNation}.data.totalSensors);
end
ax = gca; ax.XLim = round([xData(1) xData(end)]);
xlabel('Time (Years)','FontWeight','Bold');
title('Total Number of Sensors');
ylabel('Sensors','FontWeight','Bold');
lgdStr = strcat({'Nation '},strsplit(num2str(1:length(gssa_model.nations))),{' Sensors'});
legend([{'Combined GSSN Sensors'},lgdStr]);

% Sensor Status
figure('Color','w'); hold on; box on; grid on;
all_colors = {'r','y','b','g'};
for iNation = 1:length(gssa_model.nations)
    for iStatus = 1:length(gssa_model.nations{iNation}.all_status)
        statusData = double(strcmp(gssa_model.nations{iNation}.data.sensorStatus,gssa_model.nations{iNation}.all_status{iStatus}));
        statusData(statusData == 0) = NaN;
        plot(xData,iNation*statusData,[all_colors{iStatus},'.'],'MarkerSize',10);
    end
end
ax = gca; ax.XLim = round([xData(1) xData(end)]);
xlabel('Time (Years)','FontWeight','Bold');
title('Sensors Status');
ylabel('Nation','FontWeight','Bold');
legend(gssa_model.nations{iNation}.all_status);

% Total Satellites
figure('Color','w'); hold on; box on; grid on;
plot(xData,gssa_model.leo_environment.data.leoSats,'LineWidth',2);
for iNation = 1:length(gssa_model.nations)
    plot(xData,gssa_model.nations{iNation}.data.totalSatellites);
end
ax = gca; ax.XLim = round([xData(1) xData(end)]); ax.YLim = [0 max(gssa_model.leo_environment.data.leoSats)];
xlabel('Time (Years)','FontWeight','Bold');
title('Total Satellites');
ylabel('Satellites','FontWeight','Bold');
lgdStr = strcat({'Nation '},strsplit(num2str(1:length(gssa_model.nations))),{' Satellites'});
legend([{'LEO Satellites'},lgdStr]);

% Tracking Success Probability
figure('Color','w'); hold on; box on; grid on;
plot(xData, gssa_model.gssn.data.tracking_capacity ./ gssa_model.leo_environment.data.totalDebris,'LineWidth',2);
for iNation = 1:length(gssa_model.nations)
    plot(xData, ...
        gssa_model.nations{iNation}.data.trackingCapacity ./ gssa_model.leo_environment.data.totalDebris);
end
ax = gca; ax.XLim = round([xData(1) xData(end)]); ax.YLim = [0 1.5];
xlabel('Time (Years)','FontWeight','Bold');
title('Tracking Success Probability');
ylabel('Tracking Success Probability','FontWeight','Bold');
lgdStr = strcat({'Nation '},strsplit(num2str(1:length(gssa_model.nations))));
legend([{'GSSN'},lgdStr]);

% Total Budget
figure('Color','w'); hold on; box on; grid on;
for iNation = 1:length(gssa_model.nations)
    plot(xData,gssa_model.nations{iNation}.data.budget/1000);
end
ax = gca; ax.XLim = round([xData(1) xData(end)]);
xlabel('Time (Years)','FontWeight','Bold');
title('Budget');
ylabel('$ (Billions)','FontWeight','Bold');
lgdStr = strcat({'Nation '},strsplit(num2str(1:length(gssa_model.nations))));
legend(lgdStr);

% Total Revenue
figure('Color','w'); hold on; box on; grid on;
for iNation = 1:length(gssa_model.nations)
    plot(xData,gssa_model.nations{iNation}.data.revenue/1000);
end
ax = gca; ax.XLim = round([xData(1) xData(end)]);
xlabel('Time (Years)','FontWeight','Bold');
title('Revenue');
ylabel('$ (Billions)','FontWeight','Bold');
lgdStr = strcat({'Nation '},strsplit(num2str(1:length(gssa_model.nations))));
legend(lgdStr);

% Total Cost
figure('Color','w'); hold on; box on; grid on;
for iNation = 1:length(gssa_model.nations)
    plot(xData,gssa_model.nations{iNation}.data.cost/1000);
end
ax = gca; ax.XLim = round([xData(1) xData(end)]);
xlabel('Time (Years)','FontWeight','Bold');
title('Cost');
ylabel('$ (Billions)','FontWeight','Bold');
lgdStr = strcat({'Nation '},strsplit(num2str(1:length(gssa_model.nations))));
legend(lgdStr);

% GSSN Membership
figure('Color','w'); hold on; box on; grid on;
plot(xData,gssa_model.gssn.data.total_members_cum);
ax = gca; ax.XLim = round([xData(1) xData(end)]);
xlabel('Time (Years)','FontWeight','Bold');
title('GSSN Membership');
ylabel('# of Nations','FontWeight','Bold');

% GSSN Membership Status by Nation
figure('Color','w'); hold on; box on; grid on;
all_colors = {'r','g','m','y','b'};
for iNation = 1:length(gssa_model.nations)
    for iStatus = 1:length(gssa_model.nations{iNation}.all_gssn_member_status)
        statusData = double(strcmp(gssa_model.nations{iNation}.data.gssnMemberStatus,gssa_model.nations{iNation}.all_gssn_member_status{iStatus}));
        statusData(statusData == 0) = NaN;
        plot(xData,iNation*statusData,[all_colors{iStatus},'.'],'MarkerSize',10);
    end
end
ax = gca; ax.XLim = round([xData(1) xData(end)]);
xlabel('Time (Years)','FontWeight','Bold');
title('GSSN Membership Status');
ylabel('Nation','FontWeight','Bold');
legend(gssa_model.nations{iNation}.all_gssn_member_status);


