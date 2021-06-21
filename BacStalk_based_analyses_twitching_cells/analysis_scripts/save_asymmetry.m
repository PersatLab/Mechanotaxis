% graph distribution moving, non moving and all cells
clear all
close all
%% Modify
directory='directory\';
limite_ratio=0.69;

% Strains
PilB_mNG=1; mNG_PilT=1; mNG_PilU=1;
mNG_PilG=1; mNG_PilH=1; mNG_FimX=1;


%% load functions
addpath(strcat(directory,'Functions')); 
addpath(directory);

%% variables
j=0;

%% --------- PILB-------------------------
if PilB_mNG
j=j+1;
Pil_type='316 fliC- PilB_mNG'
dates={'20200717';'20201002';'20201006';'20201023'};
intervals={'2s interval-2h37';'2s interval-2h37';'2s interval-2h37';'5s interval-2h37'};

[moving_distribution{j,2},non_moving_distribution{j,2}]=get_symm_asymm(directory,Pil_type,dates,intervals,limite_ratio);
moving_distribution{j,1}=Pil_type;
non_moving_distribution{j,1}=Pil_type;

clear dates intervals
end

%% --------- PILT-------------------------
if mNG_PilT
j=j+1;
Pil_type='313 fliC- mNG_PilT'
dates={'20200717';'20201002';'20201006';'20201023'};
intervals={'2s interval-2h37';'2s interval-2h37';'2s interval-2h37';'2s interval-2h37'};

[moving_distribution{j,2},non_moving_distribution{j,2}]=get_symm_asymm(directory,Pil_type,dates,intervals,limite_ratio);
moving_distribution{j,1}=Pil_type;
non_moving_distribution{j,1}=Pil_type;

clear dates intervals
end

%% --------- PILU-------------------------
if mNG_PilU
j=j+1;
Pil_type='314 fliC- mNG_PilU'
dates={'20200717';'20201002';'20201006';'20201023'};
intervals={'2s interval-2h37';'2s interval-2h37';'2s interval-2h37';'2s interval-2h37'};

[moving_distribution{j,2},non_moving_distribution{j,2}]=get_symm_asymm(directory,Pil_type,dates,intervals,limite_ratio);
moving_distribution{j,1}=Pil_type;
non_moving_distribution{j,1}=Pil_type;

clear dates intervals
end

%% --------- PILG-------------------------
if mNG_PilG
j=j+1;
Pil_type='923 fliC- mNG_PilG'
dates={'20200717';'20201002';'20201006';'20201023'};
intervals={'2s interval-2h37';'2s interval-2h37';'2s interval-2h37';'5s interval-2h37'};

[moving_distribution{j,2},non_moving_distribution{j,2}]=get_symm_asymm(directory,Pil_type,dates,intervals,limite_ratio);
moving_distribution{j,1}=Pil_type;
non_moving_distribution{j,1}=Pil_type;

clear dates intervals
end

%% --------- PILH-------------------------
if mNG_PilH
j=j+1;
Pil_type='315 fliC- mNG_PilH'
dates={'20200717';'20201002';'20201006';'20201023'};%;'20200821'};
intervals={'2s interval-2h37';'2s interval-2h37';'2s interval-2h37';'5s interval-2h37'};%;'5s interval-2h37'};

[moving_distribution{j,2},non_moving_distribution{j,2}]=get_symm_asymm(directory,Pil_type,dates,intervals,limite_ratio);
moving_distribution{j,1}=Pil_type;
non_moving_distribution{j,1}=Pil_type;

clear dates intervals
end
%% --------- FimX-------------------------
if mNG_FimX
j=j+1;
Pil_type='463 fliC- mNG_FimX'
dates={'20200717';'20201002';'20201006';'20201023'};
intervals={'2s interval-2h37';'2s interval-2h37';'2s interval-2h37';'5s interval-2h37'};

[moving_distribution{j,2},non_moving_distribution{j,2}]=get_symm_asymm(directory,Pil_type,dates,intervals,limite_ratio);
moving_distribution{j,1}=Pil_type;
non_moving_distribution{j,1}=Pil_type;

clear dates intervals
end

%% save data:
save(strcat(directory,'Graphs\asymmetry_data.mat'),'moving_distribution','non_moving_distribution');
