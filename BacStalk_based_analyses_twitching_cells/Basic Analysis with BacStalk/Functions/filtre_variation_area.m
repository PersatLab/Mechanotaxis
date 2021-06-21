function [data_brut,BactID]=filtre_variation_area(data_brut,BactID,time,limit)
% if the area varies to fast,I delete the bacteria
nbr_bact=size(BactID,1);
area=zeros(nbr_bact,3);


for nbr=1:1:nbr_bact
    area(nbr,1)=BactID(nbr,1);
    bacteria_time=BactID(nbr,2);
    bacteria_starting_time=BactID(nbr,3);
    area_tmp=zeros(bacteria_time,1);
    
    for t=1:1:bacteria_time
    data=data_brut.frames((bacteria_starting_time+t)-1).cells;
    n=find([data.Stats.TrackID]==BactID(nbr,1));
        if ~isempty(n)
        value=data.Stats(n).Area;
        area_tmp(t,1)=value;
        end
    end
    variance=var(area_tmp);  
    area(nbr,3)=variance;
end

%% now we fix de limit of the variation of the area
n=find(area(:,3)>limit);
if ~isempty(n)
    for i=1:1:size(n,1)
        bacterie=BactID(n(i),1);
        data_brut=delete_particule(bacterie,time,data_brut);
    end
end
% delete the cells
BactID(n,:)=[];
end

