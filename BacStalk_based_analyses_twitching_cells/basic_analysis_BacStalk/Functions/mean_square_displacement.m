function [MSD]=mean_square_displacement(vector)
sum=0;

x_0=vector(1,1);
y_0=vector(1,2);
N=size(vector,1);

%% r(t)=x(t)-x(0)
r_x=vector(:,1)-x_0;
r_y=vector(:,2)-y_0;

r_x(1)=[];

for t=2:1:N
    n=norm(vector(t)-v_0)^2;
    sum=sum+n;
end

MSD=sum/N
end