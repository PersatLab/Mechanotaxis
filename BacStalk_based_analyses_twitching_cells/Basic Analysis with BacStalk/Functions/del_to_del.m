%%delete folders

directory='X:\Iscia_WS\PersatLAb-master\';
Pil_type='PilU';
% date='170720';
% interval='10s interval';

adresse2=strcat(directory,Pil_type)
dates=dir(adresse2);
num_dates=length(dates)-2;

for d=1:1:num_dates
    date=dates(d+2).name;
    adresse3=strcat(directory,Pil_type,'\',date)
    intervals=dir(adresse3);
    num_intervals=length(intervals)-2
    
    for interval=1:1:num_intervals
        interval=intervals(interval+2).name
        adresse1=strcat(directory,Pil_type,'\',date,'\',interval)
        addpath(adresse1);
        folders=dir(adresse1);
        num_folders=length(folders)-3;

         for folder=1:1:num_folders
             Pil_nbr=folders(folder+2).name;
            %% Load variables and add path
%             addpath(strcat(directory,'Functions')); % for general functions
            adresse=strcat(directory,Pil_type,'\',date,'\',interval,'\',Pil_nbr)
            addpath(adresse)
            %% 
            document=dir(adresse);
            indice=[];
            for i=1:1:size(document,1)
                if contains(document(i).name,'C0-data_t')
                    indice=[indice;i];
                elseif contains(document(i).name,'C1-data_t')
                    indice=[indice;i];
%                elseif contains(document(i).name,'Movie')
%                     indice=[indice;i];
                end
            end

            for i=1:1:size(indice,1)
               delete(strcat(adresse,'\',document(indice(i)).name));
            end

            delete(strcat(adresse,'\data.tif'));
            rmpath(adresse)
            
            adresse=strcat(directory,Pil_type,'\',date,'\',interval,'\',Pil_nbr,'\Movie')
            addpath(adresse)
            
            document=dir(adresse);
            for i=3:1:size(document,1)
            delete(strcat(adresse,'\',document(i).name));
            end
         end
    end
end