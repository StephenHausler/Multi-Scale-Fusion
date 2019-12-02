clear variables
warning off
HPC = 0;  %setting to change if run locally (0), or on HPC server (1).
Win = 1;  %OS setting
%Dataset = 'Nordland';
Dataset = 'Nearmaps_Rural';
%Dataset = 'Nearmaps_Vlong';
%Dataset = 'S11Test';

%main file - Multi_SLAM_Fusion

if HPC == 1
    if strcmp(Dataset,'Nordland')
        Qfol = '/home/n7542704/D_Drive_Backup/Windows/Nordland/nordland_summer_images';
        Rfol = '/home/n7542704/D_Drive_Backup/Windows/Nordland/nordland_winter_images';
        GT_file = load('/home/n7542704/D_Drive_Backup/Windows/Nordland/Nordland_GPSMatrix.mat');
    elseif strcmp(Dataset,'St Lucia')
        Qfol = '/home/n7542704/Datasets/St_Lucia_Dataset/1545_15FPS/Frames';
        Rfol = '/home/n7542704/Datasets/St_Lucia_Dataset/0845_15FPS/Frames';
        GT_file = load('/home/n7542704/Datasets/St_Lucia_Dataset/StLucia_GPSMatrix_20m.mat');
    elseif strcmp(Dataset,'Oxford')
        
    else
        disp('Error: unknown dataset');
        return
    end     
    datafile = '/home/n7542704/MATLAB_2019_Working/Neural_Networks/HybridNet/HybridNet.mat';
    protofile = '/home/n7542704/MATLAB_2019_Working/Neural_Networks/HybridNet/HybridNet.mat';
else    
    if Win == 1
        if strcmp(Dataset,'Nordland')
            Qfol = 'D:\Windows\Nordland\nordland_summer_images';
            Rfol = 'D:\Windows\Nordland\nordland_winter_images';
            GT_file = load('D:\Windows\Nordland\Nordland_GPSMatrix.mat');
        elseif strcmp(Dataset,'St Lucia')
            Qfol = 'D:\Windows\St_Lucia_Dataset\1545_15FPS\Frames';
            Rfol = 'D:\Windows\St_Lucia_Dataset\0845_15FPS\Frames';
            GT_file = load('D:\Windows\St_Lucia_Dataset\StLucia_GPSMatrix_20m.mat');
        elseif strcmp(Dataset,'St Lucia 2')
            Qfol = 'F:\MATLAB_2019_Working\Multi_Scale_Fusion_Ver1\IJNN_Zetao_Stlucia_Code\StLucia\Dataset\1410';
            Rfol = 'F:\MATLAB_2019_Working\Multi_Scale_Fusion_Ver1\IJNN_Zetao_Stlucia_Code\StLucia\Dataset\0845';
            GT_file = load('D:\Windows\St_Lucia_Dataset\StLucia_GPSMatrix_20m.mat');
        elseif strcmp(Dataset,'Nearmaps')
            Qfol1 = 'D:\Ubuntu\Nearmaps_Datasets\Brisbane_MultiLoop_19_2019\raw_images';
            Rfol1 = 'D:\Ubuntu\Nearmaps_Datasets\Brisbane_MultiLoop_19_2013\raw_images';
            
            Qfol2 = 'D:\Ubuntu\Nearmaps_Datasets\Brisbane_MultiLoop_18_2019\raw_images';
            Rfol2 = 'D:\Ubuntu\Nearmaps_Datasets\Brisbane_MultiLoop_18_2013\raw_images';
            
            Qfol3 = 'D:\Ubuntu\Nearmaps_Datasets\Brisbane_MultiLoop_highres_16_2019\raw_images';
            Rfol3 = 'D:\Ubuntu\Nearmaps_Datasets\Brisbane_MultiLoop_highres_16_2013\raw_images';
            
            GT_file = load('F:\MATLAB_2019_Working\Multi_Scale_Fusion_Ver1\IJNN_Zetao_Stlucia_Code\Nearmaps\features\gps_loop\Nearmaps_GPSMatrix_50m.mat');
        elseif strcmp(Dataset,'Nearmaps_Rural')
            Qfol1 = 'D:\Ubuntu\Nearmaps_Datasets\Brisbane_Rural_19_2019\raw_images';
            Rfol1 = 'D:\Ubuntu\Nearmaps_Datasets\Brisbane_Rural_19_2013\raw_images';
            
            Qfol2 = 'D:\Ubuntu\Nearmaps_Datasets\Brisbane_Rural_18_2019\raw_images';
            Rfol2 = 'D:\Ubuntu\Nearmaps_Datasets\Brisbane_Rural_18_2013\raw_images';
            
            Qfol3 = 'D:\Ubuntu\Nearmaps_Datasets\Brisbane_Rural_17_2019\raw_images';
            Rfol3 = 'D:\Ubuntu\Nearmaps_Datasets\Brisbane_Rural_17_2013\raw_images';
            
            GT_file = load('F:\MATLAB_2019_Working\Multi_Scale_Fusion_Ver1\IJNN_Zetao_Stlucia_Code\Nearmaps\features\gps_rural\Nearmaps_GPSMatrix_Rural_50m.mat');
        elseif strcmp(Dataset,'S11Test')
            Qfol = 'D:\Insta360\S11Test_Afternoon';
            Rfol = 'D:\Insta360\S11Test_Morning';
        elseif strcmp(Dataset,'Oxford')
            
        else
            disp('Error: unknown dataset');
            return
        end 
        datafile = 'D:\MATLAB\MPF_RevisePaper\HybridNet\HybridNet.caffemodel';
        protofile = 'D:\MATLAB\MPF_RevisePaper\HybridNet\deploy.prototxt';
    else    
        if strcmp(Dataset,'Nordland')
            Qfol = '/media/stephen/Data/Windows/Nordland/nordland_summer_images';
            Rfol = '/media/stephen/Data/Windows/Nordland/nordland_winter_images';
            GT_file = load('/media/stephen/Data/Windows/Nordland/Nordland_GPSMatrix.mat');
        elseif strcmp(Dataset,'St Lucia')
            Qfol = '/media/stephen/Data/Windows/St_Lucia_Dataset/1545_15FPS/Frames';
            Rfol = '/media/stephen/Data/Windows/St_Lucia_Dataset/0845_15FPS/Frames';
            GT_file = load('/media/stephen/Data/Windows/St_Lucia_Dataset/StLucia_GPSMatrix_20m.mat');
        elseif strcmp(Dataset,'Oxford')
             
        else
            disp('Error: unknown dataset');
            return
        end    
        datafile = '/media/stephen/Data/MATLAB/MPF_RevisePaper/HybridNet/HybridNet.caffemodel';
        protofile = '/media/stephen/Data/MATLAB/MPF_RevisePaper/HybridNet/deploy.prototxt';
    end
end 

CAFFE_NETWORK = 1;
MATCONV_NETWORK = 2;

methods = {"Hnet_Heat","SAD","HOG","ORB","RANSAC","SURF","NetVLAD","Hnet_Whole",...
    "LoST","BoW","KAZE","OLO"};
    % Hnet_Heat   -->   1
    % SAD         -->   2
    % HOG         -->   3
    % ORB         -->   4
    % RANSAC      -->   5
    % SURF        -->   6
    % NetVLAD     -->   7
    % Hnet_Whole  -->   8
    % LoST        -->   9
    % BoW         -->   10
    % KAZE        -->   11
    % OLO         -->   12

%method structure (graph tree)
if HPC == 0
    disp('Method structure:');
    method_order = [methods{1}, methods{2}, methods{10}; methods{3},... 
        methods{7}, methods{4}; methods{12}, methods{11}, methods{8}]
else
    method_order = [methods{1}, methods{2}, methods{10}; methods{3},...
        methods{7}, methods{4}; methods{12}, methods{11}, methods{8}];
end

pyrstruct = [100 10 1];  
numMethodsPerLayer = 3;  

% gpuInfo = gpuDevice();
% save('WhichGPU.mat','gpuInfo');

%% Initialize modules:
tic;
oGist1 = ModuleGistZoom;
oGist1 = copyConstructor(oGist1,Rfol1,Qfol1,GT_file);
oGist1 = init(oGist1);

oGist2 = ModuleGistZoom;
oGist2 = copyConstructor(oGist2,Rfol2,Qfol2,GT_file);
oGist2 = init(oGist2);

oGist3 = ModuleGistZoom;
oGist3 = copyConstructor(oGist3,Rfol3,Qfol3,GT_file);
oGist3 = init(oGist3);

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
if strcmp(Dataset,'Nearmaps')
    cropSize{8} = [764 764 764 764];    % final size: 632 x 632 pixels (eq. to 2528 by 2528)
    cropSize{9} = [632 632 632 632];    % final size: 896 x 896 pixels (eq. to 3584 by 3584)
elseif strcmp(Dataset,'Nearmaps_Rural')
    cropSize{8} = [224 224 224 224];
    cropSize{9} = [92 92 92 92];
end
for scaleCounter = 1:9
    if scaleCounter < 6
%        oGist1 = saveDbaseTemplates(oGist1, cropSize{scaleCounter}, [Dataset,'_Sqrt2_Scale_',num2str(scaleCounter),'_2013_Gist.mat']);
        oGist1 = saveQueryTemplates(oGist1, cropSize{scaleCounter}, 'computeTimer.mat');
    elseif scaleCounter < 8
%        oGist2 = saveDbaseTemplates(oGist2, cropSize{scaleCounter}, [Dataset,'_Sqrt2_Scale_',num2str(scaleCounter),'_2013_Gist.mat']);
        oGist2 = saveQueryTemplates(oGist2, cropSize{scaleCounter}, 'computeTimer.mat');
    else
%        oGist3 = saveDbaseTemplates(oGist3, cropSize{scaleCounter}, [Dataset,'_Sqrt2_Scale_',num2str(scaleCounter),'_2013_Gist.mat']);
        oGist3 = saveQueryTemplates(oGist3, cropSize{scaleCounter}, 'computeTimer.mat');
    end
end
time = toc;
timePerFrame = time/500;
save('featExtractComputeTime_Gist.mat','time','timePerFrame');

function this = copyConstructor(this,Rfol,Qfol,GT_file)
%     this = SetupPreDefines(this,'frameSkip',5,'sadResize',[64 32],'initCrop',...
%         [1 60 1 1],'hogResize',[300 300],'hogCellSize',[30 30]);
    this = SetupPreDefines(this,'frameSkip',1,'sadResize',[64 32],'initCrop',...
        [1 1 1 1],'hogResize',[300 300],'hogCellSize',[30 30]);
    this = loadImages(this,Rfol,Qfol,500); %final optional input: limit number of frames
    this = loadGTFile(this,GT_file);
end
