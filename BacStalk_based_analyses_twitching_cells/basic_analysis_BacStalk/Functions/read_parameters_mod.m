function []=read_parameters(adresse)

[num,txt,~]=xlsread('parameters.csv');

delta_x=num(1);
delta_y=num(2);
delta_t=num(3);
nom_origine=txt{2,1};
adresse_origine=txt{1,1};

clear num txt

delete(strcat(adresse,'/parameters.csv'));

save(strcat(adresse,'/parameters.mat'));

end