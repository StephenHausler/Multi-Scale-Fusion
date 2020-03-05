clear
warning off

%featureType = 'NetVLAD';
%featureType = 'Gist';
featureType = 'SAD';

Rfol1 = 'D:\Windows\Nordland\nordland_summer_images';
Rfol2 = 'D:\Windows\Nordland\nordland_summer_cont';

Qfol1 = 'D:\Windows\Nordland\nordland_winter_images';
Qfol2 = 'D:\Windows\Nordland\nordland_winter_cont';

GT_file = load('D:\Windows\Nordland\Nordland_GPSMatrix.mat');

if strcmp(featureType,'NetVLAD')
    saveFol = 'D:\Windows\Nordland\nordland_all_netvlad_features\';
elseif strcmp(featureType,'Gist')
    saveFol = 'D:\Windows\Nordland\nordland_all_gist_features\';
else
    saveFol = 'D:\Windows\Nordland\nordland_all_sad_features\';
end

mkdir(saveFol);

if strcmp(featureType,'NetVLAD')
    tic;
    
    oNetVLAD1 = ModuleNetVLAD2;
    oNetVLAD1 = init(oNetVLAD1, 'Nord', 0, 1);
    oNetVLAD1 = copyConstructor(oNetVLAD1,Rfol1,Qfol1,GT_file);
    
    oNetVLAD2 = ModuleNetVLAD2;
    oNetVLAD2 = init(oNetVLAD2, 'Nord', 0, 1);
    oNetVLAD2 = copyConstructor(oNetVLAD2,Rfol2,Qfol2,GT_file);
    
    oNetVLAD1 = saveQueryTemplatesMultiZoom(oNetVLAD1,[1 1 1 1],[saveFol 'Sect1_Query.mat']);
    oNetVLAD2 = saveQueryTemplatesMultiZoom(oNetVLAD2,[1 1 1 1],[saveFol 'Sect2_Query.mat']);
    
    oNetVLAD1 = saveDbaseTemplatesMultiZoom(oNetVLAD1,[1 1 1 1],[saveFol 'Sect1_Dbase.mat']);
    oNetVLAD2 = saveDbaseTemplatesMultiZoom(oNetVLAD2,[1 1 1 1],[saveFol 'Sect2_Dbase.mat']);
    
    time = toc;
    save('timeTaken_to_extract_features_with_NetVLAD.mat','time');
elseif strcmp(featureType,'Gist')
    tic;
    oGist1 = ModuleGistZoom;
    oGist1 = init(oGist1);
    oGist1 = copyConstructor(oGist1,Rfol1,Qfol1,GT_file);
    
    oGist2 = ModuleGistZoom;
    oGist2 = init(oGist2);
    oGist2 = copyConstructor(oGist2,Rfol2,Qfol2,GT_file);
    
    oGist1 = saveQueryTemplates(oGist1,[1 1 1 1],[saveFol 'Sect1_Query.mat']);
    oGist2 = saveQueryTemplates(oGist2,[1 1 1 1],[saveFol 'Sect2_Query.mat']);
    
    oGist1 = saveDbaseTemplates(oGist1,[1 1 1 1],[saveFol 'Sect1_Dbase.mat']);
    oGist2 = saveDbaseTemplates(oGist2,[1 1 1 1],[saveFol 'Sect2_Dbase.mat']);    
    
    time = toc;
    save('timeTaken_to_extract_features_with_Gist.mat','time');
else  %SAD
    tic;
    oSAD1 = ModuleSADZoom;
    oSAD1 = copyConstructor(oSAD1,Rfol1,Qfol1,GT_file);
    
    oSAD2 = ModuleSADZoom;
    oSAD2 = copyConstructor(oSAD2,Rfol2,Qfol2,GT_file);
    
    oSAD1 = saveQueryTemplates(oSAD1,[1 1 1 1],[saveFol 'Sect1_Query.mat']);
    oSAD2 = saveQueryTemplates(oSAD2,[1 1 1 1],[saveFol 'Sect2_Query.mat']);
    
    oSAD1 = saveDbaseTemplates(oSAD1,[1 1 1 1],[saveFol 'Sect1_Dbase.mat']);
    oSAD2 = saveDbaseTemplates(oSAD2,[1 1 1 1],[saveFol 'Sect2_Dbase.mat']);
    
    time = toc;
    save('timeTaken_to_extract_features_with_SAD.mat','time');
end

function this = copyConstructor(this,Rfol,Qfol,GT_file)
%     this = SetupPreDefines(this,'frameSkip',5,'sadResize',[64 32],'initCrop',...
%         [1 60 1 1],'hogResize',[300 300],'hogCellSize',[30 30]);
    this = SetupPreDefines(this,'frameSkip',1,'sadResize',[64 32],'initCrop',...
        [1 1 1 1],'hogResize',[300 300],'hogCellSize',[30 30]);
    this = loadImages(this,Rfol,Qfol); %final optional input: limit number of frames
    this = loadGTFile(this,GT_file);
end
