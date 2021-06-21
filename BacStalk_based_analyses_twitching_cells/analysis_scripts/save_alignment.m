% run before for graph alignement 
clear all
close all
%% Modify
directory='directory\';
limit_ratio=0.69; % ratio of intensity of the two poles; for all cells set limit to 1
alignment_limit=0; % alignment factor threshold (counts cells with alignment factor above this value)

% strains
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
Pil_type="316 fliC- PilB_mNG"
dates={'20200717';'20201002';'20201006';'20201023'};
intervals={'2s interval-2h37';'2s interval-2h37';'2s interval-2h37';'5s interval-2h37'};

[align_counts{j,2},align_counts{j,3}]=get_alignment(directory,Pil_type,dates,intervals,limit_ratio,alignment_limit); 
align_counts{j,1}=Pil_type;

clear dates intervals
end

 %% --------- PILT-------------------------
if mNG_PilT
j=j+1;
Pil_type="313 fliC- mNG_PilT"
dates={'20200717';'20201002';'20201006';'20201023'};
intervals={'2s interval-2h37';'2s interval-2h37';'2s interval-2h37';'2s interval-2h37'};

[align_counts{j,2},align_counts{j,3}]=get_alignment(directory,Pil_type,dates,intervals,limit_ratio,alignment_limit); 
align_counts{j,1}=Pil_type;

clear dates intervals
end

 %% --------- PILU-------------------------
if mNG_PilU
j=j+1;
Pil_type="314 fliC- mNG_PilU"
dates={'20200717';'20201002';'20201006';'20201023'};
intervals={'2s interval-2h37';'2s interval-2h37';'2s interval-2h37';'2s interval-2h37'};

[align_counts{j,2},align_counts{j,3}]=get_alignment(directory,Pil_type,dates,intervals,limit_ratio,alignment_limit); 
align_counts{j,1}=Pil_type;

clear dates intervals
end


 %% --------- PILG-------------------------
if mNG_PilG
j=j+1;
Pil_type="923 fliC- mNG_PilG"
dates={'20200717';'20201002';'20201006';'20201023'};
intervals={'2s interval-2h37';'2s interval-2h37';'2s interval-2h37';'5s interval-2h37'};

[align_counts{j,2},align_counts{j,3}]=get_alignment(directory,Pil_type,dates,intervals,limit_ratio,alignment_limit); 
align_counts{j,1}=Pil_type;

clear dates intervals
end

 %% --------- PILH-------------------------
if mNG_PilH
j=j+1;
Pil_type="315 fliC- mNG_PilH"
dates={'20200717';'20201002';'20201006';'20201023'};
intervals={'2s interval-2h37';'2s interval-2h37';'2s interval-2h37';'5s interval-2h37'};

[align_counts{j,2},align_counts{j,3}]=get_alignment(directory,Pil_type,dates,intervals,limit_ratio,alignment_limit); 
align_counts{j,1}=Pil_type;

clear dates intervals
end

%% --------- mNG-FimX-------------------------
if mNG_FimX
j=j+1;
Pil_type="463 fliC- mNG_FimX"
dates={'20200717';'20201002';'20201006';'20201023'};
intervals={'2s interval-2h37';'2s interval-2h37';'2s interval-2h37';'5s interval-2h37'};

[align_counts{j,2},align_counts{j,3}]=get_alignment(directory,Pil_type,dates,intervals,limit_ratio,alignment_limit); 
align_counts{j,1}=Pil_type;
 
 
clear dates intervals
end

%% save data for the function graph_alignment
save(strcat(directory,'Graphs\alignment_data.mat'),'align_counts','directory','limit_ratio');
