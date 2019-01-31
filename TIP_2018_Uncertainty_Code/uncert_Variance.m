%%%%%%%%%%%%%%%%%%%%%%%%%
% Last Update 6/2/2018
%%%%%%%%%%%%%%%%%%%%%%%%%

function  uncert_3D = uncert_Variance(salMap, h)
% centerIndex = (WinSize-1)/2+[1 1 1];
% h(centerIndex) = -1;
 temp = stdfilt(salMap,h).^2;
 uncert_3D = temp/max(temp(:));
% h = ones(WinSize);
% h = h/numel(h);
% uncert_3D = salMap - imfilter(salMap,h);
% x = (WinSize(1)-1)/2;
% y = (WinSize(2)-1)/2;
% z = (WinSize(3)-1)/2;
% uncert_3D = zeros(size(salMap));
% pad = padarray(salMap, [x y z]);
% for k=z+1:size(pad,3)-z
%     for i=x+1:size(pad,1)-x
%         for j=y+1:size(pad,2)-y
%             window = pad(i-x:i+x,j-y:j+y,k-z:k+z);
%             uncert_3D(i-x,j-y,k-z) = squeeze(pad(i,j,k)) - mean(window(:));
%         end
%     end
% end
end