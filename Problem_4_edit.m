%% Estimating CO from ABP - Problem 3

% Names: Albert, Connie, Darren, Matthew

%% Extract data

vitals = readtable('s00020-2567-03-30-17-47n.txt');
abp = readtable('s00020-2567-03-30-17-47_ABP.txt');

time = table2array(vitals(:,1));

end_time = 12*60*60; %seconds
vitals_end_index = find(time==end_time);

time = time(1:vitals_end_index);
hr = table2array(vitals(1:vitals_end_index,2));
abp_sys = table2array(vitals(1:vitals_end_index,3));
abp_dias = table2array(vitals(1:vitals_end_index,4));
abp_mean = table2array(vitals(1:vitals_end_index,5));
co_td = table2array(vitals(1:vitals_end_index,16));

abp_time = table2array(abp(:,1));
abp_vals = table2array(abp(:,2));

abp_end_index = find(abp_time==end_time);
abp_trunc = abp_vals(1:abp_end_index);

%% Collect data for CO estimation

t_on = wabp(abp_trunc);
feat = abpfeature(abp_trunc, t_on);
beat_q = jSQI(feat, t_on, abp_trunc);

%% Uncalibrated CO estimation

[co_uc_1, ~, ~, ~] = estimateCO_v3(t_on, feat, beat_q, 1, 0);
[co_uc_2, ~, ~, ~] = estimateCO_v3(t_on, feat, beat_q, 2, 0);
[co_uc_3, ~, ~, ~] = estimateCO_v3(t_on, feat, beat_q, 3, 0);
[co_uc_4, ~, ~, ~] = estimateCO_v3(t_on, feat, beat_q, 4, 0);
[co_uc_5, time_co, ~, cofromabp_feat] = estimateCO_v3(t_on, feat, beat_q, 5, 0);
[co_uc_6, ~, ~, ~] = estimateCO_v3(t_on, feat, beat_q, 6, 0);
[co_uc_7, ~, ~, ~] = estimateCO_v3(t_on, feat, beat_q, 7, 0);
[co_uc_10, ~, ~, ~] = estimateCO_v3(t_on, feat, beat_q, 10, 0);
time_co = time_co.*60;

%% Calibration

CO_indices = find(co_td);
CO_times = time(CO_indices);
[~, first_index_co] = min(abs(time_co-time(CO_indices(1,1))));
k_1 = co_td(CO_indices(1,1))/co_uc_1(first_index_co);
k_2 = co_td(CO_indices(1,1))/co_uc_2(first_index_co);
k_3 = co_td(CO_indices(1,1))/co_uc_3(first_index_co);
k_4 = co_td(CO_indices(1,1))/co_uc_4(first_index_co);
k_5 = co_td(CO_indices(1,1))/co_uc_5(first_index_co);
k_6 = co_td(CO_indices(1,1))/co_uc_6(first_index_co);
k_7 = co_td(CO_indices(1,1))/co_uc_7(first_index_co);
k_10 = co_td(CO_indices(1,1))/co_uc_10(first_index_co);

CO_1 = k_1*co_uc_1;
CO_2 = k_2*co_uc_2;
CO_3 = k_3*co_uc_3;
CO_4 = k_4*co_uc_4;
CO_5 = k_5*co_uc_5;
CO_6 = k_6*co_uc_6;
CO_7 = k_7*co_uc_7;
CO_10 = k_10*co_uc_10;

%% Plot results

tiledlayout(4,2)

nexttile
plot(time_co./3600, CO_1)
title("MAP")
ylim([0 10])
ylabel('CO')
hold on
stem(CO_times./3600, co_td(CO_indices), 'filled')

nexttile
plot(time_co./3600, CO_2)
title("Windkessel")
ylim([0 10])
ylabel('CO')
hold on
stem(CO_times./3600, co_td(CO_indices), 'filled')

nexttile
plot(time_co./3600, CO_3)
title("Systolic Area")
ylim([0 10])
ylabel('CO')
hold on
stem(CO_times./3600, co_td(CO_indices), 'filled')

nexttile
plot(time_co./3600, CO_4)
title("Systolic Area with Kouchoukos")
ylim([0 10])
ylabel('CO')
hold on
stem(CO_times./3600, co_td(CO_indices), 'filled')

nexttile
plot(time_co./3600, CO_5)
title("Liljestrand")
ylim([0 10])
hold on
stem(CO_times./3600, co_td(CO_indices), 'filled')
ylabel('CO')


nexttile
plot(time_co./3600, CO_6)
title("Herd")
ylim([0 10])
ylabel('CO')
hold on
stem(CO_times./3600, co_td(CO_indices), 'filled')

nexttile
plot(time_co./3600, CO_7)
title("Systolic Area Wesseling")
ylim([0 10])
ylabel('CO')
hold on
stem(CO_times./3600, co_td(CO_indices), 'filled')

nexttile
plot(time_co./3600, CO_10)
title("Windkessel RC decay")
xlim([0 10])
ylabel('CO')
hold on
stem(CO_times./3600, co_td(CO_indices), 'filled')