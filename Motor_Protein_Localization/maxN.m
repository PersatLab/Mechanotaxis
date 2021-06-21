function [ MaxK ] = maxN( X, k )
%maxk(X,k)return the K maximum values of a 1D array
A=sort(X);
d=length(A);
MaxK=A(d-k+1:d);
end

