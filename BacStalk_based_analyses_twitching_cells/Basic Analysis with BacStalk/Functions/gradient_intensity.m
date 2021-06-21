 function [int] = gradient_intensity(int_pole,cdn_cercle)
 %% creation du vecteur intensit�
int=zeros(1,2);
int(1,1)=cdn_cercle(1,1)-cdn_cercle(2,1);
int(1,2)=cdn_cercle(1,2)-cdn_cercle(2,2);
int=(int_pole(1,1)-int_pole(1,2))*int/norm(int); % int norm is intensity difference 
end


