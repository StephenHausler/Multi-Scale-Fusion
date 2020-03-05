classdef ModuleNetVLAD2 < Config
    properties
        templates_D;
        dbFeatFn;
        qFeatFn;
    end  
    methods   %Need to decide if want to re-write serialAllFeats to fit with
        %my other code...
        function this = init(this, name, HPC, Win)
            if HPC == 1
                addpath(genpath('/home/n7542704/MATLAB_2019_Working/Multi_SLAM_Fusion_Ver3/NetVLAD'));
                addpath(genpath('/home/n7542704/MATLAB_2019_Working/Multi_SLAM_Fusion_Ver3/matconvnet-1.0-beta25'));
            else
                if Win == 1
                    addpath(genpath('F:\MATLAB_2019_Working\Multi_Scale_Fusion_Ver1\NetVLAD'));
                    addpath(genpath('F:\MATLAB_2019_Working\Multi_Scale_Fusion_Ver1\matconvnet-1.0-beta25'));
                else    
                    addpath(genpath('/media/HPC/MATLAB_2019_Working/Multi_SLAM_Fusion_Ver3/NetVLAD'));
                    addpath(genpath('/home/stephen/Documents/MATLAB/matconvnet-1.0-beta25'));
                end
            end    
            run vl_setupnn

            netID = 'vd16_pitts30k_conv5_3_vlad_preL2_intra_white';
            paths= localPaths(HPC);
            
            load( sprintf('%s%s.mat', paths.ourCNNs, netID), 'net' );
            net= relja_simplenn_tidy(net);
            this.net= netPrepareForTest(net);

            this.dbFeatFn= sprintf('%s%s_%s_db.bin', paths.outPrefix, netID, name);
            this.qFeatFn = sprintf('%s%s_%s_q.bin', paths.outPrefix, netID, name);
        end   
        function this = createDbaseTemplates(this)
            %Create database template array:
            this.templates_D = serialAllFeats(this.net, this.filesR.path, this.filesR.fR,...
                this.dbFeatFn, 'batchSize', 10, 'CropSize',this.initCrop, 'Resize',[224 224]);%[480 640]
        end    
        function this = saveDbaseTemplates(this, saveName)
            %Create database template array:
%             feature_matrix = serialAllFeats(this.net, this.filesR.path, this.filesR.fR,...
%                 this.dbFeatFn, 'batchSize', 10, 'CropSize',this.initCrop, 'Resize',[224 224]);%[480 640]
%             save(saveName, 'feature_matrix'); %used to be 'templates_D'.
            feature_matrix = serialAllFeats(this.net, this.filesR.path, this.filesR.fR,...
                this.dbFeatFn, 'batchSize', 10, 'CropSize',this.initCrop, 'Resize',[224 224]);%[480 640]
            feature_matrix = feature_matrix';
            save(saveName, 'feature_matrix'); %used to be 'templates_Q'.
        end 
        function this = saveDbaseTemplatesMultiZoom(this, cropSize, saveName)
            this.initCrop = cropSize;
            
            feature_matrix = serialAllFeats(this.net, this.filesR.path, this.filesR.fR,...
            this.dbFeatFn, 'batchSize', 10, 'CropSize',this.initCrop, 'Resize',[224 224]);%[480 640]
            feature_matrix = feature_matrix';
            save(saveName, 'feature_matrix'); %used to be 'templates_Q'.
        end
        function this = saveQueryTemplatesMultiZoom(this, cropSize, saveName)
            this.initCrop = cropSize;
            
            feature_matrix = serialAllFeats(this.net, this.filesQ.path, this.filesQ.fQ,...
                this.qFeatFn, 'batchSize', 10, 'CropSize',this.initCrop, 'Resize',[224 224]);%[480 640]
            feature_matrix = feature_matrix';
            save(saveName, 'feature_matrix');
        end    
        function this = saveQueryTemplates(this, saveName)
            feature_matrix = serialAllFeats(this.net, this.filesQ.path, this.filesQ.fQ,...
                this.qFeatFn, 'batchSize', 10, 'CropSize',this.initCrop, 'Resize',[224 224]);%[480 640]
            feature_matrix = feature_matrix';
            save(saveName, 'feature_matrix');
        end    
        function this = saveClusterTemplates(this, saveName, label, segm)
        %loop through each label id and montage together all image ids
        %within that label id. Then res reduce the collection and run
        %through NetVLAD.
            L = length(label);
            %split L in sets of 16 images
            S = 16;
            N = floor(L/S);
            id = 1;
            for i = 1:N
                ImFinal = [];
                for j = 1:sqrt(S)
                    ImSuper = [];
                    for k = 1:sqrt(S)
                        Im = imread(char(fullfile(this.filesQ.path,this.filesQ.fQ{id})));
                        id = id+1;
                        ImSuper = [ImSuper Im];
                    end    
                    ImRow{j} = ImSuper;
                end
                ImFinal = [ImRow{1}; ImRow{2}; ImRow{3}; ImRow{4}];
                ims = imresize(ImFinal,[224 224],'lanczos3');
%                 imshow(ims);
%                 pause(1);
                ims = single(ims);
                feature_matrix(i,:) = SingleFeat(this.net,ims);   
            end
            save(saveName, 'feature_matrix', 'label', 'segm');         
        end    
        function this = saveClusterTemplatesAll(this, saveName, label, segm)
        %sequence together 16 images and make into montage then res reduce.
        
            S = 16;
            for i = 1:this.qSize
%                 clear ImSuper1
%                 clear ImSuper2
%                 clear ImSuper3
%                 clear ImSuper4
%                 clear ImSuper
                Im{i} = imread(char(fullfile(this.filesQ.path,this.filesQ.fQ{i})));
                if i >= S 
                    ImSuper1 = [Im{i-S+1} Im{i-S+2} Im{i-S+3} Im{i-S+4}];
                    ImSuper2 = [Im{i-S+5} Im{i-S+6} Im{i-S+7} Im{i-S+8}];
                    ImSuper3 = [Im{i-S+9} Im{i-S+10} Im{i-S+11} Im{i-S+12}];
                    ImSuper4 = [Im{i-S+13} Im{i-S+14} Im{i-S+15} Im{i-S+16}];
                    
                    ImSuper = [ImSuper1; ImSuper2; ImSuper3; ImSuper4];
                    
                    Im{i-S+1} = [];  %dealloc - keep mem low
                    
                    ims = imresize(ImSuper,[224 224],'lanczos3');
                    ims = single(ims);
                    feature_matrix(i,:) = SingleFeat(this.net,ims);   
                end    
            end    
            save(saveName, 'feature_matrix', 'label', 'segm');       
        end   
        function this = OLDsaveClusterTemplates(this, saveName, label, segm)
        %loop through each label id and montage together all image ids
        %within that label id. Then res reduce the collection and run
        %through NetVLAD.
            y = unique(label);
            for i = 1:length(y)
                indexs = find(label==y(i));
                %now loop through and load images in indexes.
                ImSuper = [];
                for j = 1:length(indexs)
                    id = indexs(j);
                    Im = imread(char(fullfile(this.filesR.path,this.filesR.fR{id})));
                    %now montage together...
                    ImSuper = [ImSuper Im];
                    %need to recode to add new rows (make it a 2D montage!)
                end   
                %now resize:
                ims = imresize(ImSuper,[224 224],'lanczos3');
                imshow(ims);
                pause(1);
                ims = single(ims);
                feature_matrix(i,:) = SingleFeat(this.net,ims);
            end    
            save(saveName, 'feature_matrix', 'label', 'segm');
        end    
        function this = loadDbaseTemplates(this, fileName)
            load(fileName);  %templates_D
            this.templates_D = templates_D;
        end    
        function [cluster_id,match_candidates,quality] = findMatchesLMNN(this,currImageId,L,k,classes)
            Im = imread(char(fullfile(this.filesQ.path,this.filesQ.fQ{currImageId})));
            szIm = size(Im);
            Im = Im(this.initCrop(1):(szIm(1)-this.initCrop(2)),...
                this.initCrop(3):(szIm(2)-this.initCrop(4)),:);
            Im = imresize(Im, [224 224],'lanczos3');
            Im = single(Im);
            
            template_Q = SingleFeat(this.net, Im);
            %check that template_Q is in M rows x 1 column format.
            Qnew = L*template_Q;
            
            %now compare template_Q with templates_D using same method as
            %NetVLAD, but re-written here...
            %[ids,ds]= rawNnSearch(Qnew, this.templates_D, k); %this.templates_D needs to be pre-M distanced.
            %the above line will find the L2 distance and return the k
            %closest matches. k = cluster size in frames (or average size for a specific GPS cluster size).
            %quality = sum(ds);  %smaller this number, the better the confidence in the match.
            %sum the scores from all k candidates
            %match_candidates = ids;
            %match_candidates = ids; %also can look at the cluster class vector and see if 
            %many of these ids come from the same cluster.
            
            %alternatively, can consider an alternate alg:
            [ids,ds]= rawNnSearch(Qnew, this.templates_D, this.dSize);
            
            tops = ids(1:k);
            
            % what is the most common cluster id in tops, given the initial
            % cluster assignment?
            classids = classes(tops);
            [a,b] = histc(classids,unique(classids));
            y = a(b);
            [~,tmp] = max(y);
            classid = classids(tmp);
            
            logical = classes == classid;
            
            sorted_ids = sort(ids);
            
            final_ids = sorted_ids(logical==1);
            idx = find(ismember(final_ids,ids,'rows'));
            final_ds = ds(idx);
            quality = sum(final_ds);
            match_candidates = final_ids;
            cluster_id = classid;
        end
        function [match_candidates,quality] = findMatches(this,currImageId)
            Im = imread(char(fullfile(this.filesQ.path,this.filesQ.fQ{currImageId})));
            szIm = size(Im);
            Im = Im(this.initCrop(1):(szIm(1)-this.initCrop(2)),...
                this.initCrop(3):(szIm(2)-this.initCrop(4)),:);
            Im = imresize(Im, [224 224],'lanczos3');
            Im = single(Im);
            
            template_Q = SingleFeat(this.net, Im);
            
            %now compare template_Q with templates_D using same method as
            %NetVLAD, but re-written here...
            [ids,ds]= rawNnSearch(template_Q, this.templates_D, 1);
            quality = ds(1);  %smaller this number, the better the confidence in the match.
            ids = ids(1);
            %match_candidates = ids;
            match_candidates = (((ids-1)*16)+1 + 8);
        end
        function [cluster_id,match_candidates,quality] = findMatchesLMNNSeq(this,currImageId,L,k,classes,seqLength)
            pre_alloc = 1;
            imcount = 0;
            for j = (currImageId - seqLength + 1):currImageId  
                imcount = imcount + 1;
                Im = imread(char(fullfile(this.filesQ.path,this.filesQ.fQ{j})));
                if pre_alloc == 1
                    szIm = size(Im);
                    ims = zeros(224, 224, 3, seqLength,'single');
                    pre_alloc = 0;
                end    
                Im = Im(this.initCrop(1):(szIm(1)-this.initCrop(2)),...
                    this.initCrop(3):(szIm(2)-this.initCrop(4)),:);
                Im = imresize(Im, [224 224],'lanczos3');
                Im = single(Im);
                
                ims(:,:,:,imcount) = Im(:,:,:); 
            end   
            template_Q = MultiFeat(this.net, ims, seqLength);
            
            Qnew = L*template_Q;
            
            %now compare template_Q with templates_D using same method as
            %NetVLAD, but re-written here...
            %[ids,ds]= rawNnSearch(Qnew, this.templates_D, this.dSize);
            
            D = pdist2(Qnew',this.templates_D');
            Dsum = sum(D,1);
            [quality,match_candidates] = min(Dsum);
            cluster_id = classes(match_candidates);
            
%             tops = ids(1:k);
%             
%             % what is the most common cluster id in tops, given the initial
%             % cluster assignment?
%             classids = classes(tops);
%             [a,b] = histc(classids,unique(classids));
%             y = a(b);
%             [~,tmp] = max(y);
%             classid = classids(tmp);
%             
%             logical = classes == classid;
%             
%             sorted_ids = sort(ids);
%             
%             final_ids = sorted_ids(logical==1);
%             idx = find(ismember(final_ids,ids,'rows'));
%             final_ds = ds(idx);
%             quality = sum(final_ds);
%             match_candidates = final_ids;
%             cluster_id = classid;
        end    
        function [match_candidates,quality] = findMatchesSeq(this,currImageId,seqLength)
            pre_alloc = 1;
            imcount = 0;
            for k = (currImageId - seqLength + 1):currImageId  
                imcount = imcount + 1;
                Im = imread(char(fullfile(this.filesQ.path,this.filesQ.fQ{k})));
                if pre_alloc == 1
                    szIm = size(Im);
                    ims = zeros(224, 224, 3, seqLength,'single');
                    pre_alloc = 0;
                end    
                Im = Im(this.initCrop(1):(szIm(1)-this.initCrop(2)),...
                    this.initCrop(3):(szIm(2)-this.initCrop(4)),:);
                Im = imresize(Im, [224 224],'lanczos3');
                Im = single(Im);
                
                ims(:,:,:,imcount) = Im(:,:,:); 
            end   
            template_Q = MultiFeat(this.net, ims, seqLength);
            %now compare template_Q with templates_D using same method as
            %NetVLAD, but re-written here...
            [ids,ds]= rawNnSearch(template_Q, this.templates_D, 10);
            quality = ds(1);  %smaller this number, the better the confidence in the match.
            ids = ids(1);
            match_candidates = (((ids-1)*16)+1 + 8);
            %(ceil(((ids*16) - (((ids-1)*16)+1))/2))
        end    
    end
end    
function template_Q = SingleFeat(net, Im)
opts= struct(...
    'useGPU', true, ...
    'numThreads', 8, ...
    'batchSize', 1, ...
    'Resize',[480 640],...
    'CropSize',[1 1 1 1]...
    );
simpleNnOpts= {'conserveMemory', true, 'mode', 'test'};
if opts.useGPU
    net= relja_simplenn_move(net, 'gpu');
else
    net= relja_simplenn_move(net, 'cpu');
end
Im(:,:,1)= Im(:,:,1) - net.meta.normalization.averageImage(1,1,1);
Im(:,:,2)= Im(:,:,2) - net.meta.normalization.averageImage(1,1,2);
Im(:,:,3)= Im(:,:,3) - net.meta.normalization.averageImage(1,1,3);

if opts.useGPU
    ims= gpuArray(Im);
end

% ---------- extract features
res= vl_simplenn(net, ims, [], [], simpleNnOpts{:});
clear ims;
template_Q= reshape( gather(res(end).x), [], 1 );
clear res;

end
function template_Q = MultiFeat(net, ims, seqLength)
opts= struct(...
    'useGPU', true, ...
    'numThreads', 8, ...
    'batchSize', seqLength, ...
    'Resize',[480 640],...
    'CropSize',[1 1 1 1]...
    );
simpleNnOpts= {'conserveMemory', true, 'mode', 'test'};
if opts.useGPU
    net= relja_simplenn_move(net, 'gpu');
else
    net= relja_simplenn_move(net, 'cpu');
end
ims(:,:,1,:)= ims(:,:,1,:) - net.meta.normalization.averageImage(1,1,1);
ims(:,:,2,:)= ims(:,:,2,:) - net.meta.normalization.averageImage(1,1,2);
ims(:,:,3,:)= ims(:,:,3,:) - net.meta.normalization.averageImage(1,1,3);

% %resize images smaller and montage them together.
% ims_ = zeros(224,224,3);
% s = 56;
% % 1
% ims_(1:s,1:s,:) = imresize(ims(:,:,:,1), [s s],'lanczos3');
% ims_((s+1):2*s,1:s,:) = imresize(ims(:,:,:,2), [s s],'lanczos3');
% ims_((2*s+1):3*s,1:s,:) = imresize(ims(:,:,:,3), [s s],'lanczos3');
% ims_((3*s+1):4*s,1:s,:) = imresize(ims(:,:,:,4), [s s],'lanczos3');
% % 2
% ims_(1:s,(s+1):2*s,:) = imresize(ims(:,:,:,5), [s s],'lanczos3');
% ims_((s+1):2*s,(s+1):2*s,:) = imresize(ims(:,:,:,6), [s s],'lanczos3');
% ims_((2*s+1):3*s,(s+1):2*s,:) = imresize(ims(:,:,:,7), [s s],'lanczos3');
% ims_((3*s+1):4*s,(s+1):2*s,:) = imresize(ims(:,:,:,8), [s s],'lanczos3');
% % 3
% ims_(1:s,(2*s+1):3*s,:) = imresize(ims(:,:,:,9), [s s],'lanczos3');
% ims_((s+1):2*s,(2*s+1):3*s,:) = imresize(ims(:,:,:,10), [s s],'lanczos3');
% ims_((2*s+1):3*s,(2*s+1):3*s,:) = imresize(ims(:,:,:,11), [s s],'lanczos3');
% ims_((3*s+1):4*s,(2*s+1):3*s,:) = imresize(ims(:,:,:,12), [s s],'lanczos3');
% % 4
% ims_(1:s,(3*s+1):4*s,:) = imresize(ims(:,:,:,13), [s s],'lanczos3');
% ims_((s+1):2*s,(3*s+1):4*s,:) = imresize(ims(:,:,:,14), [s s],'lanczos3');
% ims_((2*s+1):3*s,(3*s+1):4*s,:) = imresize(ims(:,:,:,15), [s s],'lanczos3');
% ims_((3*s+1):4*s,(3*s+1):4*s,:) = imresize(ims(:,:,:,16), [s s],'lanczos3');
% 
% ims_ = single(ims_);

if opts.useGPU
    ims= gpuArray(ims);
end

% ---------- extract features
res= vl_simplenn(net, ims, [], [], simpleNnOpts{:});
clear ims_;
clear ims;
template_Q= reshape( gather(res(end).x), [], seqLength );
clear res;

end

function multiFeat_v2

end