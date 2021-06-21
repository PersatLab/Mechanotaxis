function [data_brut]=filtre_proximite(data_brut,time)
for t=1:1:time
    data=data_brut.frames(t).cells;
    nbr_bact=size(data.Stats,1);
    
    Matrice_distance_i_1_j_1=zeros(nbr_bact,nbr_bact);
    Matrice_distance_i_1_j_end=zeros(nbr_bact,nbr_bact);
    Matrice_distance_i_end_j_1=zeros(nbr_bact,nbr_bact);
    Matrice_distance_i_end_j_end=zeros(nbr_bact,nbr_bact);
    
    cell_to_del=[];
    for i=1:1:nbr_bact
        for j=i+1:1:nbr_bact
            poles_1=data.Stats(i).CellMedialAxisCoordinates(1,:);
            poles_2=data.Stats(i).CellMedialAxisCoordinates(end,:);

            poles_3=data.Stats(j).CellMedialAxisCoordinates(1,:);
            poles_4=data.Stats(j).CellMedialAxisCoordinates(end,:);
            
            radius_1=data.Stats(i).CellWidth/2;
            radius_3=data.Stats(j).CellWidth/2;
            
            distance_1_3=norm(poles_1-poles_3)/(radius_1+radius_3);
            distance_1_4=norm(poles_1-poles_4)/(radius_1+radius_3);
            distance_2_3=norm(poles_2-poles_3)/(radius_1+radius_3);
            distance_2_4=norm(poles_2-poles_4)/(radius_1+radius_3);
            
            Matrice_distance_i_1_j_1(i,j)=distance_1_3<=1; %ca vaut 1 si c'est vrai et 0 sinon
            Matrice_distance_i_1_j_end(i,j)=distance_1_4<=1;
            
            Matrice_distance_i_end_j_1(i,j)=distance_2_3<=1;
            Matrice_distance_i_end_j_end(i,j)=distance_2_4<=1;
        end
    end

    [row_i_1_j_1,col_i_1_j_1]=find(Matrice_distance_i_1_j_1);
    [row_i_1_j_end,col_i_1_j_end]=find(Matrice_distance_i_1_j_end);
    [row_i_end_j_1,col_i_end_j_1]=find(Matrice_distance_i_end_j_1);
    [row_i_end_j_end,col_i_end_j_end]=find(Matrice_distance_i_end_j_end);

    cell_to_del=[cell_to_del;unique(row_i_1_j_1);unique(col_i_1_j_1)];
    cell_to_del=unique(cell_to_del);

    cell_to_del=[cell_to_del;unique(row_i_1_j_end);unique(col_i_1_j_end)];
    cell_to_del=unique(cell_to_del);

    cell_to_del=[cell_to_del;unique(row_i_end_j_1);unique(col_i_end_j_1)];
    cell_to_del=unique(cell_to_del);

    cell_to_del=[cell_to_del;unique(row_i_end_j_end);unique(col_i_end_j_end)];
    cell_to_del=unique(cell_to_del);

    if ~isempty(cell_to_del)
        for n=1:1:size(cell_to_del,1)
          trackid=data.Stats(cell_to_del(n)).TrackID;
          data_brut=delete_particule(trackid,time,data_brut);
        end
    end
end
end

