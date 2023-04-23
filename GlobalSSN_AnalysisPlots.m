function [finalCollisions, finalDebris] = GlobalSSN_AnalysisPlots(gssa_model,timeVec)

cumulativeCollisions = cumsum(gssa_model.leo_environment.data.totalCollisions);
finalCollisions = cumulativeCollisions(end);
finalDebris = gssa_model.leo_environment.data.totalDebris(end);

% Analysis plots
xData = years(days(timeVec));

% Total Debris
figure('Color','w'); hold on; box on; grid on;
plot(xData,gssa_model.leo_environment.data.totalDebris);
ax = gca; ax.XLim = [xData(1) xData(end)]; ax.YLim = [0 100000];
ax.YAxis.Exponent = 0; 
title('Total Number of Debris');
xlabel('Years','FontWeight','Bold');
ylabel('Debris Objects','FontWeight','Bold');

% Total Collisions
figure('Color','w'); hold on; box on; grid on;
plot(xData,cumulativeCollisions);
ax = gca; ax.XLim = [xData(1) xData(end)];
xlabel('Years','FontWeight','Bold');
title('Total Number of Collisions');
ylabel('Collisions','FontWeight','Bold');

% Total Sensors
figure('Color','w'); hold on; box on; grid on;
for iNation = 1:length(gssa_model.nations)
    plot(xData,gssa_model.nations{iNation}.data.totalSensors);
end
ax = gca; ax.XLim = [xData(1) xData(end)];
xlabel('Years','FontWeight','Bold');
title('Total Number of Sensors');
ylabel('Sensors','FontWeight','Bold');

% Total Satellites
figure('Color','w'); hold on; box on; grid on;
for iNation = 1:length(gssa_model.nations)
    plot(xData,gssa_model.nations{iNation}.data.totalSatellites);
end
ax = gca; ax.XLim = [xData(1) xData(end)]; ax.YLim = [0 10000];
xlabel('Years','FontWeight','Bold');
title('Total Satellites');
ylabel('Satellites','FontWeight','Bold');

% Tracking Capacity
figure('Color','w'); hold on; box on; grid on;
for iNation = 1:length(gssa_model.nations)
    plot(xData, ...
        gssa_model.nations{iNation}.data.trackingCapacity ./ gssa_model.leo_environment.data.totalDebris);
end
ax = gca; ax.XLim = [xData(1) xData(end)]; ax.YLim = [0 1.5];
xlabel('Years','FontWeight','Bold');
title('Tracking Success Probability');
ylabel('Tracking Success Probability','FontWeight','Bold');