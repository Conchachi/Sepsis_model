%import static training data (700 patients) - this is the basis of the simple model
load('static_data_training.mat');
%The header variable contains the meaning of each column of static_train
%generate simple glm
%define Y = observations which should be loaded from clinical table
Y = static_train(:,2);

%define X = covariate matrix by taking features from table. 
%This currently only uses Gender as a covariate.

%Update 11/29/21: Want to add Age as a covariate (based on literature),
%infection, as this is what triggers sepsis
% also should include respiratory rate and BP, so use respiratory and cardiovascular comorbidities
% gender those have a somewhat small role 
% Check stats.p, seems that only cardio, respiratory, and infection have significant bearing
X = static_train(:,5:7); %exclude gender based off of p-value > 0.05, but seems to be better fit if age is also excluded

%compute glm
[B,dev,stats] = glmfit(X,Y,'binomial');
%construct phat from parameters and X 
Phat = 1./(1+exp(-[ones(size(X,1),1) X]*B)); %equivalent way to compute Phat
%Phat is the estimated probability of sepsis occurence for patients


%plot phat versus patient along with its confidence bounds (1.96*stats.se)
Phat_UB = 1./(1+exp(-[ones(size(X,1),1) X]*(stats.beta + 1.96.*stats.se)));
Phat_LB = 1./(1+exp(-[ones(size(X,1),1) X]*(stats.beta - 1.96.*stats.se)));

%obtain param estimate bounds
pbound_5 = stats.beta - 1.96.*stats.se;
pbound_95 = stats.beta + 1.96.*stats.se;

% plot first 30 patients prediction, uncertainty and labels.
%figure(1)
%plot(Phat(1:30))
%hold on
%plot(Phat_LB(1:30),'b-')
%hold on
%plot(Phat_UB(1:30),'b-')
%hold on
%plot(Y(1:30),'r*')
%title('Models for Each Patient')

%test performance of models
[threshold] = test_performance(Phat, Y);
l=Y;
%[X,Y,T,AUC] = perfcurve(l,Phat, 1);
%figure;
%plot(X,Y)
