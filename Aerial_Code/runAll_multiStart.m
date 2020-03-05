clc
clear
%close all

%feature_type = 'NetVLAD';
%feature_type = 'Gist';
feature_type = 'SAD';

scaleArray = [1 2 3 4 5 6 7 8];

mainFolder = 'Random_Navigation_Results_260220_multistart';  %where to save the results
%mainFolder = 'Random_Navigation_Results_220220';  %where to save the results

numTrials = 20; %default: 20
numStarts = 7;  %default: 8 (actually 9 scales)
%using the supplied features on Github, can only run scalesArray{1}.

for runNum = 1:numTrials  
    randids = [];
    randvals = rand([1 3041]);
    for i = 1:500
        [~,randid] = max(randvals);
        randvals(randid) = 0;
        randids = [randids randid];
    end
    for j = 1:numStarts 
        tic;
        [AUC,AUC_Baseline] = multiStartCombine(mainFolder,scaleArray,...
            j,runNum,randids,feature_type);
        AUC_all(runNum,j) = AUC;
        A_B = cell2mat(AUC_Baseline);
        AUC_Baseline_all{runNum,j} = A_B;
        timer(j) = toc;
    end
    allTimes{runNum} = timer;
end

save([mainFolder,'/allAUCs_SAD.mat'],'AUC_all','AUC_Baseline_all','allTimes');
%save([mainFolder,'/allAUCs_Gist.mat'],'AUC_all','AUC_Baseline_all','allTimes');
%save([mainFolder,'/allAUCs_NetVLAD.mat'],'AUC_all','AUC_Baseline_all','allTimes');







