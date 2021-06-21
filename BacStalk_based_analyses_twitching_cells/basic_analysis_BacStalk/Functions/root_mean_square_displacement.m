function [RMSD]=root_mean_square_displacement(vector)
sum=0;

x_0=vector(1,1);
y_0=vector(1,2);
N=size(vector,1);

%% r(t)=x(t)-x(0)
r_x=vector(:,1)-x_0;
r_y=vector(:,2)-y_0;

r_x(1)=[];
r_y(1)=[];

r=[r_x,r_y];

%%RMSD
for t=1:1:size(r,1)
    n(t)=norm(r(t,:));
end

% RMSD=sqrt(mean(n));
RMSD=(mean(n));
end