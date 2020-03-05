clc
clear
close all

opt_multiStart = 0;
opt_Nord = 1;

%mainFolder = 'Random_Navigation_Results_220220_tenpixelOffset';
%mainFolder = 'Random_Navigation_Results_FrontFacing_Overlap_PCA_250220';
mainFolder = 'Random_Navigation_Results_FrontFacing_Overlap_dimreduce_260220';

%load([mainFolder,'/allAUCs_SAD.mat'],'AUC_all','AUC_Baseline_all');
load([mainFolder,'/allAUCs_NetVLAD.mat'],'AUC_all','AUC_Baseline_all');
%load([mainFolder,'/allAUCs_Gist.mat'],'AUC_all','AUC_Baseline_all');

if opt_multiStart == 1
%%
    for j = 1:7
        mean_AUC(1,j) = mean(AUC_all(:,j));
        std_AUC(1,j) = std(AUC_all(:,j));
    end
    r = mean_AUC;
    s = std_AUC;
    errlow = s./1;
    errhigh = s./1;
c = categorical({'Size One','Size Two','Size Three',...
    'Size Four','Size Five','Size Six','Size Seven'});
c = reordercats(c,{'Size One','Size Two','Size Three',...
    'Size Four','Size Five','Size Six','Size Seven'});

figure
b = bar(c,r,'FaceColor','Flat');
b(1).BarWidth = 0.6;
set(gca,'FontSize',32);
title('Absolute Scale Size Results using NetVLAD');
ylim([0.9 1]);

ylabel('AUC','FontSize',32);

hold on

er = errorbar(c,r,errlow,errhigh,'CapSize',30,'LineWidth',1.5);
er.Color = [1 0 0];
er.LineStyle = 'none';

hold off

file_fig =[mainFolder '/' 'Absolute Scale Size Results using NetVLAD' '.fig'];
saveas(gcf,file_fig);
file_fig =[mainFolder '/' 'Absolute Scale Size Results using NetVLAD' '.jpg'];
saveas(gcf,file_fig);
file_fig =[mainFolder '/' 'Absolute Scale Size Results using NetVLAD' '.eps'];
saveas(gcf,file_fig,'epsc');
elseif opt_Nord == 1
%%    
    
for j = 1:8
    mean_AUC(1,j) = mean(AUC_all(:,j));
    std_AUC(1,j) = std(AUC_all(:,j));
end
for i = 1:20
    subset(i) = AUC_Baseline_all{i,8}(9);
end
mean_baseline_AUC = mean(subset);
std_baseline_AUC = std(subset);

r = [mean_baseline_AUC mean_AUC];
s = [std_baseline_AUC std_AUC];
errlow = s./1;
errhigh = s./1;

c = categorical({'Single Scale','Two Scales','Three Scales',...
    'Four Scales','Five Scales','Six Scales','Seven Scales',...
    'Eight Scales','Nine Scales'});
c = reordercats(c,{'Single Scale','Two Scales','Three Scales',...
    'Four Scales','Five Scales','Six Scales','Seven Scales',...
    'Eight Scales','Nine Scales'});

figure
b = bar(c,r,'FaceColor','Flat');
b(1).BarWidth = 0.6;
set(gca,'FontSize',32);
title('Nordland Navigation Results using NetVLAD');
ylim([0 1]);

b(1).CData(1,:) = [0 1 0];
b(1).CData(2,:) = [0 0.8 1];
b(1).CData(3,:) = [0 0.7 1];
b(1).CData(4,:) = [0 0.6 1];
b(1).CData(5,:) = [0 0.5 1];
b(1).CData(6,:) = [0 0.4 1];
b(1).CData(7,:) = [0 0.3 1];
b(1).CData(8,:) = [0 0.2 1];
b(1).CData(9,:) = [0 0.1 1];

ylabel('AUC','FontSize',32);

hold on

er = errorbar(c,r,errlow,errhigh,'CapSize',30,'LineWidth',1.5);
er.Color = [1 0 0];
er.LineStyle = 'none';

hold off

    file_fig =[mainFolder '/' 'Nordland Navigation Results using NetVLAD' '.fig'];
    saveas(gcf,file_fig);
    file_fig =[mainFolder '/' 'Nordland Navigation Results using NetVLAD' '.jpg'];
    saveas(gcf,file_fig);
    file_fig =[mainFolder '/' 'Nordland Navigation Results using NetVLAD' '.eps'];
    saveas(gcf,file_fig,'epsc');

for k = 1:9
    clear subset;
    for i = 1:20
        subset(i) = AUC_Baseline_all{i,8}(k);
    end
    mean_baseline_AUC_arr(k) = mean(subset);
    std_baseline_AUC_arr(k) = std(subset);
end

rb = mean_baseline_AUC_arr;
sb = std_baseline_AUC_arr;
errlow = sb./1;
errhigh = sb./1;

c = categorical({'Scale 1','Scale 2','Scale 3',...
    'Scale 4','Scale 5','Scale 6','Scale 7',...
    'Scale 8','Scale 9'});
c = reordercats(c,{'Scale 1','Scale 2','Scale 3',...
    'Scale 4','Scale 5','Scale 6','Scale 7',...
    'Scale 8','Scale 9'});

figure
b = bar(c,rb,'FaceColor','Flat');
b(1).BarWidth = 0.6;
set(gca,'FontSize',32);
title('Single Scale Results on Nordland using NetVLAD');
%title('Single Scale Results on Nearmaps using Gist');
ylim([0,1]);

ylabel('AUC','FontSize',32);

hold on

er = errorbar(c,rb,errlow,errhigh,'CapSize',30,'LineWidth',1.5);
er.Color = [1 0 0];
er.LineStyle = 'none';

hold off

file_fig =[mainFolder '/Single Scale Results on Nordland using NetVLAD' '.fig'];
saveas(gcf,file_fig);
file_fig =[mainFolder '/Single Scale Results on Nordland using NetVLAD' '.jpg'];
saveas(gcf,file_fig);
file_fig =[mainFolder '/Single Scale Results on Nordland using NetVLAD' '.eps'];
saveas(gcf,file_fig,'epsc');


else
%%
for j = 1:8
    mean_AUC(1,j) = mean(AUC_all(:,j));
    std_AUC(1,j) = std(AUC_all(:,j));
end
for i = 1:20
    subset(i) = AUC_Baseline_all{i,8}(9);
end
mean_baseline_AUC = mean(subset);
std_baseline_AUC = std(subset);

r = [mean_baseline_AUC mean_AUC];
s = [std_baseline_AUC std_AUC];
errlow = s./1;
errhigh = s./1;

c = categorical({'Single Scale','Two Scales','Three Scales',...
    'Four Scales','Five Scales','Six Scales','Seven Scales',...
    'Eight Scales','Nine Scales'});
c = reordercats(c,{'Single Scale','Two Scales','Three Scales',...
    'Four Scales','Five Scales','Six Scales','Seven Scales',...
    'Eight Scales','Nine Scales'});

figure
b = bar(c,r,'FaceColor','Flat');
b(1).BarWidth = 0.6;
set(gca,'FontSize',32);
title('Nearmaps Navigation Results using Gist');
ylim([0 1]);

b(1).CData(1,:) = [0 1 0];
b(1).CData(2,:) = [0 0.8 1];
b(1).CData(3,:) = [0 0.7 1];
b(1).CData(4,:) = [0 0.6 1];
b(1).CData(5,:) = [0 0.5 1];
b(1).CData(6,:) = [0 0.4 1];
b(1).CData(7,:) = [0 0.3 1];
b(1).CData(8,:) = [0 0.2 1];
b(1).CData(9,:) = [0 0.1 1];

ylabel('AUC','FontSize',32);

hold on

er = errorbar(c,r,errlow,errhigh,'CapSize',30,'LineWidth',1.5);
er.Color = [1 0 0];
er.LineStyle = 'none';

hold off

    file_fig =[mainFolder '/' 'Nearmaps Navigation Results using NetVLAD' '.fig'];
    saveas(gcf,file_fig);
    file_fig =[mainFolder '/' 'Nearmaps Navigation Results using NetVLAD' '.jpg'];
    saveas(gcf,file_fig);
    file_fig =[mainFolder '/' 'Nearmaps Navigation Results using NetVLAD' '.eps'];
    saveas(gcf,file_fig,'epsc');

for k = 1:9
    clear subset;
    for i = 1:20
        subset(i) = AUC_Baseline_all{i,8}(k);
    end
    mean_baseline_AUC_arr(k) = mean(subset);
    std_baseline_AUC_arr(k) = std(subset);
end

rb = mean_baseline_AUC_arr;
sb = std_baseline_AUC_arr;
errlow = sb./1;
errhigh = sb./1;

c = categorical({'Scale 1','Scale 2','Scale 3',...
    'Scale 4','Scale 5','Scale 6','Scale 7',...
    'Scale 8','Scale 9'});
c = reordercats(c,{'Scale 1','Scale 2','Scale 3',...
    'Scale 4','Scale 5','Scale 6','Scale 7',...
    'Scale 8','Scale 9'});

figure
b = bar(c,rb,'FaceColor','Flat');
b(1).BarWidth = 0.6;
set(gca,'FontSize',32);
title('Single Scale Results on Nearmaps using NetVLAD');
%title('Single Scale Results on Nearmaps using Gist');
ylim([0,1]);

ylabel('AUC','FontSize',32);

hold on

er = errorbar(c,rb,errlow,errhigh,'CapSize',30,'LineWidth',1.5);
er.Color = [1 0 0];
er.LineStyle = 'none';

hold off

%     file_fig =[mainFolder '/Single Scale Results on Nearmaps using SAD' '.fig'];
%     saveas(gcf,file_fig);
%     file_fig =[mainFolder '/Single Scale Results on Nearmaps using SAD' '.jpg'];
%     saveas(gcf,file_fig);
%     file_fig =[mainFolder '/Single Scale Results on Nearmaps using SAD' '.eps'];
%     saveas(gcf,file_fig,'epsc');

    file_fig =[mainFolder '/Single Scale Results on Nearmaps using NetVLAD' '.fig'];
    saveas(gcf,file_fig);
    file_fig =[mainFolder '/Single Scale Results on Nearmaps using NetVLAD' '.jpg'];
    saveas(gcf,file_fig);
    file_fig =[mainFolder '/Single Scale Results on Nearmaps using NetVLAD' '.eps'];
    saveas(gcf,file_fig,'epsc');
    
end
    
