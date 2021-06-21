function [int_pole,ratio_poles, int_max] = poles_intensity(adresse,poles,Bact_info,t,delta_x)
t=Bact_info{t,1};
%imageData_fluo = imread(char(strcat('C1-data_t',sprintfc('%02d',t-1),'.tif')));
imageData_fluo = imread(strcat(adresse,'\C1-data.tif'),t);
% imageData_fluo = uint16(imageData_fluo);

[xDim,yDim]=size(imageData_fluo);
int_pole=zeros(1,size(poles,1));
int_max=zeros(1,size(poles,1));
 for i=1:1:size(poles,1)
   masque_cercle=uint16(mask(poles(i,1),poles(i,2),poles(i,3),xDim,yDim));
   nbr_pixel=sum(sum(masque_cercle));
   img=masque_cercle.*imageData_fluo;
   radius_um=poles(i,3)*delta_x; % to transform pixel in micro meters
   %cercle_area=pi*(radius_um^2);
   int_pole(i)=sum(sum(img))/nbr_pixel;%cercle_area;
   
   int_max(i)=max(max(img));
 end
 
 ratio_poles=min(int_pole(1:2))/max(int_pole(1:2));
end

