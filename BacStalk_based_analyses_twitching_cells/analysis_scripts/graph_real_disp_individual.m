%% Plots direction-corrected displacement as spatiotemporal displacement maps

% also adds column 4 to real_displacement_results.mat
    % 1: Pil_type
    % 2: date
    % 3: cell with 4 columns of displacement and speed data
        % 1: bact_id (which really is the id of the track; one cell can have multiple track ids!
        % 2: length of track (in timepoints)
        % 3: direction-corrected displacement in µm (using non-speed-filtered displacement and rounded alignment factor of unitary speed and unitary cell direction vector)
    % 4 (new): number of tracks that meed the conditions set below (min and max tracked)

% only works if all listed strains were analysed with the save_real_displacement.m script

clear all
close all
%% Modify
directory='directory\'; % that's where all the folder for functions, saved analyses, ... are located

min_tracked = 31; % minimum frames that cell must be tracked to be considered
max_tracked = 61; % maximum frames that cell can be tracked to be considered, max possible = 61

desired_tracks = 200; % maximum number of tracks to plot. if less tracks in real_displacement_results, takes max available

%% Strains
fliC_=1; fliC_cyaB_=1; fliC_cpdA_=1; fliC_pilH_=1; fliC_cyaB_pilH_=1; PilG_cpdA_=1;

%% load variables and strain names
load('real_displacement_data.mat') % loads analysis file that was done with script "save_real_displacement_MJK.m"
do_strain=[fliC_,fliC_cyaB_,fliC_cpdA_,fliC_pilH_,fliC_cyaB_pilH_,PilG_cpdA_]; % here you create a vector that contains what is in the data just loaded
Pil_types=unique([real_displacement_results{:,1}]);

%% load functions
addpath(strcat(directory,'Functions')); 
addpath(directory);

%% graph:
index=find(do_strain==1);
nbr_column=sum(do_strain);
colour = ["k","r","b","g","c","m"];
leg=[];

%% Process data (filter for track time length, normaize by speed, ...)

for strain = 1:1:nbr_column
    
    type=Pil_types(index(strain));
    index_type=find([real_displacement_results{:,1}]==type);
    leg=[leg,Pil_types(index(strain))];   
    
    % delete rows that don't fit condition of min tracked time
    nbr_replicates = size(index_type,2);
    for rep = 1:1:nbr_replicates
        rows_del = [real_displacement_results{index_type(rep),3}{:,2}]<min_tracked;
        rows_del_max = [real_displacement_results{index_type(rep),3}{:,2}]>max_tracked;
        index_rows_delete = [find(rows_del==1),find(rows_del_max==1)];
        real_displacement_results{index_type(rep),3}(index_rows_delete,:)=[];
        real_displacement_results{index_type(rep),4} = size(real_displacement_results{index_type(rep),3},1);
    end    
end

%% Plot displacements

% figure('units','normalized','outerposition',[0 0 1 1])

p = 0;

for strain = 1:1:nbr_column
        
    type=Pil_types(index(strain));
    index_type=find([real_displacement_results{:,1}]==type);
    nbr_replicates = size(index_type,2);
    rep_ind = repmat([1:nbr_replicates],1,1000);
        
    tracks_total = sum([real_displacement_results{index_type,4}]);
    if tracks_total<desired_tracks
        max_tracks = tracks_total;
    elseif tracks_total>=desired_tracks
        max_tracks = desired_tracks;
    end
    
    p = p+1;
    figure('units','normalized','outerposition',[0 0 1 1])
    title(strcat("Range: ",num2str((min_tracked-1)*5),"-",num2str((max_tracked-1)*5),"s   ","Tracks: ",num2str(max_tracks)))
    axis([-45 75 0 150])
    hold on

    track_rep = [0,0,0];
    index_max_rep = find([real_displacement_results{index_type,4}]==max([real_displacement_results{index_type,4}]));
    
    for plot_nbr = 1:1:max_tracks   % plots the kumulative displacement for each strain in a separate plot
                                    % loops through replicates to plot equal number of tracks per replicate as long as there are enough tracks
                                    % otherwise continues loop over remaining replicates
                                    % label only appears in first plot unfortunately
                
        if rep_ind(plot_nbr)==1
            if track_rep(rep_ind(plot_nbr))<size(real_displacement_results{index_type(rep_ind(plot_nbr)),3},1)
                plotted_rep = rep_ind(plot_nbr);
                track_rep(rep_ind(plot_nbr)) = track_rep(rep_ind(plot_nbr))+1;
                
                max_time = real_displacement_results{index_type(rep_ind(plot_nbr)),3}{track_rep(rep_ind(plot_nbr)),2};
                y_values = 5*[0:max_time-1]'; 
                   
                disp_directional = [0:max_time-1]';
                for t = 2:1:max_time
                    disp_directional(t,1) = real_displacement_results{index_type(rep_ind(plot_nbr)),3}{track_rep(rep_ind(plot_nbr)),3}(t,1) + disp_directional(t-1,1);
                end

                plot(disp_directional,y_values,colour(index(strain)),'LineWidth',1)
                                
            elseif track_rep(rep_ind(plot_nbr+1))<size(real_displacement_results{index_type(rep_ind(plot_nbr+1)),3},1) & plotted_rep~=2
                plotted_rep = rep_ind(plot_nbr+1);
                track_rep(rep_ind(plot_nbr+1)) = track_rep(rep_ind(plot_nbr+1))+1;
                
                max_time = real_displacement_results{index_type(rep_ind(plot_nbr+1)),3}{track_rep(rep_ind(plot_nbr+1)),2};
                y_values = 5*[0:max_time-1]'; 
                   
                disp_directional = [0:max_time-1]';
                for t = 2:1:max_time
                    disp_directional(t,1) = real_displacement_results{index_type(rep_ind(plot_nbr+1)),3}{track_rep(rep_ind(plot_nbr+1)),3}(t,1) + disp_directional(t-1,1);
                end

                plot(disp_directional,y_values,colour(index(strain)),'LineWidth',1)
                               
            elseif track_rep(rep_ind(plot_nbr+2))<size(real_displacement_results{index_type(rep_ind(plot_nbr+2)),3},1) & plotted_rep~=3
                plotted_rep = rep_ind(plot_nbr+2);
                track_rep(rep_ind(plot_nbr+2)) = track_rep(rep_ind(plot_nbr+2))+1;
                
                max_time = real_displacement_results{index_type(rep_ind(plot_nbr+2)),3}{track_rep(rep_ind(plot_nbr+2)),2};
                y_values = 5*[0:max_time-1]'; 
                   
                disp_directional = [0:max_time-1]';
                for t = 2:1:max_time
                    disp_directional(t,1) = real_displacement_results{index_type(rep_ind(plot_nbr+2)),3}{track_rep(rep_ind(plot_nbr+2)),3}(t,1) + disp_directional(t-1,1);
                end

                plot(disp_directional,y_values,colour(index(strain)),'LineWidth',1)
                                
            else
                plotted_rep = rep_ind(index_max_rep);
                track_rep(rep_ind(index_max_rep)) = track_rep(rep_ind(index_max_rep))+1;
                
                max_time = real_displacement_results{index_type(rep_ind(index_max_rep)),3}{track_rep(rep_ind(index_max_rep)),2};
                y_values = 5*[0:max_time-1]'; 
                   
                disp_directional = [0:max_time-1]';
                for t = 2:1:max_time
                    disp_directional(t,1) = real_displacement_results{index_type(rep_ind(index_max_rep)),3}{track_rep(rep_ind(index_max_rep)),3}(t,1) + disp_directional(t-1,1);
                end

                plot(disp_directional,y_values,colour(index(strain)),'LineWidth',1)
            
            end
        end

        if rep_ind(plot_nbr)==2
                                            
            if track_rep(rep_ind(plot_nbr))<size(real_displacement_results{index_type(rep_ind(plot_nbr)),3},1) & plotted_rep~=2
                plotted_rep = rep_ind(plot_nbr);
                track_rep(rep_ind(plot_nbr)) = track_rep(rep_ind(plot_nbr))+1;
                
                max_time = real_displacement_results{index_type(rep_ind(plot_nbr)),3}{track_rep(rep_ind(plot_nbr)),2};
                y_values = 5*[0:max_time-1]'; 
                   
                disp_directional = [0:max_time-1]';
                for t = 2:1:max_time
                    disp_directional(t,1) = real_displacement_results{index_type(rep_ind(plot_nbr)),3}{track_rep(rep_ind(plot_nbr)),3}(t,1) + disp_directional(t-1,1);
                end

                plot(disp_directional,y_values,colour(index(strain)),'LineWidth',1)
                               
            elseif track_rep(rep_ind(plot_nbr+1))<size(real_displacement_results{index_type(rep_ind(plot_nbr+1)),3},1) & plotted_rep~=3
                plotted_rep = rep_ind(plot_nbr+1);
                track_rep(rep_ind(plot_nbr+1)) = track_rep(rep_ind(plot_nbr+1))+1;
                
                max_time = real_displacement_results{index_type(rep_ind(plot_nbr+1)),3}{track_rep(rep_ind(plot_nbr+1)),2};
                y_values = 5*[0:max_time-1]'; 
                   
                disp_directional = [0:max_time-1]';
                for t = 2:1:max_time
                    disp_directional(t,1) = real_displacement_results{index_type(rep_ind(plot_nbr+1)),3}{track_rep(rep_ind(plot_nbr+1)),3}(t,1) + disp_directional(t-1,1);
                end

                plot(disp_directional,y_values,colour(index(strain)),'LineWidth',1)
                                  
            elseif track_rep(rep_ind(plot_nbr-1))<size(real_displacement_results{index_type(rep_ind(plot_nbr-1)),3},1) & plotted_rep~=1
                plotted_rep = rep_ind(plot_nbr-1);
                track_rep(rep_ind(plot_nbr-1)) = track_rep(rep_ind(plot_nbr-1))+1;
                
                max_time = real_displacement_results{index_type(rep_ind(plot_nbr-1)),3}{track_rep(rep_ind(plot_nbr-1)),2};
                y_values = 5*[0:max_time-1]'; 
                   
                disp_directional = [0:max_time-1]';
                for t = 2:1:max_time
                    disp_directional(t,1) = real_displacement_results{index_type(rep_ind(plot_nbr-1)),3}{track_rep(rep_ind(plot_nbr-1)),3}(t,1) + disp_directional(t-1,1);
                end

                plot(disp_directional,y_values,colour(index(strain)),'LineWidth',1)
                
            else
                plotted_rep = rep_ind(index_max_rep);
                track_rep(rep_ind(index_max_rep)) = track_rep(rep_ind(index_max_rep))+1;
                
                max_time = real_displacement_results{index_type(rep_ind(index_max_rep)),3}{track_rep(rep_ind(index_max_rep)),2};
                y_values = 5*[0:max_time-1]'; 
                   
                disp_directional = [0:max_time-1]';
                for t = 2:1:max_time
                    disp_directional(t,1) = real_displacement_results{index_type(rep_ind(index_max_rep)),3}{track_rep(rep_ind(index_max_rep)),3}(t,1) + disp_directional(t-1,1);
                end

                plot(disp_directional,y_values,colour(index(strain)),'LineWidth',1)
            
            end
        end
        
        if rep_ind(plot_nbr)==3
                                            
            if track_rep(rep_ind(plot_nbr))<size(real_displacement_results{index_type(rep_ind(plot_nbr)),3},1) & plotted_rep~=3
                plotted_rep = rep_ind(plot_nbr);
                track_rep(rep_ind(plot_nbr)) = track_rep(rep_ind(plot_nbr))+1;
                
                max_time = real_displacement_results{index_type(rep_ind(plot_nbr)),3}{track_rep(rep_ind(plot_nbr)),2};
                y_values = 5*[0:max_time-1]'; 
                   
                disp_directional = [0:max_time-1]';
                for t = 2:1:max_time
                    disp_directional(t,1) = real_displacement_results{index_type(rep_ind(plot_nbr)),3}{track_rep(rep_ind(plot_nbr)),3}(t,1) + disp_directional(t-1,1);
                end

                plot(disp_directional,y_values,colour(index(strain)),'LineWidth',1)
                                  
            elseif track_rep(rep_ind(plot_nbr-2))<size(real_displacement_results{index_type(rep_ind(plot_nbr-2)),3},1) & plotted_rep~=1
                plotted_rep = rep_ind(plot_nbr-2);
                track_rep(rep_ind(plot_nbr-2)) = track_rep(rep_ind(plot_nbr-2))+1;
                
                max_time = real_displacement_results{index_type(rep_ind(plot_nbr-2)),3}{track_rep(rep_ind(plot_nbr-2)),2};
                y_values = 5*[0:max_time-1]'; 
                   
                disp_directional = [0:max_time-1]';
                for t = 2:1:max_time
                    disp_directional(t,1) = real_displacement_results{index_type(rep_ind(plot_nbr-2)),3}{track_rep(rep_ind(plot_nbr-2)),3}(t,1) + disp_directional(t-1,1);
                end

                plot(disp_directional,y_values,colour(index(strain)),'LineWidth',1)
                
            elseif track_rep(rep_ind(plot_nbr-1))<size(real_displacement_results{index_type(rep_ind(plot_nbr-1)),3},1) & plotted_rep~=2
                plotted_rep = rep_ind(plot_nbr-1);
                track_rep(rep_ind(plot_nbr-1)) = track_rep(rep_ind(plot_nbr-1))+1;
                
                max_time = real_displacement_results{index_type(rep_ind(plot_nbr-1)),3}{track_rep(rep_ind(plot_nbr-1)),2};
                y_values = 5*[0:max_time-1]'; 
                   
                disp_directional = [0:max_time-1]';
                for t = 2:1:max_time
                    disp_directional(t,1) = real_displacement_results{index_type(rep_ind(plot_nbr-1)),3}{track_rep(rep_ind(plot_nbr-1)),3}(t,1) + disp_directional(t-1,1);
                end

                plot(disp_directional,y_values,colour(index(strain)),'LineWidth',1)
                
            else
                plotted_rep = rep_ind(index_max_rep);
                track_rep(rep_ind(index_max_rep)) = track_rep(rep_ind(index_max_rep))+1;
                
                max_time = real_displacement_results{index_type(rep_ind(index_max_rep)),3}{track_rep(rep_ind(index_max_rep)),2};
                y_values = 5*[0:max_time-1]'; 
                   
                disp_directional = [0:max_time-1]';
                for t = 2:1:max_time
                    disp_directional(t,1) = real_displacement_results{index_type(rep_ind(index_max_rep)),3}{track_rep(rep_ind(index_max_rep)),3}(t,1) + disp_directional(t-1,1);
                end

                plot(disp_directional,y_values,colour(index(strain)),'LineWidth',1)
                                
            end
        end

    end
    dummy(strain)=plot(nan, nan, colour(index(strain)),'Linewidth',2);
end
legend(dummy,leg,'Fontsize',15)
ylabel('Time (s)')
xlabel('Displacement (µm)')
