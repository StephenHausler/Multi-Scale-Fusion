clc
clear
%close all

feature_type = 'NetVLAD';
%feature_type = 'Gist';
%feature_type = 'SAD';

scaleArray{1} = [1,9];
scaleArray{2} = [1,5,9];
scaleArray{3} = [1,4,6,9];
scaleArray{4} = [1,3,5,7,9];
scaleArray{5} = [1,2,4,6,8,9];
scaleArray{6} = [1,3,4,5,6,7,9];
scaleArray{7} = [1,2,3,4,6,7,8,9];
scaleArray{8} = [1,2,3,4,5,6,7,8,9];

mainFolder = 'Random_Navigation_Results';  

numTrials = 20; %default: 20
numScales = 8;  %default: 8 (actually 9 scales)
%using the supplied features on Github, can only run scalesArray{1}.

for runNum = 1:numTrials  
    randids = [];
    randvals = rand([1 3041]);
    for i = 1:500
        [~,randid] = max(randvals);
        randvals(randid) = 0;
        randids = [randids randid];
    end
    for j = 8:numScales %1:numScales
        tic;
        [AUC,AUC_Baseline] = multiScaleCombine(mainFolder,scaleArray{j},runNum,randids,feature_type);
        AUC_all(runNum,j) = AUC;
        A_B = cell2mat(AUC_Baseline);
        AUC_Baseline_all{runNum,j} = A_B;
        timer(j) = toc;
    end
    allTimes{runNum} = timer;
end

%save([mainFolder,'/allAUCs_SAD.mat'],'AUC_all','AUC_Baseline_all','allTimes');
%save([mainFolder,'/allAUCs_Gist.mat'],'AUC_all','AUC_Baseline_all','allTimes');
save([mainFolder,'/allAUCs_NetVLAD.mat'],'AUC_all','AUC_Baseline_all','allTimes');







