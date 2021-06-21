function [data_brut] = delete_particule(numero_particule,time,data_brut)
   for t=1:1:time
         data=data_brut.frames(t).cells;
         nbr_particules=size(data.Stats,1);
         TrackID=zeros(nbr_particules,1);
       for p=1:1:nbr_particules
         TrackID(p)=data.Stats(p).TrackID;
       end
       indice=find(TrackID==numero_particule);
       if indice
       data_brut.frames(t).cells.Stats(indice)=[];
       end
    end
end

