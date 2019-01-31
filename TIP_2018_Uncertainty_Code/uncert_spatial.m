%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Compute Spatial Uncertainty estimation of saliency maps as proposed  
%  in "UNSUPERVISED UNCERTAINTY ANALYSIS FOR VIDEO SALIENCY DETECTION" 
%  presented at Asilomar 2015, Montery, California.
%  Written by Tariq Alshawi, PhD student, Georgia Instituet of Technology
%  contact: talshawi@gatech.edu
%  Last update: 01/14/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This function takes two inputs: the saliency map (salMap) and processing
% filter (h). The function works by filtering (using h) each frame across
% spatial axes. The output are estimated spatial uncertainty
% (uncert_s) and neighbourhood average (average_profile)
function [average_profile, uncert_s] = uncert_spatial(salMap, h)
uncert_s = zeros(size(salMap));
average_profile = zeros(size(salMap));
for k=1:size(salMap,3)
    % place frame k in variable I
    I = squeeze(salMap(:,:,k));
    % compute the average of local neighbourhood (I_hat) 
    I_hat = imfilter(I,h,'conv');
    average_profile(:,:,k) = I_hat;
    temp = I_hat;
    % normalize the estimated spatial uncertainty (uncrt_s)  
    uncert_s(:,:,k) = temp;%/max(max(temp));
end
end
