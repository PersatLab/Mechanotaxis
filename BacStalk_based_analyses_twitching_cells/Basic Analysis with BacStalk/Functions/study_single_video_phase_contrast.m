function [BactID,cell_prop,Data_speed,BactID_non_moving,cell_prop_non_moving,Data_speed_non_moving] = study_single_video_phase_contrast(adresse,speed_limit,speed_f)
%% Step1: load data
data_brut2=load('analyse_bacStalk.mat');
data_brut=data_brut2;
load('parameters.mat');

%% Variables
time=size(data_brut.frames,1);

%% Step 1: Filter the data
[data_brut,BactID]=filtres(data_brut,time);

%% Step 2: Study Intensity and Speed for each Bacteria
%intensity
[cell_prop]=cell_properties(adresse,BactID,time,data_brut,delta_x);
%speed
Data_speed=Speed(BactID,cell_prop,speed_limit,delta_x,delta_t);

%% Step 3: Clissify by moving and non moving
if speed_f
[BactID,cell_prop,Data_speed,BactID_non_moving,cell_prop_non_moving,Data_speed_non_moving]=Speed_filter_phase_contrast(BactID,Data_speed,cell_prop);
end 
    
end

