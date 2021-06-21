function [Data_projection] = Projection_factor(BactID,Data_speed,Data_intensity)
nbr_bact=size(BactID,1);
Data_projection=cell(nbr_bact,4);

for nbr=1:1:nbr_bact
    bacteria_time=BactID(nbr,2);
    speed_proj=zeros(bacteria_time,1);
    intensity_proj=zeros(bacteria_time,1);

    for t=1:1:bacteria_time-1
        speed_proj(t)=dot(Data_speed{nbr,5}{t+1},Data_speed{nbr,5}{t});
        intensity_proj(t)=dot(Data_intensity{nbr,5}{t+1},Data_intensity{nbr,5}{t});
    end
    
    Data_projection{nbr,1}=BactID(nbr,1);
    Data_projection{nbr,2}=bacteria_time;
    Data_projection{nbr,3}=speed_proj;
    Data_projection{nbr,4}=intensity_proj;
end

end

