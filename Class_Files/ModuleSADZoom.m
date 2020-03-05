classdef ModuleSADZoom < Config
    properties
        templates_D;
        N = 100;   %number of candidates output by this module
        M;          %number of candidates supplied to this module
        pyrlevel;   %needed in order to make code agnostic to module location
        normalise = 1;        
        rWindow = 20;        
        D_store;       
    end  
    methods
        function this = setNumCandidates(this,prevCanCount,NumCans,pyrlevel)
            if pyrlevel == 1
                if ((NumCans > 0) && (NumCans < this.dSize))
                    this.N = NumCans;
                else
                    error('Please enter valid SAD module candidate count, between 1 and number of database images');
                end    
            else
                if ((NumCans > 0) && (NumCans < prevCanCount))
                    this.N = NumCans;
                else
                    error('Please enter valid SAD module candidate count, between 1 and previous match candidate count');
                end
                %this.M = prevCanCount;
            end
            this.pyrlevel = pyrlevel;
        end        
        function this = createDbaseTemplates(this)
            %Create database template array:
            for i = 1:this.dSize
                Im = imread(char(fullfile(this.filesR.path,this.filesR.fR{i})));
                if i == 1
                    szIm = size(Im);
                end
                Im = Im(this.initCrop(1):(szIm(1)-this.initCrop(2)),...
                    this.initCrop(3):(szIm(2)-this.initCrop(4)),:);
                if i == 1
                    this.templates_D = cast(this.templates_D,'uint8');
                end
                Im = imresize(Im,[this.SAD_resize(2) this.SAD_resize(1)],'lanczos3');
                Im = rgb2gray(Im);
                ImP = patchNormalizeHMM(Im,this.SAD_patchsize,0,0);
                this.templates_D(i,:) = ImP(:);
            end     
            this.D_store = zeros(this.qSize,this.dSize); 
        end    
        function this = saveDbaseTemplates(this, initCrop, saveName)
            this.initCrop = initCrop;
            %Create database template array:
            for i = 1:this.dSize
                Im = imread(char(fullfile(this.filesR.path,this.filesR.fR{i})));
                if i == 1
                    szIm = size(Im);
                end
                Im = Im(this.initCrop(1):(szIm(1)-this.initCrop(2)),...
                    this.initCrop(3):(szIm(2)-this.initCrop(4)),:);
                if i == 1
                    this.templates_D = cast(this.templates_D,'uint8');
                end
                Im = imresize(Im,[this.SAD_resize(2) this.SAD_resize(1)],'lanczos3');
                Im = rgb2gray(Im);
                ImP = patchNormalizeHMM(Im,this.SAD_patchsize,0,0);
                feature_matrix(i,:) = ImP(:);
            end     
            save(saveName, 'feature_matrix');
        end  
        function this = saveQueryTemplates(this, initCrop, saveName)
            this.initCrop = initCrop;
            %create query template array:
            for i = 1:this.qSize
                Im = imread(char(fullfile(this.filesQ.path,this.filesQ.fQ{i})));
                if i == 1
                    szIm = size(Im);
                end
                Im = Im(this.initCrop(1):(szIm(1)-this.initCrop(2)),...
                    this.initCrop(3):(szIm(2)-this.initCrop(4)),:);
                if i == 1
                    this.templates_D = cast(this.templates_D,'uint8');
                end
                Im = imresize(Im,[this.SAD_resize(2) this.SAD_resize(1)],'lanczos3');
                Im = rgb2gray(Im);
                ImP = patchNormalizeHMM(Im,this.SAD_patchsize,0,0);
                feature_matrix(i,:) = ImP(:);
            end    
            save(saveName, 'feature_matrix');
        end    
        function this = loadDbaseTemplates(this, fileName)
            load(fileName);  %templates_D
            this.templates_D = templates_D;
            this.D_store = zeros(this.qSize,this.dSize); 
        end  
        function [match_candidates, this] = findMatches(this,currImageId,prev_match_candidates)
            Im = imread(char(fullfile(this.filesQ.path,this.filesQ.fQ{currImageId})));
            szIm = size(Im);
            Im = Im(this.initCrop(1):(szIm(1)-this.initCrop(2)),...
                this.initCrop(3):(szIm(2)-this.initCrop(4)),:);
            
            Im = imresize(Im,[this.SAD_resize(2) this.SAD_resize(1)],'lanczos3');
            Im = rgb2gray(Im);
            ImP = patchNormalizeHMM(Im,this.SAD_patchsize,0,0);
            template_Q(1,:) = ImP(:);
            
            if this.pyrlevel == 1          
                D = abs(this.templates_D - template_Q);
                D = sum(D,2)./(this.SAD_resize(2)*this.SAD_resize(1));
            else    
                D = abs(this.templates_D(prev_match_candidates,:) - template_Q);
                D = sum(D,2)./(this.SAD_resize(2)*this.SAD_resize(1));
            end
            if this.normalise == 1
                D_h = (D - mean(D)) ./ std(D);

                this.D_store(currImageId,:) = D_h;

                if currImageId > this.rWindow
                    for i = 1:length(D_h)
                       D_h(i) = (D_h(i) - mean(this.D_store((currImageId-this.rWindow):(currImageId),i))) ...
                           ./ std(this.D_store((currImageId-this.rWindow):(currImageId),i));      
                    end
                    clear D
                    D = D_h;
                else
                    clear D
                    D = D_h;   
                end
            end          
            sad_candidates = NaN(this.N,1);
            for i = 1:this.N
                [~,sad_candidates(i)] = min(D); %candidates are the best N scores
                D(sad_candidates(i)) = NaN;
            end
            if this.pyrlevel == 1
                match_candidates = sad_candidates;   
            else
                match_candidates = prev_match_candidates(sad_candidates);   
            end 
        end    
    end
end    




