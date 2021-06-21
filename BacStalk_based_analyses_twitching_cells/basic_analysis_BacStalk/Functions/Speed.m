function [Data_speed] = Speed(BactID,cell_prop,speed_limit,delta_x,delta_t)
nbr_bact=size(BactID,1);
Data_speed=cell(nbr_bact,6);
for nbr=1:1:nbr_bact
    bacteria_time=BactID(nbr,2);
    vit=cell(bacteria_time,1);
    vit_norm=zeros(bacteria_time,1);
    vit_unitaire=cell(bacteria_time,1);
    vit_extracted=cell(bacteria_time,1);
    
    vit{1}=[0 0];
    vit_norm(1,1)=0;
    vit_unitaire{1}=[0 0];
    vit_extracted{1}=[0 0];

    CM=cell_prop{nbr,3};

    for t=2:1:bacteria_time
        vit{t}=[CM(t,1)-CM(t-1,1)  CM(t,2)-CM(t-1,2)];
        vit{t}=vit{t}*(delta_x/delta_t); % to change units from pixel/frame to um/s
        vit_norm(t)=norm(vit{t});
        if vit_norm(t)<speed_limit*delta_x/delta_t
        vit_extracted{t}= vit{t};
        vit{t}=[0 0];
        vit_norm(t)=0;
        vit_unitaire{t}=[0 0];
        else
        vit_extracted{t}=vit{t};
        vit_unitaire{t}=vit{t}/vit_norm(t);
        end
    end

    Data_speed{nbr,1}=BactID(nbr,1);
    Data_speed{nbr,2}=bacteria_time;
    Data_speed{nbr,3}=vit;
    Data_speed{nbr,4}=vit_norm;
    Data_speed{nbr,5}=vit_unitaire;
    Data_speed{nbr,6}=vit_extracted;
    
    clear CM
end
end

