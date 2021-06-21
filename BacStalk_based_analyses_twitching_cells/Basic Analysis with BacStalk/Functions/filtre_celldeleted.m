function [data_brut] = filtre_celldeleted(data_brut,time)   
for t=1:1:time
    data=[data_brut.frames(t).cells.Stats.CellDeleted];
    n=find(data==1); 
    if ~isempty(n)
    data_brut.frames(t).cells.Stats(n)=[];
    end 
end
end

