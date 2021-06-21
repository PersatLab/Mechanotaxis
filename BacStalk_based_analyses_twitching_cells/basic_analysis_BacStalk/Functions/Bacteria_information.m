function [Bact_info] = Bacteria_information(time,nbr,data_brut,BactID)
bacteria=BactID(nbr,1);
bact_time=BactID(nbr,2);

Bact_info=cell(bact_time,2);
a=0;

for t=1:1:time
        data_tmp=data_brut.frames(t).cells;
        nbr_particules=size(data_tmp.Stats,1);
        TrackID=zeros(nbr_particules,1);
        for p=1:1:nbr_particules
        TrackID(p)=data_tmp.Stats(p).TrackID;
        end
        
        indice=find(TrackID==bacteria);
        
        if indice
        a=a+1;
        Bact_info{a,2}=data_tmp.Stats(indice);
        Bact_info{a,1}=t;
        end
    
end
end

