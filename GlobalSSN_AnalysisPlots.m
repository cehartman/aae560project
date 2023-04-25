function [finalCollisions, finalDebris] = GlobalSSN_AnalysisPlots(gssa_model,timeVec)

cumulativeCollisions = cumsum(gssa_model.leo_environment.data.totalCollisions);
finalCollisions = cumulativeCollisions(end);
finalDebris = gssa_model.leo_environment.data.totalDebris(end);

% Analysis plots
xData = years(days(timeVec));

% Total Debris and Tracking Capacity
figure('Color','w'); hold on; box on; grid on;
plot(xData,gssa_model.leo_environment.data.totalDebris);
for iNation = 1:length(gssa_model.nations)
    plot(xData,gssa_model.nations{iNation}.data.trackingCapacity);
end
ax = gca; ax.XLim = round([xData(1) xData(end)]); ax.YLim = [0 20000];
ax.YAxis.Exponent = 0;
title('Tracking');
xlabel('Time (Years)','FontWeight','Bold');
ylabel('Objects','FontWeight','Bold');
legend({'Debris','Tracking Capacity'});

% Total Debris
figure('Color','w'); hold on; box on; grid on;
plot(xData,gssa_model.leo_environment.data.totalDebris);
ax = gca; ax.XLim = round([xData(1) xData(end)]); ax.YLim = [0 20000];
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
for iNation = 1:length(gssa_model.nations)
    plot(xData,gssa_model.nations{iNation}.data.totalSensors);
end
ax = gca; ax.XLim = round([xData(1) xData(end)]);
xlabel('Time (Years)','FontWeight','Bold');
title('Total Number of Sensors');
ylabel('Sensors','FontWeight','Bold');

% Total Satellites
figure('Color','w'); hold on; box on; grid on;
for iNation = 1:length(gssa_model.nations)
    plot(xData,gssa_model.nations{iNation}.data.totalSatellites);
end
ax = gca; ax.XLim = round([xData(1) xData(end)]); ax.YLim = [0 1000];
xlabel('Time (Years)','FontWeight','Bold');
title('Total Satellites');
ylabel('Satellites','FontWeight','Bold');

% Tracking Success Probability
figure('Color','w'); hold on; box on; grid on;
for iNation = 1:length(gssa_model.nations)
    plot(xData, ...
        gssa_model.nations{iNation}.data.trackingCapacity ./ gssa_model.leo_environment.data.totalDebris);
end
ax = gca; ax.XLim = round([xData(1) xData(end)]); ax.YLim = [0 1.5];
xlabel('Time (Years)','FontWeight','Bold');
title('Tracking Success Probability');
ylabel('Tracking Success Probability','FontWeight','Bold');

% Total Budget
figure('Color','w'); hold on; box on; grid on;
for iNation = 1:length(gssa_model.nations)
    plot(xData,gssa_model.nations{iNation}.data.budget);
end
ax = gca; ax.XLim = round([xData(1) xData(end)]);
xlabel('Time (Years)','FontWeight','Bold');
title('Budget');
ylabel('$ (Millions)','FontWeight','Bold');

% Total Revenue
figure('Color','w'); hold on; box on; grid on;
for iNation = 1:length(gssa_model.nations)
    plot(xData,gssa_model.nations{iNation}.data.revenue);
end
ax = gca; ax.XLim = round([xData(1) xData(end)]);
xlabel('Time (Years)','FontWeight','Bold');
title('Revenue');
ylabel('$ (Millions)','FontWeight','Bold');

% Total Cost
figure('Color','w'); hold on; box on; grid on;
for iNation = 1:length(gssa_model.nations)
    plot(xData,gssa_model.nations{iNation}.data.cost);
end
ax = gca; ax.XLim = round([xData(1) xData(end)]);
xlabel('Time (Years)','FontWeight','Bold');
title('Cost');
ylabel('$ (Millions)','FontWeight','Bold');
