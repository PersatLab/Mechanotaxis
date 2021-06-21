function [ CI ] = ci_percentile( X )
%ci_percentile(X) Returns the 95 % confidence interval of a dataset X
% by removing the top and bottom 2,5 % of the data
Tail=floor(length(X)/100*2.5);
A=maxk(X,Tail+1);
CI(2,1)=A(1);
B=mink(X,Tail+1);
CI(1,1)=B(end);
end

