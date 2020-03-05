%t-test

clear;
clc;

opt_multiStart = 0;

%mainFolder = 'Random_Navigation_Results_260220_multistart';
mainFolder = 'Random_Navigation_Results_FrontFacing_Overlap_dimreduce_260220';

%load([mainFolder,'/allAUCs_SAD.mat']);
load([mainFolder,'/allAUCs_Gist.mat']);
%load([mainFolder,'/allAUCs_NetVLAD.mat']);

if opt_multiStart == 1
    
counter = 0;
for j = 2:7
	counter = counter + 1;
    mean_AUC(1,counter) = mean(AUC_all(:,j));
    std_AUC(1,counter) = std(AUC_all(:,j));
end

baseline_AUC = AUC_all(:,1);

mean_baseline_AUC = mean(baseline_AUC);
std_baseline_AUC = std(baseline_AUC);

% r = mean_AUC;
% s = std_AUC;

for i = 1:6
    x1 = mean_baseline_AUC;    
    s1 = std_baseline_AUC;

    x2 = mean_AUC(i);
    s2 = std_AUC(i);

    n = 20;

    t(i) = (x2 - x1)/(sqrt( ( (s1).^2 / n ) + ( (s2).^2 / n ) ));
end
t

else

counter = 0;
for j = 1:8
	counter = counter + 1;
    mean_AUC(1,counter) = mean(AUC_all(:,j));
    std_AUC(1,counter) = std(AUC_all(:,j));
end

for i = 1:20
    baseline_AUC(i) = AUC_Baseline_all{i,8}(9);
end

mean_baseline_AUC = mean(baseline_AUC);
std_baseline_AUC = std(baseline_AUC);

% r = mean_AUC;
% s = std_AUC;

for i = 1:8
    x1 = mean_baseline_AUC;    
    s1 = std_baseline_AUC;

    x2 = mean_AUC(i);
    s2 = std_AUC(i);

    n = 20;

    t(i) = (x2 - x1)/(sqrt( ( (s1).^2 / n ) + ( (s2).^2 / n ) ));
end
t

end

