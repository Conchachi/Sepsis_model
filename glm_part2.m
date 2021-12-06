%This code creates and tests a model of septic risk
clear;clc;
%import both clinical data and waveform data
load('static_data_training.mat');
load('dynamic_data_training.mat');

%%%%
%generate covariates for complex model

%preparing a septic/non-septic vector for glmfit
%note all septic data will be first, followed by all non-septic data
Y = nan(length(dynamic_train(:,1)),1);

%%%%
%X = nan(length(dynamic_train(:,1)),7); 

%X = dynamic_train(:,4:8); %only dynamic data
%X(:,3:4) = dynamic_train(:,[5,7]); %only parameters that have consistently been p-values of 0
X(:,4:8) = dynamic_train(:,[3,4,6,7,8]); %controls which dynamic data is to be used
%%%%

IDs = dynamic_train(:,1);%septic patient ID for each waveform time point
ID_uni = static_train(:,1);%patient's ID numbers

%create covariate matrix including both demographic info and waveform data
for i = 1:length(ID_uni)%for septic data
    ind = find(IDs==ID_uni(i));
    
    %%%%
    X(ind,1:3) = repmat(static_train(i,[5,6,7]),length(ind),1); %combines static with dynamic
    %X(ind,1:2) = repmat(static_train(i,[5,7]),length(ind),1);  %only parameters that have consistently been p-values of 0
    %%%%
    
    
    display(num2str(i));
    Y(ind) = repmat(static_train(i,2),length(ind),1); 
end

%%%%
[B,dev,stats] = glmfit(X,Y,'binomial');%find model parameters 
Phat = 1./(1+exp(-[ones(size(X,1),1) X]*B)); %equivalent way to compute Phat


%decision rule takes the maximum risk score over the entire time period and
%assigns that risk value to the patient this operates on the safer side

Phat_decision = nan(size(ID_uni));
Y_decision = nan(size(ID_uni));
for i = 1:length(ID_uni)%for septic data
    ind = find(IDs==ID_uni(i));
    Phat_decision(i) = max(Phat(ind));
    Y_decision(i) = static_train(i,2);
end 
    
%
[thresh] = test_performance(Phat_decision, Y_decision);
%[thresh] = test_performance(Phat, Y);


