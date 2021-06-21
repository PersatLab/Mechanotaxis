function []=read_parameters(adresse)
%INPUT: adresse where 'parameter.csv' is
%OUTPUT: 'parameter.csv' is deleted and 'parameter.mat' is created
[num,txt,~]=xlsread('parameters.csv');

delta_x=num(1);
delta_y=num(2);
delta_t=num(3);
nom_origine=txt{2,1};

clear num txt

delete(strcat(adresse,'/parameters.csv'));

save(strcat(adresse,'/parameters.mat'));

end