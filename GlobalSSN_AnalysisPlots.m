function [finalCollisions, finalDebris] = GlobalSSN_AnalysisPlots(gssa_model,timeVec)

cumulativeCollisions = cumsum(gssa_model.leo_environment.data.totalCollisions);
finalCollisions = cumulativeCollisions(end);
finalDebris = gssa_model.leo_environment.data.totalDebris(end);

% Analysis plots
% Total Debris
figure('Color','w'); hold on; box on; grid on;
plot(years(days(timeVec)),gssa_model.leo_environment.data.totalDebris);
ax = gca; ax.YAxis.Exponent = 0; ax.YLim = [0 100000];
title('Total Number of Debris');
xlabel('Years','FontWeight','Bold');
ylabel('Debris Objects','FontWeight','Bold');
% Total Collisions
figure('Color','w'); hold on; box on; grid on;
plot(years(days(timeVec)),cumulativeCollisions);
xlabel('Years','FontWeight','Bold');
title('Total Number of Collisions');
ylabel('Collisions','FontWeight','Bold');
% Total Sensors
figure('Color','w'); hold on; box on; grid on;
for iNation = 1:length(gssa_model.nations)
    plot(years(days(timeVec)),gssa_model.nations{iNation}.data.totalSensors);
end
xlabel('Years','FontWeight','Bold');
title('Total Number of Sensors');
ylabel('Sensors','FontWeight','Bold');
% Total Satellites
figure('Color','w'); hold on; box on; grid on;
for iNation = 1:length(gssa_model.nations)
    plot(years(days(timeVec)),gssa_model.nations{iNation}.data.totalSatellites);
end
ax = gca; ax.YLim = [0 10000];
xlabel('Years','FontWeight','Bold');
title('Total Satellites');
ylabel('Satellites','FontWeight','Bold');
% Tracking Capacity
figure('Color','w'); hold on; box on; grid on;
for iNation = 1:length(gssa_model.nations)
    plot(years(days(timeVec)), ...
        gssa_model.nations{iNation}.data.trackingCapacity ./ gssa_model.leo_environment.data.totalDebris);
end
ax = gca; ax.YLim = [0 1];
xlabel('Years','FontWeight','Bold');
title('Tracking Success Probability');
ylabel('Tracking Success Probability','FontWeight','Bold');