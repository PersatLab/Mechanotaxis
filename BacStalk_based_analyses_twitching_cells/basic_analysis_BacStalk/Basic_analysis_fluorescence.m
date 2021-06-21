% This code needs to be used after running the ImageJ macro 'split_image.ijm'!
close all
clear all

%% -----------------------To Modify----------------------------------------
directory='directory'; % folder where everything is (i.e. folder with split_imageJ files for each strain)

% Select folders from xlsx file (Format of columns 1, 2, 3 must be Pil_types, dates, intervals, respectively. Must match folder structure in 'directory')
[num,txt,~]=xlsread('Input.xlsx'); % must be located in 'directory'
dates = num(:,1); % read as a column vector
Pil_types = txt(:,1); % read as a cell with one column
intervals = txt(:,3); % read as a cell with one column

% Select what part of the script to run
change_parameters_format = 1; % 1 if YES 0 if NO: this creates a 'parameters.mat' document with the info needed for the analysis
do_BacStalk = 1; % 1 if YES 0 if NO
do_SaveVariables = 1;  % 1 if YES 0 if NO
do_video = 1; % 1 if YES 0 if NO: creates movies with below conditions (just images, need to run imageJ macro video_maker afterwards)
do_nonmoving = 0; % 1 if YES 0 if NO: makes movie of non-moving cells - just to check correct speed threshold
do_fluopoles = 0; % 1 if YES 0 if NO: makes movie including pole ROIs - just to check correct placement of ROIs

% segmentation settings for Backstalk:
mean_cell_size='8'; %in pixel
min_cell_size='6'; %in pixel
search_radius='20'; %in pixel
dilation_width='0.5'; %in pixel

speed_limit=1; % to change according to how well the cells are moving

%------------------------------------------------------------------------------------------------
%% add path folder with functions
addpath(strcat(directory,'Functions'));

%% Start:
for d=1:1:size(dates,1)

    Pil_type=Pil_types{d}
    date=num2str(dates(d))
    interval=intervals{d}
    
    adresse1=strcat(directory,Pil_type,'\',date,'\',interval);
    addpath(adresse1);

    folders=dir(adresse1); % column array with with folder name
    num_folders=length(folders)-2; % counting number of folders in adresse1 (interval folder)

    for folder=1:1:num_folders
        %% Step 1:Load data
        adresse=strcat(adresse1,'\',folders(folder+2).name);
        addpath(adresse) % for the folder
        
        time=size(imfinfo(strcat(adresse,'\C0-data.tif')),1); %to count how many 'C0-data_t' image are in the folder.
     
        %% Step 2: save the parameters
        if change_parameters_format
          read_parameters(adresse);
        end
        load('parameters.mat','delta_x');
        %% Step 3: BacStalk
        if do_BacStalk
          addpath(strcat(directory,'BacStalk_modified')); 
          BacStalk_automated(adresse,time,mean_cell_size,min_cell_size,num2str(delta_x),search_radius,dilation_width)%directory,Pil_type,date,interval,Pil_nbr);
        end
        %% Step 4: Study video
        [BactID,cell_prop,Data_intensity,Data_speed,Data_alignment,Data_projection...
          ,BactID_non_moving,cell_prop_non_moving,Data_intensity_non_moving,Data_speed_non_moving]=study_single_video(adresse,speed_limit,1);
        nbr_bact=size(BactID,1);
        %% Step 5: save all variables
        filename=strcat(adresse,'\variables.mat');
        save(filename)
        %% step 6: create images for video 
        if do_video
            create_image_for_video(adresse,time,do_fluopoles,cell_prop,1);
            if do_nonmoving
                create_image_for_video(adresse,time,do_fluopoles,cell_prop_non_moving,0);
            end
        end
        %% step FINAL: remove path
        rmpath(adresse)
    end
     rmpath(adresse1)
end
