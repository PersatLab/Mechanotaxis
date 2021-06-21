function [BactID,cell_prop,Data_speed,BactID_non_moving, cell_prop_non_moving, Data_speed_non_moving]=Speed_filter_phase_contrast(BactID,Data_speed,cell_prop)
nbr_bact=size(BactID,1);
n=[];
for nbr=1:1:nbr_bact
    time=size(cell_prop{nbr,3},1);
    tmp=0;
    speed=Data_speed{nbr,4};
     for t=1:1:time-2
         if speed(t)~=0 && speed(t+1)~=0 && speed(t+2)~=0
             tmp=1;
         end         
     end
     if ~tmp
        n=[n;nbr];
     end
end
%% Deletion of the data
    BactID_non_moving=BactID(n,:);

    Data_speed_non_moving=Data_speed(n,:);
    cell_prop_non_moving=cell_prop(n,:);

    BactID(n,:)=[];

    Data_speed(n,:)=[];
    cell_prop(n,:)=[];
end

