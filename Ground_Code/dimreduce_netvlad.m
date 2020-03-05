clear

HPC = 0;

featureType = 'NetVLAD';
%featureType = 'Gist';
%featureType = 'SAD';

if strcmp(featureType,'NetVLAD')
    if HPC == 0
        loadFol = 'F:\D_Drive_Backup\Windows\Nordland\nordland_all_netvlad_features\';
        saveFol = 'F:\D_Drive_Backup\Windows\Nordland\nordland_all_netvlad_features_multiscalefusion\';
        d = dir('F:\D_Drive_Backup\Windows\Nordland\nordland_all_netvlad_features\Scale*_Feats.mat');
        names = {d.name};
        featureLength = 4096;
    else
        loadFol = '/home/n7542704/D_Drive_Backup/Windows/Nordland/nordland_all_netvlad_features/';
        saveFol = '/home/n7542704/D_Drive_Backup/Windows/Nordland/nordland_all_netvlad_features_multiscalefusion/';
        d = dir('/home/n7542704/D_Drive_Backup/Windows/Nordland/nordland_all_netvlad_features/Scale*_Feats.mat');
        names = {d.name};
        featureLength = 4096;
    end
elseif strcmp(featureType,'Gist')
    if HPC == 0
        loadFol = 'F:\D_Drive_Backup\Windows\Nordland\nordland_all_gist_features\';
        saveFol = 'F:\D_Drive_Backup\Windows\Nordland\nordland_all_gist_features_multiscalefusion\';
        d = dir('F:\D_Drive_Backup\Windows\Nordland\nordland_all_gist_features\Scale*_Feats.mat');
        names = {d.name};
        featureLength = 512;
    else
        loadFol = 'D:\Windows\Nordland\nordland_all_gist_features\';
        saveFol = 'D:\Windows\Nordland\nordland_all_gist_features_multiscalefusion\';
        d = dir('D:\Windows\Nordland\nordland_all_gist_features\Scale*_Feats.mat');
        names = {d.name};
        featureLength = 512;
    end
else
    if HPC == 0
        loadFol = 'F:\D_Drive_Backup\Windows\Nordland\nordland_all_sad_features\';
        saveFol = 'F:\D_Drive_Backup\Windows\Nordland\nordland_all_sad_features_multiscalefusion\';
        d = dir('F:\D_Drive_Backup\Windows\Nordland\nordland_all_sad_features\Scale*_Feats.mat');
        names = {d.name};
        featureLength = 2048;
    else
        loadFol = 'D:\Windows\Nordland\nordland_all_sad_features\';
        saveFol = 'D:\Windows\Nordland\nordland_all_sad_features_multiscalefusion\';
        d = dir('D:\Windows\Nordland\nordland_all_sad_features\Scale*_Feats.mat');
        names = {d.name};
        featureLength = 2048;
    end
end

%mkdir(saveFol);

for i = 1:2:length(names)

    X = load([loadFol names{i}]);
    fname = fieldnames(X);
    train_data = double(X.(fname{1})); %reference
    scale = size(train_data,2)/featureLength;
    if scale>1
        train_data = train_data(scale:end,:);
    end
    clear X;
    X = load([loadFol names{(i+1)}]);
    fname = fieldnames(X);
    test_data = double(X.(fname{1})); %query
    if scale>1
        test_data = test_data(scale:end,:);
    end
    test_len = size(test_data,1);
    test_dimensionality = size(test_data,2);
    
    spacing = test_dimensionality/400;
    
    red_train = train_data(:,1:spacing:end);
    red_test = test_data(:,1:spacing:end);

    size(red_train)
    
    feature_matrix1 = red_test;
    
%    feature_matrix1 = proj_test(:,(1:featureLength));
    if scale>1
        pad_matrix = zeros((scale-1),size(feature_matrix1,2));
        feature_matrix = [pad_matrix; feature_matrix1];
    else
        feature_matrix = feature_matrix1;
    end
    
    save([saveFol 'Scale_DimReduce_' num2str(scale) '_Query_Feats'],'feature_matrix');
    
    clear feature_matrix; clear feature_matrix1;
%    feature_matrix1 = proj_train(:,(1:featureLength));
    feature_matrix1 = red_train;

    if scale>1
        pad_matrix = zeros((scale-1),size(feature_matrix1,2));
        feature_matrix = [pad_matrix; feature_matrix1];
    else
        feature_matrix = feature_matrix1;
    end
    save([saveFol 'Scale_DimReduce_' num2str(scale) '_Dbase_Feats'],'feature_matrix');
    
    clear X; clear pad_matrix; clear feature_matrix;
    clear feature_matrix1; 
end

