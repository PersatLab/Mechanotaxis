function [Data_alignment] = Alignment(BactID,Data_intensity,Data_speed)
nbr_bact=size(BactID,1);
Data_alignment=cell(nbr_bact,3);

for nbr=1:1:nbr_bact
    bacteria_time=BactID(nbr,2);
    align_factor_unitary=projection(Data_intensity{nbr,5},Data_speed{nbr,5});

    Data_alignment{nbr,1}=BactID(nbr,1);
    Data_alignment{nbr,2}=bacteria_time;
    Data_alignment{nbr,3}=align_factor_unitary;
end
end

