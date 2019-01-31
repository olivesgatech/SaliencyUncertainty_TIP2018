%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Compute Temporal Uncertainty estimation of saliency maps as proposed  
%  in "UNSUPERVISED ESTIMATION OF UNCERTAINTY FOR VIDEO SALIENCY DETECTION
%  USING TEMPORAL CUES" presented at GlobalSIP 2015, Orlando, Florida.
%  Written by Tariq Alshawi, PhD student, Georgia Instituet of Technology
%  contact: talshawi@gatech.edu
%  Last update: 01/14/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This function takes two inputs: the saliency map (salMap) and processing
% filter (h). The function works by filtering (using h) each pixel across 
% time axis (frames). The output are estimated temporal uncertainty
% (uncert_t) and neighbourhood average (average_profile)
function [average_profile, uncert_t] = uncert_temporal(salMap, h)
uncert_t = zeros(size(salMap));
average_profile = zeros(size(salMap));
for m=1:size(salMap,1)
    for n=1:size(salMap,2)
        % place pixel (m,n) in variable I
        I = squeeze(salMap(m,n,:));
        % compute the average of local neighbourhood (I_hat) 
        I_hat = filter(h,1,I);
        average_profile(m,n,:) = I_hat;
        temp = I_hat;
        % normalize the estimated temporal uncertainty (uncrt_t)  
        uncert_t(m,n,:) = temp;%/max(max(temp));
    end
end
end
