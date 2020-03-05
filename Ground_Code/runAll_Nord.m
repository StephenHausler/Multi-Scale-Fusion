opt_fastStart = 1;

if opt_fastStart == 1

    
else
    
clc
clear
%close all

%feature_type = 'NetVLAD';
feature_type = 'Gist';
%feature_type = 'SAD';

% scaleArray{1} = [1,23];
% %scaleArray{1} = [1,2];
% %scaleArray{1} = [16,23];
% 
% scaleArray{2} = [1,6,23];
% scaleArray{3} = [1,4,8,23];
% scaleArray{4} = [1,3,6,11,23];
% %scaleArray{4} = [6,8,11,16,23];
% 
% scaleArray{5} = [1,2,4,8,16,23];
% scaleArray{6} = [1,3,4,6,8,11,23];
% %scaleArray{6} = [3,4,6,8,11,16,23];
% 
% scaleArray{7} = [1,2,3,4,8,11,16,23];
% scaleArray{8} = [1,2,3,4,6,8,11,16,23];

% scaleArray{1} = [1,2,3,4,6,8,11,16];
% scaleArray{2} = [2,3,4,6,8,11,16,23];
% scaleArray{3} = [3,4,6,8,11,16,23,33];
% scaleArray{4} = [4,6,8,11,16,23,33,47];
% scaleArray{5} = [1,2,3,4,5,6,7,8];
% scaleArray{6} = [1,3,5,7,9,11,13,15];
% scaleArray{7} = [1,4,7,10,13,16,19,22];
% scaleArray{8} = [1,5,9,13,17,21,25,29];

scaleArray{1} = [1,23];
scaleArray{2} = [1,6,23];
scaleArray{3} = [1,4,8,23];
scaleArray{4} = [1,3,6,11,23];
scaleArray{5} = [1,2,4,8,16,23];
scaleArray{6} = [1,3,4,6,8,11,23];
scaleArray{7} = [1,2,3,4,8,11,16,23];
scaleArray{8} = [1,2,3,4,6,8,11,16,23];

mainFolder = 'Random_Navigation_Results_FrontFacing_Overlap_dimreduce_260220';  %where to save the results

numTrials = 20; %default: 20
numScales = 8;  %default: 8 (actually 9 scales)

%load('D:\Windows\Nordland\nordland_all_gist_features_multiscalefusion\precomputed_Gist');
%load('D:\Windows\Nordland\nordland_all_netvlad_features_multiscalefusion\precomputed_NetVLAD');
%load('D:\Windows\Nordland\nordland_all_sad_features_multiscalefusion\precomputed_sad');

%load('D:\Windows\Nordland\nordland_all_netvlad_features_dimred\precomputed_NetVLAD');
load('D:\Windows\Nordland\nordland_all_gist_features_dimred\precomputed_Gist');
%load('D:\Windows\Nordland\nordland_all_sad_features_dimred\precomputed_SAD');

%allDiffs_byScale = '';

end

%need to perform PCA on the feature vectors to turn them to 1x4096!

for runNum = 1:numTrials  
    randids = [];
    %randvals = rand([1 8280]); %23*360
    randvals = rand([1 (8300-23)]);
    for i = 1:500
        [~,randid] = max(randvals);
        randid = randid + 23;
        randvals(randid-23) = 0;
        randids = [randids randid];
    end
    for j = 5:numScales %1:numScales
        [AUC,AUC_Baseline] = forwardFacingCombine(mainFolder,...
            scaleArray{j},runNum,randids,feature_type,allDiffs_byScale);
        AUC_all(runNum,j) = AUC;
        A_B = cell2mat(AUC_Baseline);
        AUC_Baseline_all{runNum,j} = A_B;
    end
end

%save([mainFolder,'/allAUCs_SAD.mat'],'AUC_all','AUC_Baseline_all');
%save([mainFolder,'/allAUCs_NetVLAD.mat'],'AUC_all','AUC_Baseline_all');
save([mainFolder,'/allAUCs_Gist.mat'],'AUC_all','AUC_Baseline_all');








