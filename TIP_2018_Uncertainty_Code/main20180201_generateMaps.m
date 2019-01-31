%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Generates results and figures for TIP paper
%  Written by Tariq Alshawi, PhD student, Georgia Instituet of Tech
%  contact: talshawi@gatech.edu
%  Last update: 09/29/2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc

loadFileNames;
nPoints = 100;
Th = 0.35:0.05:0.65;
nScores = 6;
salMapMethodx = {'STSR','3DFFT','PQFT'};
mapScale = 'scale1';
AUCtotal = zeros(nScores,length(Th),3);
fileList = {CRCNS_List,DIEM_List,AVDlist};

for index=1:3
    TP=zeros(nScores,length(Th),length(fileList{index}),nPoints);
    FP=zeros(nScores,length(Th),length(fileList{index}),nPoints);
    Positive = zeros(length(Th),length(fileList{index}));
    Negative = zeros(length(Th),length(fileList{index}));
    
    for k=1:length(fileList{index})
        disp(['k= ' num2str(k)])

        salMapMethod = salMapMethodx{2};
        if index==1; prefix='CRCNS_';else; prefix='';end
        fileName=[prefix fileList{index}{k} '_salMap_' salMapMethod '_' mapScale '.mat'];
        load([pwd '/SaliencyMaps/' fileName ]);
        disp(fileName)
        if strcmp(salMapMethod,'3DFFT'); salMap = salMapScale1; end
        if strcmp(salMapMethod,'STSR')
            salMap = (salMap-min(salMap(:)))/(max(salMap(:))-min(salMap(:)));
        end
        
        % Load Eye-fixation Map
        fileName=[prefix fileList{index}{k} '_subsampledFxTruth_' mapScale '.mat'];
        if index==3; fileName=[fileList{index}{k} '_' mapScale '.mat'];end
        load([pwd '/EyeFixationMaps/' fileName]);
        disp(fileName)
        
        % Generate Uncertainty Groundtruth
        Tsize = min(size(subsampledFxTruth,3),size(salMap,3));
        disp(['size salMap = ' num2str(size(salMap,3)) ' - subsampledFxTruth = ' num2str(size(subsampledFxTruth))])
        mapSize = size(salMap,1)*size(salMap,2);
        uncert_gTruth = abs(salMap(:,:,1:Tsize)-subsampledFxTruth(:,:,1:Tsize));
   
        % Compute Binary Uncertainty Groundtruth
        GroundTruth = zeros(mapSize*Tsize,length(Th));
        for i=1:length(Th); GroundTruth(:,i) = uncert_gTruth(:)>=Th(i); end
        
        %%% Compute Scores for uncertainty estimation methods %%%
        
        % Spatial uncertainty estimation
        filter = ones(5,5);filter(3,3) = 0;
        [~, temp] = uncert_spatial(salMap(:,:,1:Tsize), filter);
        Scores1 = abs(temp(:));
        % Temporal uncertainty estimation
        filter = ones(1,5);filter(3) = 0;
        [~, temp] = uncert_temporal(salMap(:,:,1:Tsize), filter);
        Scores2 = abs(temp(:));
        % Spatiotemporal uncertainty estimation
        filter = ones(5,5,5);filter(3,3,3) = 0;
        [~, temp] = uncert_spatioTemporal(salMap(:,:,1:Tsize), filter);
        Scores3 = abs(temp(:));%/max(temp(:));
        % Entropy uncertainty estimation
        temp = uncert_EU(salMap(:,:,1:Tsize));
        Scores4 = abs(temp(:));
        % Spatial + Temporal uncertainty estimation
        Scores5 = 0.5*Scores1 + 0.5*Scores2;
        % Variance uncertainty estimation (baseline)
        filter = ones(5,5,5);filter(3,3,3) = 0;
        temp = uncert_Variance(salMap(:,:,1:Tsize), filter);
        Scores6 = abs(temp(:));
        
        mapGroundTruth = uncert_gTruth(:);
        mapFileName = [fileList{index}{k} '_Scores.mat'];
        save([pwd '\ScoresMaps\' mapFileName],'Scores1','Scores2','Scores3'...
            ,'Scores4','Scores5','Scores6','mapGroundTruth')
        
        % Normalize Scores
        Scores1 = Scores1 / max(Scores1(:));
        Scores2 = Scores2 / max(Scores2(:));
        Scores3 = Scores3 / max(Scores3(:));
        Scores4 = Scores4 / max(Scores4(:));
        Scores5 = Scores5 / max(Scores5(:));
        Scores6 = Scores6 / max(Scores6(:));
        
        % Count total positives and total negatives
        for i=1:length(Th)
            Positive(i,k)= length(find(GroundTruth(:,i)==1));
            Negative(i,k)= length(GroundTruth(:,i))-Positive(i,k);
        end
        
        
        Distance = [logspace(0,-5,nPoints-1) 0];
        % Count true positives and true negatives
        for idxi=1:nPoints
            for j=1:length(Th)
                TP(1,j,k,idxi) = sum(GroundTruth(:,j).*Scores1>Distance(idxi));
                TP(2,j,k,idxi) = sum(GroundTruth(:,j).*Scores2>Distance(idxi));
                TP(3,j,k,idxi) = sum(GroundTruth(:,j).*Scores3>Distance(idxi));
                TP(4,j,k,idxi) = sum(GroundTruth(:,j).*Scores4>Distance(idxi));
                TP(5,j,k,idxi) = sum(GroundTruth(:,j).*Scores5>Distance(idxi));
                TP(6,j,k,idxi) = sum(GroundTruth(:,j).*Scores6>Distance(idxi));
                
                FP(1,j,k,idxi) = sum(not(GroundTruth(:,j)).*Scores1>Distance(idxi));
                FP(2,j,k,idxi) = sum(not(GroundTruth(:,j)).*Scores2>Distance(idxi));
                FP(3,j,k,idxi) = sum(not(GroundTruth(:,j)).*Scores3>Distance(idxi));
                FP(4,j,k,idxi) = sum(not(GroundTruth(:,j)).*Scores4>Distance(idxi));
                FP(5,j,k,idxi) = sum(not(GroundTruth(:,j)).*Scores5>Distance(idxi));
                FP(6,j,k,idxi) = sum(not(GroundTruth(:,j)).*Scores6>Distance(idxi));
            end
        end
    end
    
    AUC = zeros(nScores,length(Th));
    
    % Compute AUC values
    for idxScores=1:nScores
        for idxTh=1:length(Th)
            AUC(idxScores, idxTh) = trapz(sum(squeeze(FP(idxScores,idxTh,:,:)))...
                /sum(squeeze(Negative(idxTh,:))),...
                sum(squeeze(TP(idxScores,idxTh,:,:)))...
                /sum(squeeze(Positive(idxTh,:))));
        end
    end
    
    
    % Plot results
    figure;
    plot(Th,AUC(2,:),'-*',Th,AUC(1,:),'-o',Th,AUC(5,:),'-x',Th,AUC(3,:),'-s',Th,AUC(4,:),...
        '-d')
    xlabel('Fixed Threshold T_1')
    ylabel('Area Under the Curve (AUC)')
    legend('TU[13]','SU[14]','SU+TU','STU','EU[12]')
    AUCtotal(:,:,index) = AUC;
end

figure;
bar(squeeze(AUCtotal([4,6,2,5,1,3],5,[2,1,3]))')
legend('EU[12]','Baseline','TU[13]','SU+TU','SU[14]','STU','Location','southeast')
xlabel('Computational Visual Attention Dataset')
ylabel('Area Under the Curve (AUC)')
xticklabels({'DIEM','CRCNS','AVD'})