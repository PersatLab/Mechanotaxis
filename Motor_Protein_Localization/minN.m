function [ MinK ] = mink( X, k )
%mink(X,k)returne the K minimum values of an 1D array
A=sort(X);
MinK=A(1:k);
end

