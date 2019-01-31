function out = normalizeFun(in)
temp = in;
temp(temp<0.05) = [];
temp(temp>1) = [];
out = temp;