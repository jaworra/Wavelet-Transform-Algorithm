% Author: John Worrall
% Description:Given input data, create a ANN (3 layers, 30 hidden nerons, with log sig as activation function
% linear output function and Levenberg-Marquardt for backpropation).
% Requirments: Funtion asseMetric.m and Assignment 2 Data.xls
%----------------------------
clear all
clc
close all

%Standalone ANN model 
%Read
nwave=xlsread('Assignment 2 Data.xls','solar_normalized_non_wavelet');
datin = nwave(1:65,1:2);
datout = nwave(1:65,3);
datinval = nwave(66:91,1:2);
datoutval = nwave(66:91,3);
chkdatin = nwave(92:end,1:2);
chkdatout = nwave(92:end,3);

%nn variables 
pn = datin'; 
qn = datout';
valP = datinval';
valT = datoutval';

%randomise parameters, so historic runs have no influence
rand('state',0)

%build model
net = newff(minmax(pn),[30 1], {'logsig','purelin'}, 'trainlm');    
net = init(net);
%parmeters
net.trainParam.show = 100;
net.trainParam.epochs = 500;
net.trainParam.goal = 0.0001;
net.performFcn='mse';
w1=net.IW{1,1};
w2=net.LW{2,1};
b1=net.b{1};
b2=net.b{2};
%train model
[net,tr] = train(net,pn,qn,[],[],valT); %Check if this is valT
%simiulat results
a = sim(net, pn);
av = a';
z = [a' datout];    
%simulate outputdata
pval = chkdatin';
qval = chkdatout';
y = sim(net, pval);
yv = y';
zv = [y' chkdatout];

%denormaised data - *****HARD CODEDED VALUES****
xMax = 21.5056;
xMin = 17.7023;
sdataObs = zv(:,2);
sdataSim = zv(:,1);

for x = 1:numel(sdataObs)
   dataObs(x) = sdataObs(x) * (xMax - xMin)+ xMin;
   dataSim(x) = sdataSim(x) * (xMax - xMin)+ xMin;
end
dataObs = dataObs';
dataSim = dataSim';
nWaveResults = cat(2,dataObs,dataSim);
nWavedataObs = dataObs;
nWavedataSim = dataSim ;

%========================================================
%Hybrid wavelet + ANN model 
%Read
%clear all
%clc
%close all
clearvars -except nwave nWaveErrors nWaveResults nWavedataObs nWavedataSim

%Standalone ANN model 
%Read
wave=xlsread('Assignment 2 Data.xls','solar_normalised_wavelets_norma');
datin = wave(1:65,1:8);
datout= wave(1:65,9);
datinval = wave(66:91,1:8);
datoutval = wave(66:91,9);
chkdatin = wave(92:end,1:8);
chkdatout = wave(92:end,9);

%nn variables 
pn = datin'; 
qn = datout';
valP = datinval';
valT = datoutval';

%randomise parameters, so historic runs have no influence
rand('state',0)

%build model
net = newff(minmax(pn),[30 1], {'logsig','purelin'}, 'trainlm');    
net = init(net);
%parmeters
net.trainParam.show = 100;
net.trainParam.epochs = 500;
net.trainParam.goal = 0.0001;
net.performFcn='mse';
w1=net.IW{1,1};
w2=net.LW{2,1};
b1=net.b{1};
b2=net.b{2};
%train model
[net,tr] = train(net,pn,qn,[],[],valT); %Check if this is valT
%simiulat results
a = sim(net, pn);
av = a';
z = [a' datout];    
%simulate outputdata
pval = chkdatin';
qval = chkdatout';
y = sim(net, pval);
yv = y';
zv = [y' chkdatout];

%denormaised data - *****HARD CODEDED VALUES****
xMax = 21.5056;
xMin = 17.7023;
sdataObs = zv(:,2);
sdataSim = zv(:,1);

for x = 1:numel(sdataObs)
   dataObs(x) = sdataObs(x) * (xMax - xMin)+ xMin;
   dataSim(x) = sdataSim(x) * (xMax - xMin)+ xMin;
end
dataObs = dataObs';
dataSim = dataSim';
WaveResults = cat(2,dataObs,dataSim);
WavedataObs = dataObs;
WavedataSim = dataSim ;

clearvars -except nwave nWaveErrors nWaveResults nWavedataObs nWavedataSim wave WaveErrors WaveResults WavedataObs WavedataSim


%Call metric assement function
%r,Nash_ENS,Willmott Index_d,P Peak Dev_Pdv,RMSE,MAE
[nnR,nnENS,nnD,nnPDEV,nnRMSE,nnMAE,nnPI]=asseMetric(nWavedataObs,WavedataSim);
nWaveErrors = nnPI

%Call metric assement function
%r,Nash_ENS,Willmott Index_d,P Peak Dev_Pdv,RMSE,MAE
[nnR,nnENS,nnD,nnPDEV,nnRMSE,nnMAE,nnPI]=asseMetric(WavedataObs,WavedataSim);
nnPI;
WaveErrors = nnPI;

ylimMax1 = max(WavedataSim);
ylimMax2 = max(nWavedataSim); % maximum y value
ylimMax = max(ylimMax1,ylimMax2);
ylimMin1 = min(WavedataSim); % minimum y value
ylimMin2= min(nWavedataSim);
ylimMin = min(ylimMin1,ylimMin2);

%plots observes vs prediction
% Scatterplot
figure(1)
hold on;
scatter(nWavedataObs,nWavedataSim)
ylim([ylimMin ylimMax])
%text(1,1, ['r^2 = ' num2str(nnR)])
title('Solar data observe vs predicted scatterplot');
xlabel('Data Obs');
ylabel('Data Sim');
%add line
coeffs = polyfit(nWavedataObs, nWavedataSim, 1);
% Get fitted values
fittedX = linspace(min(nWavedataObs), max(nWavedataObs), 200);
fittedY = polyval(coeffs, fittedX);
% Plot the fitted line
plot(fittedX, fittedY, 'r-', 'LineWidth', 3);
hold off;

%time series
figure(2)
hold on;
plot(nWavedataObs);
plot(nWavedataSim);
ylim([ylimMin ylimMax])
title('Solar data timeseries prediction and observed');
ylabel('Solar data value');
legend('forecasted','observed');
hold off;

%histogram
figure(3)
dataErr = abs(nWavedataObs - nWavedataSim);
hmin = min(dataErr);
hmax = max(dataErr);
hold on;
hist(dataErr,[hmin:0.25:hmax])
title('Solar data histogram prediction againts observed');
ylabel('Observed difference againts prediction');
ylabel('Frequency');
hold off;




% Scatterplot
figure(4)
scatter(WavedataObs,WavedataSim)
ylim([ylimMin ylimMax])
%text(1,1, ['r^2 = ' num2str(nnR)])
title(' Wavelet solar data observe vs predicted scatterplot')
xlabel('Data Obs');
ylabel('Data Sim');
%add line
coeffs = polyfit(WavedataObs, WavedataSim, 1);
% Get fitted values
fittedX = linspace(min(WavedataObs), max(WavedataObs), 200);
fittedY = polyval(coeffs, fittedX);
% Plot the fitted line
hold on;
plot(fittedX, fittedY, 'r-', 'LineWidth', 3);

%time series
figure(5)
hold on;
plot(WavedataObs);
plot(WavedataSim);
ylim([ylimMin ylimMax])
title('Wavelet solar data timeseries prediction and observed');
ylabel('Solar data value');
legend('forecasted','observed');
hold off;

%histogram
figure(6)
dataErr = abs(WavedataObs - WavedataSim);
hmin = min(dataErr);
hmax = max(dataErr);
hold on;
hist(dataErr,[hmin:0.25:hmax])
title('Wavelet solar data histogram prediction againts observed');
ylabel('Observed difference againts prediction');
ylabel('Frequency');
hold off;


