
function [AUC,AUC_Baseline] = multiScaleCombine(mainFolder,scaleArray,runNum,randids,feature_type)

%dataset = 'Nearmaps_Vloop';
dataset1 = 'Nearmaps_Rural';
dataset2 = 'Nearmaps';  

GT_tol = 50; %meters

opt_postz = 1;

opt_visualize = 1;

opt_saveMe = 1;

numScales = length(scaleArray);

if numScales < 9
    opt_visualize = 0; %currently not configured for less than 9 scales
end

if opt_visualize == 1
    visSpeed = 0.5;  %seconds per image
    
    configObj1_17 = Config;
    configObj2_16 = Config;
    configObj1_18 = Config;  %dataset1 (rural)
    configObj2_18 = Config;  %dataset2 (urban)
    configObj1_19 = Config;
    configObj2_19 = Config;
    
    Qfol1_17 = 'D:\Ubuntu\Nearmaps_Datasets\Brisbane_Rural_17_2019\raw_images';
    Qfol2_16 = 'D:\Ubuntu\Nearmaps_Datasets\Brisbane_MultiLoop_highres_16_2019\raw_images';
    Rfol1_17 = 'D:\Ubuntu\Nearmaps_Datasets\Brisbane_Rural_17_2013\raw_images';
    Rfol2_16 = 'D:\Ubuntu\Nearmaps_Datasets\Brisbane_MultiLoop_highres_16_2013\raw_images';
    
    Qfol1_18 = 'D:\Ubuntu\Nearmaps_Datasets\Brisbane_Rural_18_2019\raw_images';
    Qfol2_18 = 'D:\Ubuntu\Nearmaps_Datasets\Brisbane_MultiLoop_18_2019\raw_images';
    Rfol1_18 = 'D:\Ubuntu\Nearmaps_Datasets\Brisbane_Rural_18_2013\raw_images';
    Rfol2_18 = 'D:\Ubuntu\Nearmaps_Datasets\Brisbane_MultiLoop_18_2013\raw_images';
    
    Qfol1_19 = 'D:\Ubuntu\Nearmaps_Datasets\Brisbane_Rural_19_2019\raw_images';
    Qfol2_19 = 'D:\Ubuntu\Nearmaps_Datasets\Brisbane_MultiLoop_19_2019\raw_images';
    Rfol1_19 = 'D:\Ubuntu\Nearmaps_Datasets\Brisbane_Rural_19_2013\raw_images';
    Rfol2_19 = 'D:\Ubuntu\Nearmaps_Datasets\Brisbane_MultiLoop_19_2013\raw_images';
    
    configObj1_17 = loadImages(configObj1_17,Rfol1_17,Qfol1_17);
    configObj2_16 = loadImages(configObj2_16,Rfol2_16,Qfol2_16);
    configObj1_18 = loadImages(configObj1_18,Rfol1_18,Qfol1_18);
    configObj2_18 = loadImages(configObj2_18,Rfol2_18,Qfol2_18);
    configObj1_19 = loadImages(configObj1_19,Rfol1_19,Qfol1_19);
    configObj2_19 = loadImages(configObj2_19,Qfol2_19,Rfol2_19);
    
    %array to store the single scale correct matches per visualization:
    storeTicks = {}; %each cell stores 9 single scale binary decisions
    %1 = true match, 0 = false match
end

%load('F:\MATLAB_2019_Working\Multi_Scale_Fusion_Ver1\IJNN_Zetao_Stlucia_Code\Nearmaps\features\gps_rural\Nearmaps_Rural_Loop_Full_GPS.mat');
load('Nearmaps_Rural_Loop_Full_GPS.mat');
RuralLats = allLats; RuralLongs = allLongs;
%load('F:\MATLAB_2019_Working\Multi_Scale_Fusion_Ver1\IJNN_Zetao_Stlucia_Code\Nearmaps\features\gps_loop\Nearmaps_Loop_Full_GPS.mat');
load('Nearmaps_Loop_Full_GPS.mat');
UrbanLats = allLats; UrbanLongs = allLongs;

RefLatArray = [RuralLats UrbanLats]; RefLongArray = [RuralLongs UrbanLongs];

labelid = 'GPS';  %in 2-D datasets, always GPS

%for generating and saving graphs:
file_name = [mainFolder,'/',feature_type,'_',labelid,'_results_',date,'/Figures/'];
save_name = [mainFolder,'/',feature_type,'_',labelid,'_results_',date,'/Data/'];

mkdir(file_name);
mkdir(save_name);

QueryLatArray = RefLatArray(randids); QueryLongArray = RefLongArray(randids);

tic;

for i = 1:numScales
    load(['Extracted_Features/',dataset1,'_Sqrt2_Scale_',num2str(scaleArray(i)),'_2013_',feature_type,'.mat']);
    feature_matrix2 = feature_matrix;
    load(['Extracted_Features/',dataset2,'_Sqrt2_Scale_',num2str(scaleArray(i)),'_2013_',feature_type,'.mat']);
    bigfm = [feature_matrix2; feature_matrix];
    s_train{i} = bigfm; %if this was C++ I would certainly have to prealloc this
    load(['Extracted_Features/',dataset1,'_Sqrt2_Scale_',num2str(scaleArray(i)),'_2019_',feature_type,'.mat']);
    feature_matrix2 = feature_matrix;
    load(['Extracted_Features/',dataset2,'_Sqrt2_Scale_',num2str(scaleArray(i)),'_2019_',feature_type,'.mat']);
    bigfm = [feature_matrix2; feature_matrix];
    randfm = bigfm(randids,:);
    s_test{i} = randfm;
end

thresh = 0:0.1:9.9;  %100
thresh2 = 10:0.5:59.5;   %100
thresh = [thresh thresh2]; %200
    
True_pos = zeros(1,length(thresh));
False_pos = zeros(1,length(thresh));
False_neg = zeros(1,length(thresh));
%small - 19
for i = 1:numScales
    True_pos_baseline{i} = zeros(1,length(thresh));
    False_pos_baseline{i} = zeros(1,length(thresh));
    False_neg_baseline{i} = zeros(1,length(thresh));
end    

for i = 1:numScales
    train_data = s_train{i};
    test_data = s_test{i};
    
    D_temp = pdist2(test_data,train_data);
    D_ma = max(D_temp); D_mi = min(D_temp); D_d = abs(D_ma - D_mi);
    D_temp = D_temp - D_mi;   %set min score to 0
    D_temp = D_temp ./ D_d;   %scale
    Dis_scale{i} = D_temp;
end    

%saveDis = Dis_scale;

hinge_array_L0 = (zeros(size(Dis_scale{1},1),size(Dis_scale{1},2)))+0.99;
min_hinge_L0 = 0.01;

min_hinge = min_hinge_L0;
hinge_array = hinge_array_L0;

D_super = zeros(size(Dis_scale{1}));

for i = 1:size(Dis_scale,2)
   Dis_scale{i} = Dis_scale{i} + min_hinge;
   cat_array = cat(3,Dis_scale{i},hinge_array);
   Dis_scale{i} = min(cat_array,[],3);
   
   D_super = D_super + log(Dis_scale{i});
end

if opt_postz == 1
    DS_z = zscore(D_super,[],2);
    [final_quality,final_match] = min(DS_z,[],2);
    final_quality = final_quality*-1;
else
    [final_quality,final_match] = min(D_super,[],2);  % best match is the most negative value in D_super
    final_quality = final_quality*-1;
end

time = toc;
timePerFrame = time/500;
save('matchComputeTime.mat','time','timePerFrame');

%now compare final_match to GT
%% GT eval
flag = 0;
recall_count = 0;
for i = 1:length(final_match)
    d = GPS2Meters(QueryLatArray(i),QueryLongArray(i),...
        RefLatArray(final_match(i)),RefLongArray(final_match(i)));
    dMS_Store(i) = d;
    if d <= GT_tol
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
%%
recall = recall_count / length(final_match)

%now run comparison to single frame baseline...
for j = 1:numScales
    if opt_postz == 1
        l_Dis_single = log(Dis_scale{j});
        D_z = zscore(l_Dis_single,[],2);
        [quality{j},matches{j}] = min(D_z,[],2);
        quality{j} = quality{j}.*-1;
    else
        [quality{j},matches{j}] = min(log(Dis_scale{j}),[],2);
        quality{j} = quality{j}.*-1;
    end
    %%  Eval GT
    flag = 0;
    recall_count = 0;
    for i = 1:length(matches{j})
        d = GPS2Meters(QueryLatArray(i),QueryLongArray(i),...
            RefLatArray(matches{j}(i)),RefLongArray(matches{j}(i)));
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
if opt_visualize == 1
    %red_box = 0;
    
%     configObj1_17 = loadImages(configObj1_17,Rfol1_17,Qfol1_17);
%     configObj2_16 = loadImages(configObj2_16,Rfol2_16,Qfol2_16);
%     configObj1_18 = loadImages(configObj1_18,Rfol1_18,Qfol1_18);
%     configObj2_18 = loadImages(configObj2_18,Rfol2_18,Qfol2_18);
%     configObj1_19 = loadImages(configObj1_19,Rfol1_19,Qfol1_19);
%     configObj2_19 = loadImages(configObj2_19,Qfol2_19,Rfol2_19); 

        %the crop sizes below are for a scale factor of root(2)
        cropSize{1} = [428 428 428 428]; % final size: 224 x 224 pixels
        cropSize{2} = [382 382 382 382]; % final size: 316 x 316 pixels
        cropSize{3} = [316 316 316 316]; % final size: 448 x 448 pixels
        cropSize{4} = [224 224 224 224]; % final size: 632 x 632 pixels
        cropSize{5} = [92 92 92 92];     % final size: 896 x 896 pixels
        %larger zoomed image (1080 x 1080 pixels at zoom 18)
        cropSize{6} = [224 224 224 224]; % final size: 632 x 632 pixels (eq. to 1264 by 1264)
        cropSize{7} = [92 92 92 92];     % final size: 896 x 896 pixels (eq. to 1792 by 1792)
        %even larger zoomed image (2160 x 2160 pixels at zoom 16)
        cropSize{8} = [764 764 764 764];    % final size: 632 x 632 pixels (eq. to 2528 by 2528)
        cropSize{9} = [632 632 632 632];    % final size: 896 x 896 pixels (eq. to 3584 by 3584)
        %zoom 17 (1080 x 1080):
        cropSize{10} = [224 224 224 224];
        cropSize{11} = [92 92 92 92];    

    for i = 1:length(final_match)
        %option: visualize
        iQ = randids(i);  %return real query id
        if iQ > 1597  %urban dataset
            iQ = iQ - 1597;
            ImQ2_16 = imread(fullfile(configObj2_16.filesQ.path,configObj2_16.filesQ.fQ{iQ}));
            ImQ2_18 = imread(fullfile(configObj2_18.filesQ.path,configObj2_18.filesQ.fQ{iQ}));
            ImQ2_19 = imread(fullfile(configObj2_19.filesQ.path,configObj2_19.filesQ.fQ{iQ}));
            
            szIm = size(ImQ2_18);
            szIm16 = size(ImQ2_16);
            
            ImQ_S1 = ImQ2_19(cropSize{1}(1):(szIm(1)-cropSize{1}(2)),...
                cropSize{1}(3):(szIm(2)-cropSize{1}(4)),:);
            ImQ_S2 = ImQ2_19(cropSize{2}(1):(szIm(1)-cropSize{2}(2)),...
                cropSize{2}(3):(szIm(2)-cropSize{2}(4)),:);
            ImQ_S3 = ImQ2_19(cropSize{3}(1):(szIm(1)-cropSize{3}(2)),...
                cropSize{3}(3):(szIm(2)-cropSize{3}(4)),:);
            ImQ_S4 = ImQ2_19(cropSize{4}(1):(szIm(1)-cropSize{4}(2)),...
                cropSize{4}(3):(szIm(2)-cropSize{4}(4)),:);
            ImQ_S5 = ImQ2_19(cropSize{5}(1):(szIm(1)-cropSize{5}(2)),...
                cropSize{5}(3):(szIm(2)-cropSize{5}(4)),:);
            ImQ_S6 = ImQ2_18(cropSize{6}(1):(szIm(1)-cropSize{6}(2)),...
                cropSize{6}(3):(szIm(2)-cropSize{6}(4)),:);
            ImQ_S7 = ImQ2_18(cropSize{7}(1):(szIm(1)-cropSize{7}(2)),...
                cropSize{7}(3):(szIm(2)-cropSize{7}(4)),:);
            ImQ_S8 = ImQ2_16(cropSize{8}(1):(szIm16(1)-cropSize{8}(2)),...
                cropSize{8}(3):(szIm16(2)-cropSize{8}(4)),:);
            ImQ_S9 = ImQ2_16(cropSize{9}(1):(szIm16(1)-cropSize{9}(2)),...
                cropSize{9}(3):(szIm16(2)-cropSize{9}(4)),:);
            
            ImQ_S1 = imresize(ImQ_S1,[224 224],'lanczos3');
            ImQ_S2 = imresize(ImQ_S2,[224 224],'lanczos3');
            ImQ_S3 = imresize(ImQ_S3,[224 224],'lanczos3');
            ImQ_S4 = imresize(ImQ_S4,[224 224],'lanczos3');
            ImQ_S5 = imresize(ImQ_S5,[224 224],'lanczos3');
            ImQ_S6 = imresize(ImQ_S6,[224 224],'lanczos3');
            ImQ_S7 = imresize(ImQ_S7,[224 224],'lanczos3');
            ImQ_S8 = imresize(ImQ_S8,[224 224],'lanczos3');
            ImQ_S9 = imresize(ImQ_S9,[224 224],'lanczos3');     
        else     %rural dataset
            ImQ1_17 = imread(fullfile(configObj1_17.filesQ.path,configObj1_17.filesQ.fQ{iQ}));
            ImQ1_18 = imread(fullfile(configObj1_18.filesQ.path,configObj1_18.filesQ.fQ{iQ}));
            ImQ1_19 = imread(fullfile(configObj1_19.filesQ.path,configObj1_19.filesQ.fQ{iQ}));
            
            szIm = size(ImQ1_18);
            
            ImQ_S1 = ImQ1_19(cropSize{1}(1):(szIm(1)-cropSize{1}(2)),...
                cropSize{1}(3):(szIm(2)-cropSize{1}(4)),:);
            ImQ_S2 = ImQ1_19(cropSize{2}(1):(szIm(1)-cropSize{2}(2)),...
                cropSize{2}(3):(szIm(2)-cropSize{2}(4)),:);
            ImQ_S3 = ImQ1_19(cropSize{3}(1):(szIm(1)-cropSize{3}(2)),...
                cropSize{3}(3):(szIm(2)-cropSize{3}(4)),:);
            ImQ_S4 = ImQ1_19(cropSize{4}(1):(szIm(1)-cropSize{4}(2)),...
                cropSize{4}(3):(szIm(2)-cropSize{4}(4)),:);
            ImQ_S5 = ImQ1_19(cropSize{5}(1):(szIm(1)-cropSize{5}(2)),...
                cropSize{5}(3):(szIm(2)-cropSize{5}(4)),:);
            ImQ_S6 = ImQ1_18(cropSize{6}(1):(szIm(1)-cropSize{6}(2)),...
                cropSize{6}(3):(szIm(2)-cropSize{6}(4)),:);
            ImQ_S7 = ImQ1_18(cropSize{7}(1):(szIm(1)-cropSize{7}(2)),...
                cropSize{7}(3):(szIm(2)-cropSize{7}(4)),:);
            ImQ_S8 = ImQ1_17(cropSize{10}(1):(szIm(1)-cropSize{10}(2)),...
                cropSize{10}(3):(szIm(2)-cropSize{10}(4)),:);
            ImQ_S9 = ImQ1_17(cropSize{11}(1):(szIm(1)-cropSize{11}(2)),...
                cropSize{11}(3):(szIm(2)-cropSize{11}(4)),:);
            
            ImQ_S1 = imresize(ImQ_S1,[224 224],'lanczos3');
            ImQ_S2 = imresize(ImQ_S2,[224 224],'lanczos3');
            ImQ_S3 = imresize(ImQ_S3,[224 224],'lanczos3');
            ImQ_S4 = imresize(ImQ_S4,[224 224],'lanczos3');
            ImQ_S5 = imresize(ImQ_S5,[224 224],'lanczos3');
            ImQ_S6 = imresize(ImQ_S6,[224 224],'lanczos3');
            ImQ_S7 = imresize(ImQ_S7,[224 224],'lanczos3');
            ImQ_S8 = imresize(ImQ_S8,[224 224],'lanczos3');
            ImQ_S9 = imresize(ImQ_S9,[224 224],'lanczos3');         
        end   
        if final_match(i) > 1597
            iR = final_match(i) - 1597;
            try
                ImR1 = imread(fullfile(configObj2_19.filesR.path,configObj2_19.filesR.fR{iR}));
            catch
                error('debug');
            end  
        else    %rural dataset
            iR = final_match(i);
            try
                ImR1 = imread(fullfile(configObj1_19.filesR.path,configObj1_19.filesR.fR{iR}));
            catch
                error('debug');
            end  
        end 
        clear iR;
        %need to add all the scales and for loop
        for k = 1:numScales
            iR = matches{k}(i);
            if iR > 1597   %urban dataset
                iR = iR - 1597;
                switch k
                    case 1 %Scale 1
                        ImR = imread(fullfile(configObj2_19.filesR.path,configObj2_19.filesR.fR{iR}));
                        szIm = size(ImR);
                        ImR2_S1 = ImR(cropSize{1}(1):(szIm(1)-cropSize{1}(2)),...
                            cropSize{1}(3):(szIm(2)-cropSize{1}(4)),:);
                        ImR2_S1 = imresize(ImR2_S1,[224 224],'lanczos3');
                    case 2
                        ImR = imread(fullfile(configObj2_19.filesR.path,configObj2_19.filesR.fR{iR}));
                        szIm = size(ImR);
                        ImR2_S2 = ImR(cropSize{2}(1):(szIm(1)-cropSize{2}(2)),...
                            cropSize{2}(3):(szIm(2)-cropSize{2}(4)),:);
                        ImR2_S2 = imresize(ImR2_S2,[224 224],'lanczos3');
                    case 3
                        ImR = imread(fullfile(configObj2_19.filesR.path,configObj2_19.filesR.fR{iR}));
                        szIm = size(ImR);
                        ImR2_S3 = ImR(cropSize{3}(1):(szIm(1)-cropSize{3}(2)),...
                            cropSize{3}(3):(szIm(2)-cropSize{3}(4)),:);
                        ImR2_S3 = imresize(ImR2_S3,[224 224],'lanczos3');
                    case 4
                        ImR = imread(fullfile(configObj2_19.filesR.path,configObj2_19.filesR.fR{iR}));
                        szIm = size(ImR);
                        ImR2_S4 = ImR(cropSize{4}(1):(szIm(1)-cropSize{4}(2)),...
                            cropSize{4}(3):(szIm(2)-cropSize{4}(4)),:);
                        ImR2_S4 = imresize(ImR2_S4,[224 224],'lanczos3');
                    case 5
                        ImR = imread(fullfile(configObj2_19.filesR.path,configObj2_19.filesR.fR{iR}));
                        szIm = size(ImR);
                        ImR2_S5 = ImR(cropSize{5}(1):(szIm(1)-cropSize{5}(2)),...
                            cropSize{5}(3):(szIm(2)-cropSize{5}(4)),:);
                        ImR2_S5 = imresize(ImR2_S5,[224 224],'lanczos3');
                    case 6
                        ImR = imread(fullfile(configObj2_18.filesR.path,configObj2_18.filesR.fR{iR}));
                        szIm = size(ImR);
                        ImR2_S6 = ImR(cropSize{6}(1):(szIm(1)-cropSize{6}(2)),...
                            cropSize{6}(3):(szIm(2)-cropSize{6}(4)),:);
                        ImR2_S6 = imresize(ImR2_S6,[224 224],'lanczos3');
                    case 7
                        ImR = imread(fullfile(configObj2_18.filesR.path,configObj2_18.filesR.fR{iR}));
                        szIm = size(ImR);
                        ImR2_S7 = ImR(cropSize{7}(1):(szIm(1)-cropSize{7}(2)),...
                            cropSize{7}(3):(szIm(2)-cropSize{7}(4)),:);
                        ImR2_S7 = imresize(ImR2_S7,[224 224],'lanczos3');
                    case 8
                        ImR = imread(fullfile(configObj2_16.filesR.path,configObj2_16.filesR.fR{iR}));
                        szIm = size(ImR);
                        ImR2_S8 = ImR(cropSize{8}(1):(szIm(1)-cropSize{8}(2)),...
                            cropSize{8}(3):(szIm(2)-cropSize{8}(4)),:);
                        ImR2_S8 = imresize(ImR2_S8,[224 224],'lanczos3');
                    case 9
                        ImR = imread(fullfile(configObj2_16.filesR.path,configObj2_16.filesR.fR{iR}));
                        szIm = size(ImR);
                        ImR2_S9 = ImR(cropSize{9}(1):(szIm(1)-cropSize{9}(2)),...
                            cropSize{9}(3):(szIm(2)-cropSize{9}(4)),:);
                        ImR2_S9 = imresize(ImR2_S9,[224 224],'lanczos3');
                end        
            else  %rural dataset
                switch k
                    case 1 %Scale 1
                        ImR = imread(fullfile(configObj1_19.filesR.path,configObj1_19.filesR.fR{iR}));
                        szIm = size(ImR);
                        ImR2_S1 = ImR(cropSize{1}(1):(szIm(1)-cropSize{1}(2)),...
                            cropSize{1}(3):(szIm(2)-cropSize{1}(4)),:);
                        ImR2_S1 = imresize(ImR2_S1,[224 224],'lanczos3');
                    case 2
                        ImR = imread(fullfile(configObj1_19.filesR.path,configObj1_19.filesR.fR{iR}));
                        szIm = size(ImR);
                        ImR2_S2 = ImR(cropSize{2}(1):(szIm(1)-cropSize{2}(2)),...
                            cropSize{2}(3):(szIm(2)-cropSize{2}(4)),:);
                        ImR2_S2 = imresize(ImR2_S2,[224 224],'lanczos3');
                    case 3
                        ImR = imread(fullfile(configObj1_19.filesR.path,configObj1_19.filesR.fR{iR}));
                        szIm = size(ImR);
                        ImR2_S3 = ImR(cropSize{3}(1):(szIm(1)-cropSize{3}(2)),...
                            cropSize{3}(3):(szIm(2)-cropSize{3}(4)),:);
                        ImR2_S3 = imresize(ImR2_S3,[224 224],'lanczos3');
                    case 4
                        ImR = imread(fullfile(configObj1_19.filesR.path,configObj1_19.filesR.fR{iR}));
                        szIm = size(ImR);
                        ImR2_S4 = ImR(cropSize{4}(1):(szIm(1)-cropSize{4}(2)),...
                            cropSize{4}(3):(szIm(2)-cropSize{4}(4)),:);
                        ImR2_S4 = imresize(ImR2_S4,[224 224],'lanczos3');
                    case 5
                        ImR = imread(fullfile(configObj1_19.filesR.path,configObj1_19.filesR.fR{iR}));
                        szIm = size(ImR);
                        ImR2_S5 = ImR(cropSize{5}(1):(szIm(1)-cropSize{5}(2)),...
                            cropSize{5}(3):(szIm(2)-cropSize{5}(4)),:);
                        ImR2_S5 = imresize(ImR2_S5,[224 224],'lanczos3');
                    case 6
                        ImR = imread(fullfile(configObj1_18.filesR.path,configObj1_18.filesR.fR{iR}));
                        szIm = size(ImR);
                        ImR2_S6 = ImR(cropSize{6}(1):(szIm(1)-cropSize{6}(2)),...
                            cropSize{6}(3):(szIm(2)-cropSize{6}(4)),:);
                        ImR2_S6 = imresize(ImR2_S6,[224 224],'lanczos3');
                    case 7
                        ImR = imread(fullfile(configObj1_18.filesR.path,configObj1_18.filesR.fR{iR}));
                        szIm = size(ImR);
                        ImR2_S7 = ImR(cropSize{7}(1):(szIm(1)-cropSize{7}(2)),...
                            cropSize{7}(3):(szIm(2)-cropSize{7}(4)),:);
                        ImR2_S7 = imresize(ImR2_S7,[224 224],'lanczos3');
                    case 8
                        ImR = imread(fullfile(configObj1_17.filesR.path,configObj1_17.filesR.fR{iR}));
                        szIm = size(ImR);
                        ImR2_S8 = ImR(cropSize{10}(1):(szIm(1)-cropSize{10}(2)),...
                            cropSize{10}(3):(szIm(2)-cropSize{10}(4)),:);
                        ImR2_S8 = imresize(ImR2_S8,[224 224],'lanczos3');
                    case 9
                        ImR = imread(fullfile(configObj1_17.filesR.path,configObj1_17.filesR.fR{iR}));
                        szIm = size(ImR);
                        ImR2_S9 = ImR(cropSize{11}(1):(szIm(1)-cropSize{11}(2)),...
                            cropSize{11}(3):(szIm(2)-cropSize{11}(4)),:);
                        ImR2_S9 = imresize(ImR2_S9,[224 224],'lanczos3');
                end
            end    
        end      
        subplot(3,1,1,'replace');
        %image(ImQ);
        montage({ImQ_S1,ImQ_S2,ImQ_S3,ImQ_S4,ImQ_S5,ImQ_S6,ImQ_S7,...
            ImQ_S8,ImQ_S9},'Size',[1 9],'BorderSize',[5 5]);
        title('Current View');

        subplot(3,1,2,'replace');
        image(ImR1);
        axis image;
        if dMS_Store(i) > GT_tol  %red_box = 1;
            hold on
            sz = size(ImR1);
            rectangle('Position',[10,10,sz(2)-10,sz(1)-10],...
                'EdgeColor', 'r',...
                'LineWidth', 5,...
                'LineStyle','-')
            hold off
        else
            hold on
            sz = size(ImR1);
            rectangle('Position',[10,10,sz(2)-10,sz(1)-10],...
                'EdgeColor', 'g',...
                'LineWidth', 5,...
                'LineStyle','-')
            hold off
        end
        title('Multi-Scale Matched Scene'); 
        
        subplot(3,1,3,'replace');
        montage({ImR2_S1,ImR2_S2,ImR2_S3,ImR2_S4,ImR2_S5,ImR2_S6,ImR2_S7,...
            ImR2_S8,ImR2_S9},'Size',[1 9],'BorderSize',[5 5]);
%         if dSS_Store{numScales}(i) > GT_tol
%             hold on
%             sz = size(ImR2);
%             rectangle('Position',[10,10,sz(2)-10,sz(1)-10],...
%                 'EdgeColor', 'r',...
%                 'LineWidth', 5,...
%                 'LineStyle','-')
%             hold off
%         end    
        title('All Single-Scale Matched Scenes');
        
%             d = GPS2Meters(QueryLatArray(i),QueryLongArray(i),...
%         RefLatArray(final_match(i)),RefLongArray(final_match(i)));

        % need to plot the matched location in a heatmap... over multiple
        % scales...
        
        figure
        plot(RuralLongs,RuralLats);
        
        drawnow;
        pause(visSpeed);
    end
end    
%%
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

%re-order precision and recall such that AUC calculates correctly... TODO
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

function [recall] = evalMatches(GPSMatrix,currImageId,match_candidates)
recall = 0;
%are any of the match_candidates within ground truth?
for i = 1:length(match_candidates)
    if (GPSMatrix(match_candidates(i),currImageId)==1)
        recall = 1;
        break
    else
        
    end
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
    xlabel('GPS Distance from Exact Match');
    ylabel('Recall Rate');
    xlim([1 200]);
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