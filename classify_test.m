%This code creates and tests a model of septic risk


%% Dynamic dataset
clear; glm_part2;

% Filenames
static_filename = 'static_data_validating.mat';
dynamic_filename = 'dynamic_data_validating.mat';

clearvars -except B static_train dynamic_train static_filename dynamic_filename

%bring in testing data
load(static_filename);
load(dynamic_filename);

%extract variables for data structures
Y_val = nan(length(dynamic_val(:,1)),1);
X_val = nan(length(dynamic_val(:,1)),11);
X(:,6:11) = dynamic_train(:,3:8); %controls which dynamic data is to be used
IDs = dynamic_val(:,1);%septic patient ID for each waveform time point
ID_uni = static_val(:,1);%patient's ID numbers

%create covariate matrix including both demographic info and waveform data
for i = 1:length(ID_uni)%for septic data
    ind = find(IDs==ID_uni(i));
    
    %%%%
    X(ind,1:5) = repmat(static_train(i,[3,4,5,6,7]),length(ind),1); %combines static with dynamic
    %X(ind,1:2) = repmat(static_train(i,[5,7]),length(ind),1);  %only parameters that have consistently been p-values of 0
    %%%%
    %display(num2str(i));
    Y_val(ind) = repmat(static_train(i,2),length(ind),1); 
end

%%%%%%%%COMPUTE TEST MODEL USING B FROM TRAINING MODEL
Phat_val = 1./(1+exp(-[ones(size(X,1),1) X]*B));

%Implement your decision rule for each patient here.

Phat_decision = nan(size(ID_uni));
Y_decision = nan(size(ID_uni));
for i = 1:length(ID_uni)%for septic data
    ind = find(IDs==ID_uni(i));
    Phat_decision(i) = max(Phat_val(ind));
    Y_decision(i) = static_train(i,2);
end 

[threshold] = test_performance(Phat_decision, Y_decision);

Y_bestguess(Phat_decision>threshold,1) = 1;
Y_bestguess(Phat_decision<threshold,1) = 0;

PercentCorrect_dynamic = (1 - sum(abs(Y_decision-Y_bestguess))/length(Y_decision))*100

%% Static dataset

glm_part1
clearvars -except B X Y static_filename dynamic_filename % save coefficients

%bring in testing data
load(static_filename);
load(dynamic_filename);

% static validating
X = static_val(:,5:7);
Phat_val_static = 1./(1+exp(-[ones(size(X,1),1) X]*B));

Y_test = static_val(:,2);
[threshold] = test_performance(Phat_val_static, Y_test);

Y_bestguess(Phat_val_static>threshold,1) = 1;
Y_bestguess(Phat_val_static<threshold,1) = 0;

PercentCorrect_static = (1 - sum(abs(Y_test-Y_bestguess))/length(Y_test))*100


