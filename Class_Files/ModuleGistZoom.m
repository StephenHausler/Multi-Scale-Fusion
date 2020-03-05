classdef ModuleGistZoom < Config
    properties
        templates_D;
    end  
    methods 
        function this = init(this)
            addpath('F:\MATLAB_2019_Working\Multi_Scale_Fusion_Ver1\gist');
            %addpath('/home/n7542704/MATLAB_2019_Working/Multi_Scale_Fusion_Ver1/gist');
        end
        function this = createDbaseTemplates(this)
            param.imageSize = [48 64];
            param.orientationsPerScale = [8 8 8 8];
            param.numberBlocks = 4;
            param.fc_prefilt = 4;
            %Create database template array:
            for i = 1:this.dSize
                Im = imread(char(fullfile(this.filesR.path,this.filesR.fR{i})));
                if i == 1
                    szIm = size(Im);
                end
                Im = Im(this.initCrop(1):(szIm(1)-this.initCrop(2)),...
                    this.initCrop(3):(szIm(2)-this.initCrop(4)),:);
                Im = rgb2gray(Im);
                this.templates_D(i,:) = LMgist(Im, '', param);
            end
        end    
        function this = saveDbaseTemplates(this, initCrop, saveName)
            this.initCrop = initCrop;
            %Create database template array:
%             param.imageSize = [64 64];
%             param.orientationsPerScale = [8 8 8 8];
%             param.numberBlocks = 4;
%             param.fc_prefilt = 4;
%           use default params
            for i = 1:this.dSize
                Im = imread(char(fullfile(this.filesR.path,this.filesR.fR{i})));
                if i == 1
                    szIm = size(Im);
                end
                Im = Im(this.initCrop(1):(szIm(1)-this.initCrop(2)),...
                    this.initCrop(3):(szIm(2)-this.initCrop(4)),:);
                Im = rgb2gray(Im);
                
                feature_matrix(i,:) = LMgist(Im);
            end
            %feature_matrix = LMgist(this.filesR.fR,this.filesR.path);
            save(saveName,'feature_matrix');
        end  
        function this = saveQueryTemplates(this, initCrop, saveName)
            this.initCrop = initCrop;
            %Create database template array:
%             param.imageSize = [64 64];
%             param.orientationsPerScale = [8 8 8 8];
%             param.numberBlocks = 4;
%             param.fc_prefilt = 4;
%           use default params
            for i = 1:this.qSize
                Im = imread(char(fullfile(this.filesQ.path,this.filesQ.fQ{i})));
                if i == 1
                    szIm = size(Im);
                end
                Im = Im(this.initCrop(1):(szIm(1)-this.initCrop(2)),...
                    this.initCrop(3):(szIm(2)-this.initCrop(4)),:);
                Im = rgb2gray(Im);
                
                feature_matrix(i,:) = LMgist(Im);
            end
            %feature_matrix = LMgist(this.filesR.fR,this.filesR.path);
            save(saveName,'feature_matrix');
        end
        %%
%         function this = saveQueryTemplates(this, saveName)
%             %Create query template array:
%             param.imageSize = [48 64];
%             param.orientationsPerScale = [8 8 8 8];
%             param.numberBlocks = 4;
%             param.fc_prefilt = 4;
%             for i = 1:this.qSize
%                 Im = imread(char(fullfile(this.filesQ.path,this.filesQ.fQ{i})));
% %                 if i == 1
% %                     szIm = size(Im);
% %                 end
% %                 Im = Im(this.initCrop(1):(szIm(1)-this.initCrop(2)),...
% %                     this.initCrop(3):(szIm(2)-this.initCrop(4)),:);
% %                 Im = rgb2gray(Im);
%                 feature_matrix(i,:) = LMgist(Im, '', param);
%             end
%             save(saveName,'feature_matrix');
%        end
        %%
        function this = loadDbaseTemplates(this, fileName)
            load(fileName);  %templates_D
            this.templates_D = templates_D; 
        end    
        function [match_candidates] = findMatches(this,currImageId,prev_match_candidates)
            %currently unused
            match_candidates = 0;
        end 
    end
end    




