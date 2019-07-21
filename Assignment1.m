% Assignment 1 MAT8180
% Author: John Worrall
% Description:Given input data, create a ANN (3 layers, 30 hidden nerons, with log sig as activation function
% linear output function and Levenberg-Marquardt for backpropation).
% Requirments: Funtion asseMetric.m and Assignment 1 Data.xls
%----------------------------
clear all
clc
close all

%Read
assignData=xlsread('Assignment 1 Data.xls');
datin = assignData(1:1045,1:2);
datout = assignData(1:1045,3);
datinval = assignData(1046:1105,1:2);
datoutval = assignData(1046:1105,3);
chkdatin = assignData(1105:end,1:2);
chkdatout = assignData(1105:end,3);

%nn variables 
pn = datin'; 
qn = datout';
valP = datinval';
valT = datoutval';

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

%denormaised data - convert back
xMax = 3.970;
xMin = -2.318;
sdataObs = zv(:,2);
sdataSim = zv(:,1);
for x = 1:numel(sdataObs)
   dataObs(x) = sdataObs(x) * (xMax - xMin)+ xMin;
   dataSim(x) = sdataSim(x) * (xMax - xMin)+ xMin;
end
dataObs = dataObs';
dataSim = dataSim';

%Call metric assement function
%r,Nash_ENS,Willmott Index_d,P Peak Dev_Pdv,RMSE,MAE
[nnR,nnENS,nnD,nnPDEV,nnRMSE,nnMAE,nnPI]=asseMetric(dataObs,dataSim);
nnPI

% Scatterplot
scatter(dataObs,dataSim)
text(1,1, ['r^2 = ' num2str(nnR)])
title('Scatter plot or r^2');
xlabel('Data Obs');
ylabel('Data Sim');
%add line
coeffs = polyfit(dataObs, dataSim, 1);
% Get fitted values
fittedX = linspace(min(dataObs), max(dataObs), 200);
fittedY = polyval(coeffs, fittedX);
% Plot the fitted line
hold on;
plot(fittedX, fittedY, 'r-', 'LineWidth', 3);
