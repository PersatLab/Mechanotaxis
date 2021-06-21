function [Data_intensity,cell_prop] = Intensity(adresse,BactID,time,data_brut,delta_x)
%% variables
nbr_bact=size(BactID,1);
Data_intensity=cell(nbr_bact,5);
cell_prop=cell(nbr_bact,9);

%% loop on every cell
for nbr=1:1:nbr_bact
    Bact_info=Bacteria_information(time,nbr,data_brut,BactID);
    bacteria_time=BactID(nbr,2);
    % variables
    int=cell(bacteria_time,1);
    int_norm=zeros(bacteria_time,1);
    int_unitaire=cell(bacteria_time,1);
    CM1=zeros(bacteria_time,2);
    orientation=zeros(bacteria_time,1);
    poles=cell(bacteria_time,1);
    int_pole=cell(bacteria_time,1);
    contour=cell(bacteria_time,1);
    ratio_poles=zeros(bacteria_time,1);
    int_max=cell(bacteria_time,1);
 %% loop on all the times the cell is segmented   
     for t=1:1:bacteria_time
         poles{t}=poles_coordinate(Bact_info,t);
         [int_pole{t},ratio_poles(t),int_max{t}]=poles_intensity(adresse,poles{t},Bact_info,t,delta_x);
         int{t}=gradient_intensity(int_pole{t},poles{t});
         int_norm(t)=norm(int{t});
         if int_norm(t)~=0
         int_unitaire{t}=int{t}/int_norm(t);
         else
         int_unitaire{t}=[0,0];
         end

         CM1(t,:)=Bact_info{t,2}.Centroid;
         orientation(t)=Bact_info{t,2}.Orientation;
         contour{t,1}=Bact_info{t,2}.CellOutlineCoordinates;
     end
     
     Data_intensity{nbr,1}=BactID(nbr,1);
     Data_intensity{nbr,2}=bacteria_time;
     Data_intensity{nbr,3}=int;
     Data_intensity{nbr,4}=int_norm;
     Data_intensity{nbr,5}=int_unitaire;     

     cell_prop{nbr,1}=BactID(nbr,1);
     cell_prop{nbr,2}=bacteria_time;
     cell_prop{nbr,3}=CM1;
     cell_prop{nbr,4}=orientation;
     cell_prop{nbr,5}=poles;
     cell_prop{nbr,6}=int_pole;
     cell_prop{nbr,7}=cell2mat(Bact_info(:,1));
     cell_prop{nbr,8}=contour;
     cell_prop{nbr,9}=ratio_poles;
     cell_prop{nbr,10}=int_max;
     
     
end
end

