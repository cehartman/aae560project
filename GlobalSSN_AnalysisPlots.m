function [finalCollisions, finalDebris] = GlobalSSN_AnalysisPlots(gssa_model,timeVec)

cumulativeCollisions = cumsum(gssa_model.leo_environment.data.totalCollisions);
finalCollisions = cumulativeCollisions(end);
finalDebris = gssa_model.leo_environment.data.totalDebris(end);

% Analysis plots
xData = years(days(timeVec));

% Nation colors
n_nations = length(gssa_model.nations);
nation_colors = distinguishable_colors(n_nations,'w');

% Total Debris and Tracking Capacity
figure('Color','w','Position',[600 400 620 420]); hold on; box on; grid on;
plot(xData,gssa_model.leo_environment.data.totalDebris,'LineWidth',2);
plot(xData,gssa_model.gssn.data.tracking_capacity,'LineWidth',2);
for iNation = 1:n_nations
    plot(xData,gssa_model.nations{iNation}.data.trackingCapacity,'Color',nation_colors(iNation,:));
end
ax = gca; ax.XLim = round([xData(1) xData(end)]); ax.YLim(1) = 0;
ax.YAxis.Exponent = 0;
title('Tracking Capacity');
xlabel('Time (Years)','FontWeight','Bold');
ylabel('Objects','FontWeight','Bold');
lgdStr = strcat({'Nation '},strsplit(num2str(1:length(gssa_model.nations))));
legend([{'Debris','GSSN Capacity'},lgdStr],'location','northeastoutside');

% Total Debris
figure('Position',[600 400 720 420],'Color','w'); hold on; box on; grid on;
plot(xData,gssa_model.leo_environment.data.totalDebris);
ax = gca; ax.XLim = round([xData(1) xData(end)]); ax.YLim(1) = 0;
ax.YAxis.Exponent = 0;
title('Total Number of Debris');
xlabel('Time (Years)','FontWeight','Bold');
ylabel('Debris Objects','FontWeight','Bold');

% Total Collisions
figure('Position',[600 400 720 420],'Color','w'); hold on; box on; grid on;
plot(xData,cumulativeCollisions);
ax = gca; ax.XLim = round([xData(1) xData(end)]);
title('Total Number of Collisions');
xlabel('Time (Years)','FontWeight','Bold');
ylabel('Collisions','FontWeight','Bold');

% Total Sensors
figure('Position',[600 400 720 420],'Color','w'); hold on; box on; grid on;
plot(xData,gssa_model.gssn.data.combined_sensors,'LineWidth',2);
for iNation = 1:n_nations
    plot(xData,gssa_model.nations{iNation}.data.totalSensors,'Color',nation_colors(iNation,:));
end
ax = gca; ax.XLim = round([xData(1) xData(end)]);
title('Total Number of Sensors');
xlabel('Time (Years)','FontWeight','Bold');
ylabel('Sensors','FontWeight','Bold');
lgdStr = strcat({'Nation '},strsplit(num2str(1:length(gssa_model.nations))));
legend([{'Combined GSSN'},lgdStr],'location','northeastoutside');

% Sensor Status
try
    figure('Position',[600 400 720 420],'Color','w'); hold on; box on; grid on;
    all_colors = {'r','y','b','g'};
    for iNation = 1:n_nations
        for iStatus = 1:length(gssa_model.nations{iNation}.all_status)
            statusData = double(strcmp(gssa_model.nations{iNation}.data.sensorStatus,gssa_model.nations{iNation}.all_status{iStatus}));
            statusData(statusData == 0) = NaN;
            plot(xData,iNation*statusData,[all_colors{iStatus},'.'],'MarkerSize',10);
        end
    end
    ax = gca; ax.XLim = round([xData(1) xData(end)]);
    title('Sensors Status');
    xlabel('Time (Years)','FontWeight','Bold');
    ylabel('Nation','FontWeight','Bold');
    legend(gssa_model.nations{iNation}.all_status,'location','northeastoutside');
catch err
    disp(err.message);
    close(gcf);
end

% Total Satellites
figure('Position',[600 400 720 420],'Color','w'); hold on; box on; grid on;
plot(xData,gssa_model.leo_environment.data.leoSats,'LineWidth',2);
for iNation = 1:n_nations
    plot(xData,gssa_model.nations{iNation}.data.totalSatellites,'Color',nation_colors(iNation,:));
end
ax = gca; ax.XLim = round([xData(1) xData(end)]); ax.YLim = [0 max(gssa_model.leo_environment.data.leoSats)];
title('Total Satellites');
xlabel('Time (Years)','FontWeight','Bold');
ylabel('Satellites','FontWeight','Bold');
lgdStr = strcat({'Nation '},strsplit(num2str(1:n_nations)));
legend([{'LEO Total'},lgdStr],'location','northeastoutside');

% Tracking Success Probability
figure('Position',[600 400 720 420],'Color','w'); hold on; box on; grid on;
plot(xData, gssa_model.gssn.data.tracking_capacity ./ gssa_model.leo_environment.data.totalDebris,'LineWidth',2);
for iNation = 1:n_nations
    plot(xData, ...
        gssa_model.nations{iNation}.data.trackingCapacity ./ gssa_model.leo_environment.data.totalDebris,'Color',nation_colors(iNation,:));
end
ax = gca; ax.XLim = round([xData(1) xData(end)]);
title('Tracking Success Probability');
xlabel('Time (Years)','FontWeight','Bold');
ylabel('Tracking Success Probability','FontWeight','Bold');
lgdStr = strcat({'Nation '},strsplit(num2str(1:n_nations)));
legend([{'GSSN'},lgdStr],'location','northeastoutside');

% Total Budget
figure('Position',[600 400 720 420],'Color','w'); hold on; box on; grid on;
for iNation = 1:n_nations
    plot(xData,gssa_model.nations{iNation}.data.budget/1000,'Color',nation_colors(iNation,:));
end
ax = gca; ax.XLim = round([xData(1) xData(end)]);
title('Budget');
xlabel('Time (Years)','FontWeight','Bold');
ylabel('$ (Billions)','FontWeight','Bold');
lgdStr = strcat({'Nation '},strsplit(num2str(1:n_nations)));
legend(lgdStr,'location','northeastoutside');

% Total Revenue
figure('Position',[600 400 720 420],'Color','w'); hold on; box on; grid on;
for iNation = 1:n_nations
    plot(xData,gssa_model.nations{iNation}.data.revenue/1000,'Color',nation_colors(iNation,:));
end
ax = gca; ax.XLim = round([xData(1) xData(end)]);
title('Revenue');
xlabel('Time (Years)','FontWeight','Bold');
ylabel('$ (Billions)','FontWeight','Bold');
lgdStr = strcat({'Nation '},strsplit(num2str(1:n_nations)));
legend(lgdStr,'location','northeastoutside');

% Total Cost
figure('Position',[600 400 720 420],'Color','w'); hold on; box on; grid on;
for iNation = 1:n_nations
    plot(xData,gssa_model.nations{iNation}.data.cost/1000,'Color',nation_colors(iNation,:));
end
ax = gca; ax.XLim = round([xData(1) xData(end)]);
title('Cost');
xlabel('Time (Years)','FontWeight','Bold');
ylabel('$ (Billions)','FontWeight','Bold');
lgdStr = strcat({'Nation '},strsplit(num2str(1:n_nations)));
legend(lgdStr,'location','northeastoutside');

% GSSN Membership
figure('Position',[600 400 720 420],'Color','w'); hold on; box on; grid on;
plot(xData,gssa_model.gssn.data.total_members_cum);
ax = gca; ax.XLim = round([xData(1) xData(end)]);
title('GSSN Membership');
xlabel('Time (Years)','FontWeight','Bold');
ylabel('# of Nations','FontWeight','Bold');

% GSSN Membership Status by Nation
try
    figure('Position',[600 400 720 420],'Color','w'); hold on; box on; grid on;
    all_colors = {'r','g','m','y','b'};
    for iNation = 1:n_nations
        for iStatus = 1:length(gssa_model.nations{iNation}.all_gssn_member_status)
            statusData = double(strcmp(gssa_model.nations{iNation}.data.gssnMemberStatus,gssa_model.nations{iNation}.all_gssn_member_status{iStatus}));
            statusData(statusData == 0) = NaN;
            plot(xData,iNation*statusData,[all_colors{iStatus},'.'],'MarkerSize',10);
        end
    end
    ax = gca; ax.XLim = round([xData(1) xData(end)]);
    title('GSSN Membership Status');
    xlabel('Time (Years)','FontWeight','Bold');
    ylabel('Nation','FontWeight','Bold');
    legend(gssa_model.nations{iNation}.all_gssn_member_status,'location','northeastoutside');
catch err
    disp(err.message);
    close(gcf);
end
