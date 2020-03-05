function [AUC,AUC_Baseline] = forwardFacingCombine(...
    mainFolder,scaleArray,runNum,randids,feature_type,...
    allDiffs_byScale)

%dataset is Nordland

GT_tol = 5; %frames %(5 frames equals about 100m)
opt_postz = 1;
opt_visualize = 1;
opt_saveMe = 0;
opt_useHPCfiles = 0;
opt_plotFigs = 0;
opt_loadPreComputed = 1;
%opt_loadPadded = 0;
opt_normPeriodic = 1;
%opt_skipReloading = 0;
opt_noSizeOneScale = 1;

% if opt_skipReloading == 0
%     clear allDiffs_byScale_rep;
% end

numScales = length(scaleArray);

labelid = 'Nord';

%in this version, scaleArray contains different sequence lengths

%GT_file = load('D:\Windows\Nordland\Nordland_GPSMatrix.mat');

file_name = [mainFolder,'/',feature_type,'_',labelid,'_results_',date,'/Figures/'];
save_name = [mainFolder,'/',feature_type,'_',labelid,'_results_',date,'/Data/'];

mkdir(file_name);
mkdir(save_name);

%we can use randomly sampled queries, however, we also need to grab nearby
%queries as well in order to formulate a sequence.
if strcmp(feature_type,'NetVLAD')
    loadpath = 'F:\D_Drive_Backup\Windows\Nordland\nordland_all_netvlad_features_multiscalefusion\';
elseif strcmp(feature_type,'Gist')    
    loadpath = 'F:\D_Drive_Backup\Windows\Nordland\nordland_all_gist_features_multiscalefusion\';
else %sad
    loadpath = 'F:\D_Drive_Backup\Windows\Nordland\nordland_all_sad_features_multiscalefusion\';
end
if opt_loadPreComputed == 0
    for i = 1:numScales
        s = scaleArray(i);
        load([loadpath 'Scale_DimReduce_' num2str(s) '_Dbase_Feats']);
        All_DbaseFeats{i} = feature_matrix;

        load([loadpath 'Scale_DimReduce_' num2str(s) '_Query_Feats']);
        All_QueryFeats{i} = feature_matrix;
    end
end
thresh = 0:0.1:9.9;  %100
thresh2 = 10:0.5:59.5;   %100
thresh = [thresh thresh2];   %200

True_pos = zeros(1,length(thresh));
False_pos = zeros(1,length(thresh));
False_neg = zeros(1,length(thresh));
%small - 19
for i = 1:numScales
    True_pos_baseline{i} = zeros(1,length(thresh));
    False_pos_baseline{i} = zeros(1,length(thresh));
    False_neg_baseline{i} = zeros(1,length(thresh));
end

%now randomly select 500 query locations:
%randQueries = All_QueryFeats(randids,:);

tic;

if opt_loadPreComputed == 1
    
else
    clear allDiffs_byScale;
    for k = 1:numScales
        allDiffs_byScale{k} = pdist2(All_QueryFeats{k},All_DbaseFeats{k});
    end    
    save(['precomputed_' feature_type '.mat'],'allDiffs_byScale','-v7.3');
end

if opt_normPeriodic == 1
    ns1 = 30; %these are the best values!
    ns2 = 60;
    ns3 = 120;
    ns4 = 250;
    ns5 = 500;
    ns6 = 1000;
    ns7 = 2000;
    ns8 = 4000;
end
for i = 1:numScales
    s = scaleArray(i);   
    switch s
        case 1
            ii = 1;
        case 2
            ii = 2;
        case 3
            ii = 3;
        case 4
            ii = 4;
        case 6
            ii = 5;
        case 8
            ii = 6;
        case 11
            ii = 7;
        case 16
            ii = 8;
        case 23
            ii = 9;
    end
    if opt_normPeriodic == 1
        for j = 1:500
            D_temp(j,:) = allDiffs_byScale{ii}(randids(j),(24:end));
            
            %24:end is used to prevent data warping due to missing early
            %references at large scales (remember, reference images are
            %sequenced too in the past direction). But, need to remember
            %that the final_match will be out by 23 positions due to this!
            %(this is a little hacky, will need to work out how best to
            %omit the first 23 values in the actual norm section later)
        end
        D_z = [];
        sz = size(D_temp);
        switch s
            case 1
                for k = 1:round(sz(2)/ns1)
                    if k == round(sz(2)/ns1)
                        start = 1 + (k-1)*ns1;
                        finish = sz(2);
                    else
                        start = 1 + (k-1)*ns1;
                        finish = k*ns1;
                    end
                    D_z = [D_z zscore(D_temp(:,start:finish),[],2)];
                end
            case 2
                for k = 1:round(sz(2)/ns2)
                    if k == round(sz(2)/ns2)
                        start = 1 + (k-1)*ns2;
                        finish = sz(2);
                    else
                        start = 1 + (k-1)*ns2;
                        finish = k*ns2;
                    end
                    D_z = [D_z zscore(D_temp(:,start:finish),[],2)];
                end
            case 3
                for k = 1:round(sz(2)/ns3)
                    if k == round(sz(2)/ns3)
                        start = 1 + (k-1)*ns3;
                        finish = sz(2);
                    else
                        start = 1 + (k-1)*ns3;
                        finish = k*ns3;
                    end
                    D_z = [D_z zscore(D_temp(:,start:finish),[],2)];
                end
            case 4
                for k = 1:round(sz(2)/ns4)
                    if k == round(sz(2)/ns4)
                        start = 1 + (k-1)*ns4;
                        finish = sz(2);
                    else
                        start = 1 + (k-1)*ns4;
                        finish = k*ns4;
                    end
                    D_z = [D_z zscore(D_temp(:,start:finish),[],2)];
                end
            case 6
                for k = 1:round(sz(2)/ns5)
                    if k == round(sz(2)/ns5)
                        start = 1 + (k-1)*ns5;
                        finish = sz(2);
                    else
                        start = 1 + (k-1)*ns5;
                        finish = k*ns5;
                    end
                    D_z = [D_z zscore(D_temp(:,start:finish),[],2)];
                end
            case 8
                for k = 1:round(sz(2)/ns6)
                    if k == round(sz(2)/ns6)
                        start = 1 + (k-1)*ns6;
                        finish = sz(2);
                    else
                        start = 1 + (k-1)*ns6;
                        finish = k*ns6;
                    end
                    D_z = [D_z zscore(D_temp(:,start:finish),[],2)];
                end
            case 11
                for k = 1:round(sz(2)/ns7)
                    if k == round(sz(2)/ns7)
                        start = 1 + (k-1)*ns7;
                        finish = sz(2);
                    else
                        start = 1 + (k-1)*ns7;
                        finish = k*ns7;
                    end
                    D_z = [D_z zscore(D_temp(:,start:finish),[],2)];
                end
            case 16
                for k = 1:round(sz(2)/ns8)
                    if k == round(sz(2)/ns8)
                        start = 1 + (k-1)*ns8;
                        finish = sz(2);
                    else
                        start = 1 + (k-1)*ns8;
                        finish = k*ns8;
                    end
                    D_z = [D_z zscore(D_temp(:,start:finish),[],2)];
                end
            case 23 %largest scale
                start = 1;
                finish = sz(2);
                D_z = [D_z zscore(D_temp(:,start:finish),[],2)];
        end
        Dis_scale{i} = D_z;
        Dis_orig{i} = D_temp;
    else
        for j = 1:size(randQueries,1) %should be 1:500
            Diff(j,:) = allDiffs_byScale{i}(randids(j),:);
        end
        Dis_scale{i} = Diff;
        Dis_orig{i} = Diff;
        clear Diff;
    end
end

%now combine the different scale sequence scores
%small sequences will be more location accurate on the current location,
%where-as long sequences will be more inaccurate by location (but less
%perceptually aliased).

if opt_normPeriodic == 1
    D_super = zeros(size(Dis_scale{1}));
    for i = 1:size(Dis_scale,2)
        D_super = D_super + Dis_scale{i};
    end    
else  
    D_super = zeros(size(Dis_scale{1}));
    for i = 1:size(Dis_scale,2)
        zdis = zscore(Dis_scale{i},[],2);
        D_super = D_super + zdis;
    end
end

if opt_postz == 1
    DS_z = zscore(D_super,[],2);
    [final_quality,final_match] = min(DS_z,[],2);
    final_match = final_match+23; %because I removed the first 24 refs
    final_quality = final_quality*-1;
else
    [final_quality,final_match] = min(D_super,[],2);  % best match is the most negative value in D_super
    final_match = final_match+23; %because I removed the first 24 refs
    final_quality = final_quality*-1;
end

time = toc;
timePerFrame = time/500;
save([save_name 'FrontView_matchComputeTime' feature_type num2str(numScales) 'scales' '.mat'],'time','timePerFrame');

%GT eval
%write some code here to eval GT...
flag = 0;
recall_count = 0;
for i = 1:length(final_match)
    d = abs(randids(i) - final_match(i));
    dMS_Store(i) = d;
    if d < GT_tol
        for t = 1:length(thresh)
            if final_quality(i) > thresh(t)
                True_pos(t) = True_pos(t) + 1;
            else
                False_neg(t) = False_neg(t) + 1;
            end
        end
        recall_count = recall_count + 1;
    else    
        for t = 1:length(thresh)
            if final_quality(i) > thresh(t)
                False_pos(t) = False_pos(t) + 1;
            else
                False_neg(t) = False_neg(t) + 1;
            end
        end
    end
end
recall = recall_count / length(final_match)

%now run comparison to single frame baseline...
for j = 1:numScales
    if opt_postz == 1
        D_z = zscore(Dis_orig{j},[],2);
        [quality{j},matches{j}] = min(D_z,[],2);
        matches{j} = matches{j}+23;
        %matches{j} = ((matches{j}*4)+23)-1;
        quality{j} = quality{j}.*-1;
    else
        [quality{j},matches{j}] = min(log(Dis_scale{j}),[],2);
        matches{j} = matches{j}+23;
        %matches{j} = ((matches{j}*4)+23)-1;
        quality{j} = quality{j}.*-1;
    end
    %%  Eval GT
    flag = 0;
    recall_count = 0;
    for i = 1:length(matches{j})
        d = abs(randids(i) - matches{j}(i));
        dSS_Store{j}(i) = d;
        if d <= GT_tol
            for t = 1:length(thresh)
                if quality{j}(i) > thresh(t)
                    True_pos_baseline{j}(t) = True_pos_baseline{j}(t) + 1;
                else
                    False_neg_baseline{j}(t) = False_neg_baseline{j}(t) + 1;
                end
            end
            recall_count = recall_count + 1;
        else
            for t = 1:length(thresh)
                if quality{j}(i) > thresh(t)
                    False_pos_baseline{j}(t) = False_pos_baseline{j}(t) + 1;
                else
                    False_neg_baseline{j}(t) = False_neg_baseline{j}(t) + 1;
                end
            end
        end
    end
    recall_base{j} = recall_count / length(matches{j})
end
for t = 1:length(thresh)
    Precision(t) = True_pos(t)/(True_pos(t) + False_pos(t));
    Recall(t) = True_pos(t)/(True_pos(t) + False_neg(t));
    F1score(t) = 2*True_pos(t) / (2*True_pos(t) + False_pos(t) + False_neg(t));
end
for i = 1:numScales
    for t = 1:length(thresh)
        Precision_Baseline{i}(t) = True_pos_baseline{i}(t)/(True_pos_baseline{i}(t) + False_pos_baseline{i}(t));
        Recall_Baseline{i}(t) = True_pos_baseline{i}(t)/(True_pos_baseline{i}(t) + False_neg_baseline{i}(t));
        F1score_Baseline{i}(t) = 2*True_pos_baseline{i}(t) / (2*True_pos_baseline{i}(t) + False_pos_baseline{i}(t) + False_neg_baseline{i}(t));
    end
    Precision_Baseline{i}(isnan(Precision_Baseline{i})) = 1;
end

Precision(isnan(Precision)) = 1;

rP = Precision; rR = Recall; 
rP = fliplr(rP); rR = fliplr(rR);
AUC = trapz(rR,rP)

for i = 1:numScales
    rBp{i} = Precision_Baseline{i}; rBr{i} = Recall_Baseline{i};
    rBpf{i} = fliplr(rBp{i}); rBrf{i} = fliplr(rBr{i});
    AUC_Baseline{i} = trapz(rBrf{i},rBpf{i});  
    maxF1Score_Baseline{i} = max(F1score_Baseline{i});
end

maxF1Score = max(F1score);

scaleNum = [];
for i = 1:length(scaleArray)
    scaleNum = [scaleNum ['_',num2str(scaleArray(i))]];
end

if opt_plotFigs == 1
figure
hold on
p1 = plot(Recall,Precision,'-r');
p2 = plot(Recall_Baseline{1},Precision_Baseline{1},'-b');
p3 = plot(Recall_Baseline{2},Precision_Baseline{2},'--b');
if numScales > 2
    p4 = plot(Recall_Baseline{3},Precision_Baseline{3},'-g');
end
if numScales > 3
    p5 = plot(Recall_Baseline{4},Precision_Baseline{4},'--g');
end    
if numScales > 4
    p6 = plot(Recall_Baseline{5},Precision_Baseline{5},'-m');
end    
if numScales > 5
    p7 = plot(Recall_Baseline{6},Precision_Baseline{6},'--m');
end    
if numScales > 6
    p8 = plot(Recall_Baseline{7},Precision_Baseline{7},'-c');
end    
if numScales > 7
    p9 = plot(Recall_Baseline{8},Precision_Baseline{8},'--c');
end    
if numScales > 8
    p10 = plot(Recall_Baseline{9},Precision_Baseline{9},'-y');
end    
if numScales > 9
    p11 = plot(Recall_Baseline{10},Precision_Baseline{10},'--y');
end    
if numScales > 10
    p12 = plot(Recall_Baseline{11},Precision_Baseline{11},'-k');
end    
if numScales > 11
    p13 = plot(Recall_Baseline{12},Precision_Baseline{12},'--k');
end    
if numScales > 12
    p14 = plot(Recall_Baseline{13},Precision_Baseline{13},'-.b');
end 
if numScales > 13
    p15 = plot(Recall_Baseline{14},Precision_Baseline{14},'-.g');
end 
if numScales > 14
    p16 = plot(Recall_Baseline{15},Precision_Baseline{15},'-.m');
end 
if numScales > 15
    p17 = plot(Recall_Baseline{16},Precision_Baseline{16},'-.k');
end 
title([feature_type ' on Nearmaps with Scales: ',num2str(scaleArray)]);
xlabel('Recall');
ylabel('Precision');
xlim([0 1]);
ylim([0 1]);
grid on
ax = gca;
ax.FontSize = 16;
switch numScales
    case 2
        legend([p1 p2 p3],{'With Scales',['Baseline Scale ',num2str(scaleArray(1))],...
            ['Baseline Scale ',num2str(scaleArray(2))]});        
    case 3
        legend([p1 p2 p3 p4],{'With Scales',['Baseline Scale ',num2str(scaleArray(1))],...
            ['Baseline Scale ',num2str(scaleArray(2))],...
            ['Baseline Scale ',num2str(scaleArray(3))]});
    case 4
        legend([p1 p2 p3 p4 p5],{'With Scales',['Baseline Scale ',num2str(scaleArray(1))],...
            ['Baseline Scale ',num2str(scaleArray(2))],...
            ['Baseline Scale ',num2str(scaleArray(3))],...
            ['Baseline Scale ',num2str(scaleArray(4))]});
    case 5
        legend([p1 p2 p3 p4 p5 p6],{'With Scales',['Baseline Scale ',num2str(scaleArray(1))],...
            ['Baseline Scale ',num2str(scaleArray(2))],...
            ['Baseline Scale ',num2str(scaleArray(3))],...
            ['Baseline Scale ',num2str(scaleArray(4))],...
            ['Baseline Scale ',num2str(scaleArray(5))]});      
    case 6
        legend([p1 p2 p3 p4 p5 p6 p7],{'With Scales',['Baseline Scale ',num2str(scaleArray(1))],...
            ['Baseline Scale ',num2str(scaleArray(2))],...
            ['Baseline Scale ',num2str(scaleArray(3))],...
            ['Baseline Scale ',num2str(scaleArray(4))],...
            ['Baseline Scale ',num2str(scaleArray(5))],...
            ['Baseline Scale ',num2str(scaleArray(6))]});
    case 7
        legend([p1 p2 p3 p4 p5 p6 p7 p8],{'With Scales',['Baseline Scale ',num2str(scaleArray(1))],...
            ['Baseline Scale ',num2str(scaleArray(2))],...
            ['Baseline Scale ',num2str(scaleArray(3))],...
            ['Baseline Scale ',num2str(scaleArray(4))],...
            ['Baseline Scale ',num2str(scaleArray(5))],...
            ['Baseline Scale ',num2str(scaleArray(6))],...
            ['Baseline Scale ',num2str(scaleArray(7))]}); 
    case 8
        legend([p1 p2 p3 p4 p5 p6 p7 p8 p9],...
            {'With Scales',['Baseline Scale ',num2str(scaleArray(1))],...
            ['Baseline Scale ',num2str(scaleArray(2))],...
            ['Baseline Scale ',num2str(scaleArray(3))],...
            ['Baseline Scale ',num2str(scaleArray(4))],...
            ['Baseline Scale ',num2str(scaleArray(5))],...
            ['Baseline Scale ',num2str(scaleArray(6))],...
            ['Baseline Scale ',num2str(scaleArray(7))],...
            ['Baseline Scale ',num2str(scaleArray(8))]});   
    case 9
        legend([p1 p2 p3 p4 p5 p6 p7 p8 p9 p10],...
            {'With Scales',['Baseline Scale ',num2str(scaleArray(1))],...
            ['Baseline Scale ',num2str(scaleArray(2))],...
            ['Baseline Scale ',num2str(scaleArray(3))],...
            ['Baseline Scale ',num2str(scaleArray(4))],...
            ['Baseline Scale ',num2str(scaleArray(5))],...
            ['Baseline Scale ',num2str(scaleArray(6))],...
            ['Baseline Scale ',num2str(scaleArray(7))],...
            ['Baseline Scale ',num2str(scaleArray(8))],...
            ['Baseline Scale ',num2str(scaleArray(9))]}); 
    case 10
        legend([p1 p2 p3 p4 p5 p6 p7 p8 p9 p10 p11],...
            {'With Scales',['Baseline Scale ',num2str(scaleArray(1))],...
            ['Baseline Scale ',num2str(scaleArray(2))],...
            ['Baseline Scale ',num2str(scaleArray(3))],...
            ['Baseline Scale ',num2str(scaleArray(4))],...
            ['Baseline Scale ',num2str(scaleArray(5))],...
            ['Baseline Scale ',num2str(scaleArray(6))],...
            ['Baseline Scale ',num2str(scaleArray(7))],...
            ['Baseline Scale ',num2str(scaleArray(8))],...
            ['Baseline Scale ',num2str(scaleArray(9))],...
            ['Baseline Scale ',num2str(scaleArray(10))]});   
    case 11
        legend([p1 p2 p3 p4 p5 p6 p7 p8 p9 p10 p11 p12],...
            {'With Scales',['Baseline Scale ',num2str(scaleArray(1))],...
            ['Baseline Scale ',num2str(scaleArray(2))],...
            ['Baseline Scale ',num2str(scaleArray(3))],...
            ['Baseline Scale ',num2str(scaleArray(4))],...
            ['Baseline Scale ',num2str(scaleArray(5))],...
            ['Baseline Scale ',num2str(scaleArray(6))],...
            ['Baseline Scale ',num2str(scaleArray(7))],...
            ['Baseline Scale ',num2str(scaleArray(8))],...
            ['Baseline Scale ',num2str(scaleArray(9))],...
            ['Baseline Scale ',num2str(scaleArray(10))],...
            ['Baseline Scale ',num2str(scaleArray(11))]});  
    case 12
        legend([p1 p2 p3 p4 p5 p6 p7 p8 p9 p10 p11 p12 p13],...
            {'With Scales',['Baseline Scale ',num2str(scaleArray(1))],...
            ['Baseline Scale ',num2str(scaleArray(2))],...
            ['Baseline Scale ',num2str(scaleArray(3))],...
            ['Baseline Scale ',num2str(scaleArray(4))],...
            ['Baseline Scale ',num2str(scaleArray(5))],...
            ['Baseline Scale ',num2str(scaleArray(6))],...
            ['Baseline Scale ',num2str(scaleArray(7))],...
            ['Baseline Scale ',num2str(scaleArray(8))],...
            ['Baseline Scale ',num2str(scaleArray(9))],...
            ['Baseline Scale ',num2str(scaleArray(10))],...
            ['Baseline Scale ',num2str(scaleArray(11))],...
            ['Baseline Scale ',num2str(scaleArray(12))]});
    case 13
        legend([p1 p2 p3 p4 p5 p6 p7 p8 p9 p10 p11 p12 p13 p14],...
            {'With Scales',['Baseline Scale ',num2str(scaleArray(1))],...
            ['Baseline Scale ',num2str(scaleArray(2))],...
            ['Baseline Scale ',num2str(scaleArray(3))],...
            ['Baseline Scale ',num2str(scaleArray(4))],...
            ['Baseline Scale ',num2str(scaleArray(5))],...
            ['Baseline Scale ',num2str(scaleArray(6))],...
            ['Baseline Scale ',num2str(scaleArray(7))],...
            ['Baseline Scale ',num2str(scaleArray(8))],...
            ['Baseline Scale ',num2str(scaleArray(9))],...
            ['Baseline Scale ',num2str(scaleArray(10))],...
            ['Baseline Scale ',num2str(scaleArray(11))],...
            ['Baseline Scale ',num2str(scaleArray(12))],...
            ['Baseline Scale ',num2str(scaleArray(13))]});
    case 14
        legend([p1 p2 p3 p4 p5 p6 p7 p8 p9 p10 p11 p12 p13 p14 p15],...
            {'With Scales',['Baseline Scale ',num2str(scaleArray(1))],...
            ['Baseline Scale ',num2str(scaleArray(2))],...
            ['Baseline Scale ',num2str(scaleArray(3))],...
            ['Baseline Scale ',num2str(scaleArray(4))],...
            ['Baseline Scale ',num2str(scaleArray(5))],...
            ['Baseline Scale ',num2str(scaleArray(6))],...
            ['Baseline Scale ',num2str(scaleArray(7))],...
            ['Baseline Scale ',num2str(scaleArray(8))],...
            ['Baseline Scale ',num2str(scaleArray(9))],...
            ['Baseline Scale ',num2str(scaleArray(10))],...
            ['Baseline Scale ',num2str(scaleArray(11))],...
            ['Baseline Scale ',num2str(scaleArray(12))],...
            ['Baseline Scale ',num2str(scaleArray(13))],...
            ['Baseline Scale ',num2str(scaleArray(14))]});
    case 15
        legend([p1 p2 p3 p4 p5 p6 p7 p8 p9 p10 p11 p12 p13 p14 p15 p16],...
            {'With Scales',['Baseline Scale ',num2str(scaleArray(1))],...
            ['Baseline Scale ',num2str(scaleArray(2))],...
            ['Baseline Scale ',num2str(scaleArray(3))],...
            ['Baseline Scale ',num2str(scaleArray(4))],...
            ['Baseline Scale ',num2str(scaleArray(5))],...
            ['Baseline Scale ',num2str(scaleArray(6))],...
            ['Baseline Scale ',num2str(scaleArray(7))],...
            ['Baseline Scale ',num2str(scaleArray(8))],...
            ['Baseline Scale ',num2str(scaleArray(9))],...
            ['Baseline Scale ',num2str(scaleArray(10))],...
            ['Baseline Scale ',num2str(scaleArray(11))],...
            ['Baseline Scale ',num2str(scaleArray(12))],...
            ['Baseline Scale ',num2str(scaleArray(13))],...
            ['Baseline Scale ',num2str(scaleArray(14))],...
            ['Baseline Scale ',num2str(scaleArray(15))]});
    case 16
        legend([p1 p2 p3 p4 p5 p6 p7 p8 p9 p10 p11 p12 p13 p14 p15 p16 p17],...
            {'With Scales',['Baseline Scale ',num2str(scaleArray(1))],...
            ['Baseline Scale ',num2str(scaleArray(2))],...
            ['Baseline Scale ',num2str(scaleArray(3))],...
            ['Baseline Scale ',num2str(scaleArray(4))],...
            ['Baseline Scale ',num2str(scaleArray(5))],...
            ['Baseline Scale ',num2str(scaleArray(6))],...
            ['Baseline Scale ',num2str(scaleArray(7))],...
            ['Baseline Scale ',num2str(scaleArray(8))],...
            ['Baseline Scale ',num2str(scaleArray(9))],...
            ['Baseline Scale ',num2str(scaleArray(10))],...
            ['Baseline Scale ',num2str(scaleArray(11))],...
            ['Baseline Scale ',num2str(scaleArray(12))],...
            ['Baseline Scale ',num2str(scaleArray(13))],...
            ['Baseline Scale ',num2str(scaleArray(14))],...
            ['Baseline Scale ',num2str(scaleArray(15))],...
            ['Baseline Scale ',num2str(scaleArray(16))]});
end
legend('Location','southwest');
end

if opt_saveMe == 1
    file_fig =[file_name feature_type '_Scales' scaleNum '_runNum' num2str(runNum) '.fig'];
    saveas(gcf,file_fig);
    file_fig =[file_name feature_type '_Scales' scaleNum '_runNum' num2str(runNum) '.jpg'];
    saveas(gcf,file_fig);
    file_fig =[file_name feature_type '_Scales' scaleNum '_runNum' num2str(runNum) '.eps'];
    saveas(gcf,file_fig,'epsc');
    
    close all;
    if numScales == 9
        Plot_GTTol(dMS_Store,dSS_Store,numScales,file_name,scaleArray,scaleNum,runNum,feature_type);
        close all;
    end
    
    save([save_name feature_type,'_',labelid,'_results_',date,...
        '_Scales',scaleNum,'_runNum',num2str(runNum),'.mat'],...
        'recall','recall_base','scaleArray','Precision','Recall','Precision_Baseline',...
        'Recall_Baseline','maxF1Score','maxF1Score_Baseline','AUC','AUC_Baseline',...
        'dMS_Store','dSS_Store');
end    
end
function Plot_GTTol(dMS_Store,dSS_Store,numScales,file_name,scaleArray,scaleNum,runNum,feature_type)
%plot new graph based on Gt tol radius:

    recall_MS = zeros(1,500);
    recall_SS = zeros(numScales,500);
    for i = 1:500 %meters
        for j = 1:length(dMS_Store)
            if dMS_Store(j) < i
                recall_MS(i) = recall_MS(i) + 1;
            end
            for k = 1:numScales
                if dSS_Store{k}(j) < i
                    recall_SS(k,i) = recall_SS(k,i) + 1;
                end
            end
        end
    end

    xaxisvals = 1:500;

    recall_MS = recall_MS./length(dMS_Store);
    for k = 1:numScales    
        recall_SS(k,:) = recall_SS(k,:)./length(dMS_Store);
    end    

    figure
    p1 = plot(xaxisvals,recall_MS,'-r');
    hold on
    p2 = plot(xaxisvals,recall_SS(1,:),'-b');
    p3 = plot(xaxisvals,recall_SS(2,:),'--b');
    p4 = plot(xaxisvals,recall_SS(3,:),'-.b');
    p5 = plot(xaxisvals,recall_SS(4,:),'-g');
    p6 = plot(xaxisvals,recall_SS(5,:),'--g');
    p7 = plot(xaxisvals,recall_SS(6,:),'-.g');
    p8 = plot(xaxisvals,recall_SS(7,:),'-k');
    p9 = plot(xaxisvals,recall_SS(8,:),'--k');
    p10 = plot(xaxisvals,recall_SS(9,:),'-.k');

    title([feature_type ' over Varying Ground Truth Tolerance']);
    xlabel('Frame Distance from Exact Match');
    ylabel('Recall Rate');
    xlim([1 50]);
    ylim([0 1]);
    grid on
    ax = gca;
    ax.FontSize = 16;
    legend([p1 p2 p3 p4 p5 p6 p7 p8 p9 p10],...
        {'With Scales',['Baseline Scale ',num2str(scaleArray(1))],...
        ['Baseline Scale ',num2str(scaleArray(2))],...
        ['Baseline Scale ',num2str(scaleArray(3))],...
        ['Baseline Scale ',num2str(scaleArray(4))],...
        ['Baseline Scale ',num2str(scaleArray(5))],...
        ['Baseline Scale ',num2str(scaleArray(6))],...
        ['Baseline Scale ',num2str(scaleArray(7))],...
        ['Baseline Scale ',num2str(scaleArray(8))],...
        ['Baseline Scale ',num2str(scaleArray(9))]});
    legend('Location','southeast');

    file_fig =[file_name feature_type '_Scales' scaleNum '_runNum' num2str(runNum) 'Recall_over_GTTol' '.fig'];
    saveas(gcf,file_fig);
    file_fig =[file_name feature_type '_Scales' scaleNum '_runNum' num2str(runNum) 'Recall_over_GTTol' '.jpg'];
    saveas(gcf,file_fig);
    file_fig =[file_name feature_type '_Scales' scaleNum '_runNum' num2str(runNum) 'Recall_over_GTTol' '.eps'];
    saveas(gcf,file_fig,'epsc');

end

