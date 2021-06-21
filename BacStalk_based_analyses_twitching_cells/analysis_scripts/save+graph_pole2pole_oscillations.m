close all
clear all
%% Set options

combined = 1;    move = 0;
filtered = 0;

%% Set directories
directory='directory\';
addpath(strcat(directory,'Functions'));
addpath(directory);
%% Load data
% Select folders from csv file (Format of columns 1, 2, 3 must be Pil_types, dates, intervals, respectively (see Table "Sample Information"))
[num,txt,~]=xlsread('Input.xlsx'); % must be located in 'directory'
dates = num(:,1); % read as a column vector
Pil_types = txt(:,1); % read as a cell with one column
intervals = txt(:,3); % read as a cell with one column
clear num txt
%% Load Variables, Loop over all samples
pole2pole_data = cell(size(intervals,1),10);
for row = 1:size(pole2pole_data,1)
    pole2pole_data{row,4} = 0;
    pole2pole_data{row,5} = 0;
end
for sample = 1:size(intervals,1)
    Pil_type = Pil_types{sample};
    date = dates(sample);
    interval = intervals{sample};

    adresse_folder = strcat(directory,Pil_type,'\',num2str(date),'\',interval);
    nbr_folders = length(dir(adresse_folder))-2;

    %% Loop over all folders
    for folder = 1:nbr_folders
        adresse_data=strcat(directory,Pil_type,'\',num2str(date),'\',interval,'\',num2str(folder));
        addpath(adresse_data)
        
        if combined
            load('variables.mat','cell_prop','cell_prop_non_moving')
            cell_info =  vertcat(cell_prop,cell_prop_non_moving);
        else           
            if move
                load('variables.mat','cell_prop')    
                cell_info=cell_prop;
            else
                load('variables.mat','cell_prop_non_moving')
                cell_info=cell_prop_non_moving;
            end
        end

        load('parameters.mat','delta_t')

        %% Loop over all cell tracks
        
        if size(cell_info,1) == 0 % if no tracks for that folder
            pole2pole_folder(1,1) = 0; % % number of cell track - set to 0
            pole2pole_folder(1,2) = 0; % number of frames tracked - set to 0
            pole2pole_folder(1,3) = 0; % total number of pole2pole switches for each cell track - set to 0
            pole2pole_folder(1,4) = NaN; % number of pole2pole switches normalized by time in minutes (i.e. X siwtches per min) - set to nothing
        else
            pole2pole_folder = zeros(size(cell_info,1),4);
            for nbr = 1:size(cell_info,1)
                %% Label poles correctly
                poles_coord = cell_info{nbr,5};
                poles_int_mean = cell_info{nbr,6};
                poles_int_max = cell_info{nbr,10};
                CM = cell_info{nbr,3};
                [pole_A,pole_B] = label_the_poles(poles_coord,CM,poles_int_mean,poles_int_max);
                clear poles_coord poles_int_mean poles_int_max
                %% Find pole2pole intensity change
                nbr_frames = size(pole_A,1);
                pole2pole =zeros(nbr_frames+1,3);

                for frame = 1:nbr_frames
                    if pole_A(frame,4) > pole_B(frame,4)
                        pole2pole(frame,1) = 1;
                    elseif pole_A(frame,4) < pole_B(frame,4)
                        pole2pole(frame,1) = -1;
                    end
                end
                %% Count pole2pole switches
                for frame = 2:nbr_frames % checks if there is a change from -1 to 1 or vice versa from previous to current frame
                    pole_switch = pole2pole(frame-1,1) + pole2pole(frame,1);
                    if pole_switch == 0
                        pole2pole(frame,2) = 1;   
                    else
                        pole2pole(frame,2) = 0;
                    end
                end
                for frame = 2:nbr_frames % adds additional column with "filtered" pole2pole switches (if 2 switches in subsequent frames, i.e. just change of bright pole for 1 frame, doesn't count)
                    pole_switch_filterd = pole2pole(frame-1,2) + pole2pole(frame,2) + pole2pole(frame+1,2);
                    if pole_switch_filterd == 0 | pole_switch_filterd == 1
                        pole2pole(frame,3) = pole2pole(frame,2);   
                    elseif pole_switch > 1
                        pole2pole(frame,3) = 0;
                    end
                end
                clear pole_switch
                %% Collect number of pole switches for each cell track and combine to matrix for all cell tracks in the current folder
                pole2pole_folder(nbr,1) = cell_info{nbr,1}; % number of cell track
                pole2pole_folder(nbr,2) = cell_info{nbr,2}; % number of frames tracked
                if filtered
                    pole2pole_folder(nbr,3) = sum(pole2pole(:,3)); % total number of pole2pole switches (filtered) for each cell track
                else
                    pole2pole_folder(nbr,3) = sum(pole2pole(:,2)); % total number of pole2pole switches (unfiltered) for each cell track
                end
                pole2pole_folder(nbr,4) = pole2pole_folder(nbr,3) / ((pole2pole_folder(nbr,2)*delta_t)/60); % number of pole2pole switches normalized by time in minutes (i.e. X siwtches per min)
            end
            clear pole2pole
        end
        %% Collect data over all folders for the current sample
        
        pole2pole_data{sample,1} = Pil_type;
        pole2pole_data{sample,2} = date;
        pole2pole_data{sample,3} = interval;    
        pole2pole_data{sample,4} = pole2pole_data{sample,4} + sum(pole2pole_folder(:,2)); % number of frames tracked, sum over all cell tracks
        pole2pole_data{sample,5} = pole2pole_data{sample,5} + sum(pole2pole_folder(:,3)); % number of pole2pole switches, sum over all cell tracks
        if isnan(pole2pole_folder(:,4))
            pole2pole_data{sample,7} = pole2pole_data{sample,7}; % if there's no tracks, leaves entry as it is
        else
            pole2pole_data{sample,7} = vertcat(pole2pole_data{sample,7},pole2pole_folder(:,4)); % concatenates all the cell track individual pole2pole switches
        end
        clear pole2pole_folder
    end
    if pole2pole_data{sample,4} == 0
        pole2pole_data{sample,6} = 0;
    else
        pole2pole_data{sample,6} = pole2pole_data{sample,5} / ((pole2pole_data{sample,4}*delta_t)/60); % number of pole2pole switches for this day (replicate) normalized by time in minute (i.e. X siwtches per min)
    end
    if isempty(pole2pole_data{sample,7})
        pole2pole_data{sample,8} = [];
    else
        pole2pole_data{sample,8} = median(pole2pole_data{sample,7}(:,1)); % mean of cell track individual pole2pole switches
    end
    
    pole2pole_data{sample,10} = size(find(pole2pole_data{sample,7}(:,1)==0),1) / size(pole2pole_data{sample,7}(:,1),1); % fraction of cell tracks with 0 pole2pole swichtes
end
%% Plot  Histogram of number of pole2pole switches for each cell track normalized by time in minute (i.e. X siwtches per min)

% generate correct X axis labels
max_value = 10;
% bin_size = 21;
% bins = linspace(0,max_value,bin_size);
bins = [0 0.1 linspace(1,10,10)];
bin_size = size(bins,2);
bin_labels = cell(1,bin_size-1);
for i = 1:bin_size-1
    bin_labels{i} = strcat(num2str(bins(i))," - ",num2str(bins(i+1)));
end
figure('units','normalized','outerposition',[0 0 1 1])

%% 463
% collect data
data_10min = [];
data_60min = [];
for sample = 1:2:6 % quite bad way of adressing the data! too lazy so far to change...
    data_10min = [data_10min;pole2pole_data{sample,7}(:,1)];
end
for sample = 2:2:6 % quite bad way of adressing the data! too lazy so far to change...
    data_60min = [data_60min;pole2pole_data{sample,7}(:,1)];
end

% Add average over all cell tracks to pole2pole_data
pole2pole_data{5,9} = median(data_10min); 
pole2pole_data{6,9} = median(data_60min); 

% plot histogram 10 min (normalized by sample size)

[N,edges]=histcounts(data_10min,bins);
total=sum(N);
normalizedN=N/total;
subplot(2,2,1)

bar(normalizedN,'g')
axis([0 bin_size 0 0.6])
title("463 - 10 min")
set(gca, 'XTickLabel',["",[bin_labels{1:end}]], 'Fontsize',10)
xticks([0:bin_size])
xtickangle(45)
xlabel("Number of bright pole switches per min (individual cell tracks, unfiltered, normalized)")
ylabel("Probability")

% plot histogram 60 min (normalized by sample size) 

[N,edges]=histcounts(data_60min,bins);
total=sum(N);
normalizedN=N/total;
subplot(2,2,2)
    
bar(normalizedN,'g')
axis([0 bin_size 0 0.6])
title("463 - 60 min")
set(gca, 'XTickLabel',["",[bin_labels{1:end}]], 'Fontsize',10)
xticks([0:bin_size])
xtickangle(45)
xlabel("Number of bright pole switches per min (individual cell tracks, unfiltered, normalized)")
ylabel("Probability")

%% 1044

% collect data

data_10min = [];
data_60min = [];
for sample = 7:2:12 % quite bad way of adressing the data! too lazy so far to change...
    data_10min = [data_10min;pole2pole_data{sample,7}(:,1)];
end
for sample = 8:2:12 % quite bad way of adressing the data! too lazy so far to change...
    data_60min = [data_60min;pole2pole_data{sample,7}(:,1)];
end

% Add average over all cell tracks to pole2pole_data
pole2pole_data{11,9} = median(data_10min); 
pole2pole_data{12,9} = median(data_60min); 

% plot histogram 10 min (normalized by sample size)

[N,edges]=histcounts(data_10min,bins);
total=sum(N);
normalizedN=N/total;
subplot(2,2,3)

bar(normalizedN)
axis([0 bin_size 0 0.6])
title("1044 - 10 min")
set(gca, 'XTickLabel',["",[bin_labels{1:end}]], 'Fontsize',10)
xticks([0:bin_size])
xtickangle(45)
xlabel("Number of bright pole switches per min (individual cell tracks, unfiltered, normalized)")
ylabel("Probability")

% plot histogram 60 min (normalized by sample size)

[N,edges]=histcounts(data_60min,bins);
total=sum(N);
normalizedN=N/total;
subplot(2,2,4)

bar(normalizedN)
axis([0 bin_size 0 0.6])
title("1044 - 60 min")
set(gca, 'XTickLabel',["",[bin_labels{1:end}]], 'Fontsize',10)
xticks([0:bin_size])
xtickangle(45)
xlabel("Number of bright pole switches per min (individual cell tracks, unfiltered, normalized)")
ylabel("Probability")

%% Plot Fraction of 0 switches per min

xlabels = ["463 - 10 min" "463 - 60 min" "1044 - 10 min" "1044 - 60 min",];
figure('units','normalized','outerposition',[0 0 1 1])
hold on

% 463 10 min
collect_mean = [];
for sample = 1:2:6
    what2plot = (1-pole2pole_data{sample,10})*100;
    collect_mean = [collect_mean;what2plot];
    plot(1,what2plot,'g o','MarkerSize',10, 'Linewidth',2);
end
plot([0.9 1.1], [mean(collect_mean(:,1)) mean(collect_mean(:,1))], 'r -', 'Linewidth',2);

% 463 60 min
collect_mean = [];
for sample = 2:2:6
    what2plot = (1-pole2pole_data{sample,10})*100;
    collect_mean = [collect_mean;what2plot];
    plot(2,what2plot,'g o','MarkerSize',10, 'Linewidth',2);
end
plot([1.9 2.1], [mean(collect_mean(:,1)) mean(collect_mean(:,1))], 'r -', 'Linewidth',2);

% 1044 10 min
collect_mean = [];
for sample = 7:2:12
    what2plot = (1-pole2pole_data{sample,10})*100;
    collect_mean = [collect_mean;what2plot];
    plot(3,what2plot,'b o','MarkerSize',10, 'Linewidth',2);
end
plot([2.9 3.1], [mean(collect_mean(:,1)) mean(collect_mean(:,1))], 'r -', 'Linewidth',2);

% 1044 60 min
collect_mean = [];
for sample = 8:2:12
    what2plot = (1-pole2pole_data{sample,10})*100;
    collect_mean = [collect_mean;what2plot];
    plot(4,what2plot,'b o','MarkerSize',10, 'Linewidth',2);
end
plot([3.9 4.1], [mean(collect_mean(:,1)) mean(collect_mean(:,1))], 'r -', 'Linewidth',2);

axis([0 5 0 100])
set(gca, 'XTickLabel',["",xlabels,""], 'Fontsize',10)
xticks([0:5])
xtickangle(45)
ylabel("Fraction of cells with bright pole switches (%)")