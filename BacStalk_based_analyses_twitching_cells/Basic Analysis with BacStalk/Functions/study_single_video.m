function [BactID,cell_prop,Data_intensity,Data_speed,Data_alignment,Data_projection,BactID_non_moving,cell_prop_non_moving,Data_intensity_non_moving,Data_speed_non_moving] = study_single_video(adresse,speed_limit,speed_f)

%% Input
% adresse -> path of all images and all, most importantly the
% analyse_bacStalk.mat file
% speed_limit -> supposed to set the minimum speed limit of moving cells in
% pixel
% speed_f -> 1 = split data into moving and non-moving data sets, 0 = not
% split

%% Step1: load data
data_brut2=load('analyse_bacStalk.mat');
data_brut=data_brut2;
load('parameters.mat','delta_t','delta_x');

%% Variables
time=size(data_brut.frames,1);

%% Step 2: Filter the data
[data_brut,BactID]=filtres(data_brut,time);

%% Step 3: Study Intensity and Speed for each Bacteria
%intensity
[Data_intensity,cell_prop]=Intensity(adresse,BactID,time,data_brut,delta_x);
%speed
Data_speed=Speed(BactID,cell_prop,speed_limit,delta_x,delta_t);

%% Step 4: Delete da cell that have 0 speed all over the frames
if speed_f
[BactID,cell_prop,Data_intensity,Data_speed,BactID_non_moving, cell_prop_non_moving, Data_intensity_non_moving, Data_speed_non_moving]=Speed_filter(BactID,Data_speed,cell_prop,Data_intensity);
end 
%% Step 5: Alignment factor
Data_alignment=Alignment(BactID,Data_intensity,Data_speed);

%% Step 5: Projection Factor
Data_projection=Projection_factor(BactID,Data_speed,Data_intensity);
    
end

