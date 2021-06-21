function [alignment_counts,Median_value_all]=get_alignment(directory1,Pil_type,dates,intervals,limit_ratio,alignment_limit)
%OUTPUT:
    % the output is alignment_counts which is a cell of 4 columns
    % column 1 = day number; from 1 to size(dates,1)
    % column 2 = folder number
    % column 3 = number of tracks with alignment factor > limit_ratio (disabled for now -> all tracks instead, symmetric and asymmetric)
    % column 4 = total number of tracks
    
    % added Median_value_all which is a column array of the median alignment factor for each track for all movies for all dates (only tracks above alignment_limit = moving towards bright pole)

i=0;
Median_value_all=[];

for d=1:1:size(dates,1)
        date=dates{d}
        interval=intervals{d}

        adresse_folder=strcat(directory1,Pil_type,'\',date,'\',interval);
        num_folder=length(dir(adresse_folder))-2;
        
        for folder=1:1:num_folder
            i=i+1;
            Median_value=[];
            Pil_nbr=folder;
            adresse_data=strcat(directory1,Pil_type,'\',date,'\',interval,'\',num2str(Pil_nbr));
            addpath(adresse_data)
            load('variables.mat','BactID','Data_alignment','cell_prop')
            
            nbr_bact=size(BactID,1);
            [~,median_value_tmp,~]=Histogram(nbr_bact,Data_alignment);
            for nbr=1:1:nbr_bact    
%                 ratio=cell_prop{nbr,9};
%                 mean_ratio=mean(ratio);
%                 if mean_ratio<limit_ratio % saves stuff only for tracks with mean intensity ratio of poles below limit_ratio (here: asymmetric)
                    Median_value=[Median_value;median_value_tmp(nbr)]; %calculat the median value of the alignment for each cell
%                 end
            end
              alignment_counts(i,1)=d;
              alignment_counts(i,2)=folder;
              alignment_counts(i,3)=sum(Median_value>alignment_limit);
              alignment_counts(i,4)=size(Median_value,1);
              
              Median_value_all=[Median_value_all;Median_value];
           
        end 
end
%     figure
%     histogram(Median_value_all,20,'Normalization','probability');
%     title(strcat('Pil',Pil_type));
%     xlabel('Alignment factor (speed, and intensity gradient normalized)')
%     ylabel('Probability')
end