clear variables
warning off
HPC = 1;  %setting to change if run locally (0), or on HPC server (1).
Win = 0;  %OS setting
%Dataset = 'Nordland';
%Dataset = 'Nearmaps';
Dataset = 'Nearmaps_Rural';
%Dataset = 'Nearmaps_Vlong';
%Dataset = 'S11Test';

saveFolder = '/home/n7542704/MATLAB_2019_Working/Multi_Scale_Fusion_Release/Extracted_Features_sameoffset_220220/';

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
        
    elseif strcmp(Dataset,'Nearmaps')
        Qfol1 = '/home/n7542704/Datasets/Nearmaps_Datasets/Brisbane_MultiLoop_19_2019/raw_images';
        Rfol1 = '/home/n7542704/Datasets/Nearmaps_Datasets/Brisbane_MultiLoop_19_2013/raw_images';
        
        Qfol2 = '/home/n7542704/Datasets/Nearmaps_Datasets/Brisbane_MultiLoop_18_2019/raw_images';
        Rfol2 = '/home/n7542704/Datasets/Nearmaps_Datasets/Brisbane_MultiLoop_18_2013/raw_images';
        
        Qfol3 = '/home/n7542704/Datasets/Nearmaps_Datasets/Brisbane_MultiLoop_highres_16_2019/raw_images';
        Rfol3 = '/home/n7542704/Datasets/Nearmaps_Datasets/Brisbane_MultiLoop_highres_16_2013/raw_images';
        
        GT_file = load('/home/n7542704/MATLAB_2019_Working/Multi_Scale_Fusion_Ver1/IJNN_Zetao_Stlucia_Code/Nearmaps/features/gps_loop/Nearmaps_GPSMatrix_50m.mat');
    elseif strcmp(Dataset,'Nearmaps_Rural')
        Qfol1 = '/home/n7542704/Datasets/Nearmaps_Datasets/Brisbane_Rural_19_2019/raw_images';
        Rfol1 = '/home/n7542704/Datasets/Nearmaps_Datasets/Brisbane_Rural_19_2013/raw_images';
        
        Qfol2 = '/home/n7542704/Datasets/Nearmaps_Datasets/Brisbane_Rural_18_2019/raw_images';
        Rfol2 = '/home/n7542704/Datasets/Nearmaps_Datasets/Brisbane_Rural_18_2013/raw_images';
        
        Qfol3 = '/home/n7542704/Datasets/Nearmaps_Datasets/Brisbane_Rural_17_2019/raw_images';
        Rfol3 = '/home/n7542704/Datasets/Nearmaps_Datasets/Brisbane_Rural_17_2013/raw_images';
        
        GT_file = load('/home/n7542704/MATLAB_2019_Working/Multi_Scale_Fusion_Ver1/IJNN_Zetao_Stlucia_Code/Nearmaps/features/gps_rural/Nearmaps_GPSMatrix_Rural_50m.mat');
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

    %use crop shifts of 20, then 10, then 5
    
    %the crop sizes below are for a scale factor of root(2)
    cropSizeD{1} = [428 428 438 428]; % final size: 224 x 224 pixels
    cropSizeD{2} = [382 382 392 382]; % final size: 316 x 316 pixels
    cropSizeD{3} = [316 316 336 326]; % final size: 448 x 448 pixels
    cropSizeD{4} = [224 224 234 224]; % final size: 632 x 632 pixels
    cropSizeD{5} = [92 92 102 92];     % final size: 896 x 896 pixels
    
    cropSizeQ{1} = [428 428 428 438]; % final size: 224 x 224 pixels
    cropSizeQ{2} = [382 382 382 392]; % final size: 316 x 316 pixels
    cropSizeQ{3} = [316 316 326 336]; % final size: 448 x 448 pixels
    cropSizeQ{4} = [224 224 224 234]; % final size: 632 x 632 pixels
    cropSizeQ{5} = [92 92 92 102];     % final size: 896 x 896 pixels
    
    %larger zoomed image (1080 x 1080 pixels at zoom 18)
    cropSizeD{6} = [224 224 234 224]; % final size: 632 x 632 pixels (eq. to 1264 by 1264)
    cropSizeQ{6} = [224 224 224 234]; % final size: 632 x 632 pixels (eq. to 1264 by 1264)    
    cropSizeD{7} = [92 92 102 92];     % final size: 896 x 896 pixels (eq. to 1792 by 1792)
    cropSizeQ{7} = [92 92 92 102];     % final size: 896 x 896 pixels (eq. to 1792 by 1792)
    
    %even larger zoomed image (2160 x 2160 pixels at zoom 16)
    if strcmp(Dataset,'Nearmaps')
        cropSizeD{8} = [764 764 774 764];    % final size: 632 x 632 pixels (eq. to 2528 by 2528)
        cropSizeQ{8} = [764 764 764 774];
        cropSizeD{9} = [632 632 642 632];    % final size: 896 x 896 pixels (eq. to 3584 by 3584)
        cropSizeQ{9} = [632 632 632 642];
    elseif strcmp(Dataset,'Nearmaps_Rural')
        cropSizeD{8} = [224 224 234 224]; 
        cropSizeQ{8} = [224 224 224 234];
        cropSizeD{9} = [92 92 102 92];
        cropSizeQ{9} = [92 92 92 102];
    end
for scaleCounter = 1:9
    if scaleCounter < 6
        oGist1 = saveDbaseTemplates(oGist1, cropSizeD{scaleCounter}, [saveFolder,Dataset,'_Sqrt2_Scale_',num2str(scaleCounter),'_2013_Gist.mat']);
        oGist1 = saveQueryTemplates(oGist1, cropSizeQ{scaleCounter}, [saveFolder,Dataset,'_Sqrt2_Scale_',num2str(scaleCounter),'_2019_Gist.mat']);
    elseif scaleCounter < 8
        oGist2 = saveDbaseTemplates(oGist2, cropSizeD{scaleCounter}, [saveFolder,Dataset,'_Sqrt2_Scale_',num2str(scaleCounter),'_2013_Gist.mat']);
        oGist2 = saveQueryTemplates(oGist2, cropSizeQ{scaleCounter}, [saveFolder,Dataset,'_Sqrt2_Scale_',num2str(scaleCounter),'_2019_Gist.mat']);
    else
        oGist3 = saveDbaseTemplates(oGist3, cropSizeD{scaleCounter}, [saveFolder,Dataset,'_Sqrt2_Scale_',num2str(scaleCounter),'_2013_Gist.mat']);
        oGist3 = saveQueryTemplates(oGist3, cropSizeQ{scaleCounter}, [saveFolder,Dataset,'_Sqrt2_Scale_',num2str(scaleCounter),'_2019_Gist.mat']);
    end
end
time = toc;
save('featExtractComputeTime_Gist_allFeats_Rural_HPC.mat','time');

function this = copyConstructor(this,Rfol,Qfol,GT_file)
%     this = SetupPreDefines(this,'frameSkip',5,'sadResize',[64 32],'initCrop',...
%         [1 60 1 1],'hogResize',[300 300],'hogCellSize',[30 30]);
    this = SetupPreDefines(this,'frameSkip',1,'sadResize',[64 32],'initCrop',...
        [1 1 1 1],'hogResize',[300 300],'hogCellSize',[30 30]);
    this = loadImages(this,Rfol,Qfol); %final optional input: limit number of frames
    this = loadGTFile(this,GT_file);
end
