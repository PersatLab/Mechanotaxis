function [data_brut,BactID]=filtres(data_brut,time)
%% FILTRE 0: CellDeleted by BacStalk
[data_brut]=filtre_celldeleted(data_brut,time);
%% Filter 1: poles proximity
%[data_brut]=filtre_proximite(data_brut,time);
%% FILTER 2: presence
time_min=3;
[data_brut,BactID]=filtre_presence(data_brut,time,time_min);
%% Filter 3: area variations
limit=120;
[data_brut,BactID]=filtre_variation_area(data_brut,BactID,time,limit);
end







