%createNordFeats_multiScale

%convert a single-scale set of features into multiple scales (by
%concatenating image features with different concat lengths)

%use HPC!

clear

featureType = 'NetVLAD';
%featureType = 'Gist';
%featureType = 'SAD';

if strcmp(featureType,'NetVLAD')
    loadFol = 'D:\Windows\Nordland\nordland_all_netvlad_features\';
elseif strcmp(featureType,'Gist')
%     loadFol = 'D:\Windows\Nordland\nordland_all_gist_features\';
    loadFol = '/home/n7542704/D_Drive_Backup/Windows/Nordland/nordland_all_gist_features/';
else
    loadFol = 'D:\Windows\Nordland\nordland_all_sad_features\';
end

tic;

load([loadFol 'Sect1_Dbase']);
Sect1_DbaseFeats = feature_matrix;
load([loadFol 'Sect2_Dbase']);
Sect2_DbaseFeats = feature_matrix;
All_DbaseFeats = [Sect1_DbaseFeats; Sect2_DbaseFeats];

load([loadFol 'Sect1_Query']);
Sect1_QueryFeats = feature_matrix;
load([loadFol 'Sect2_Query']);
Sect2_QueryFeats = feature_matrix;
All_QueryFeats = [Sect1_QueryFeats; Sect2_QueryFeats];

longDbase = reshape(All_DbaseFeats',[1 (8301*size(All_DbaseFeats,2))]);
longQuery = reshape(All_QueryFeats',[1 (8301*size(All_DbaseFeats,2))]);

scaleArray = [1 2 3 4 6 8 11 16 23];

for k = 1:length(scaleArray) %need to rerun with *All* possible scales
    s = scaleArray(k);
    for i = s:8301
        start = 1 + ((i-s)*size(All_DbaseFeats,2));
        finish = i*size(All_DbaseFeats,2);
        scaledDbase(i,:) = longDbase(start:finish);
        scaledQuery(i,:) = longQuery(start:finish);
    end
    save([loadFol 'Scale' num2str(s) '_Dbase_Feats'],'scaledDbase');
    save([loadFol 'Scale' num2str(s) '_Query_Feats'],'scaledQuery');
    clear scaledDbase;
    clear scaledQuery;
end

time = toc;
save([loadFol 'TimeTaken_to_copy_feats_using_NetVLAD.mat'],'time');







