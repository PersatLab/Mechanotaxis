%This script is to:
    %1. save the reversal frequency
    %2. calculate the number of reversals and jiggles (in the end, the separation didn't make so much sense, so we combined both again into directional changes in general)
    %3. save reversals_phase_contrast.mat to plot with graph_reversals_phase_contrast
    
% Main output variables: 
    %1. total_counts: MatLab-cell of 6 columns (cleared and filled again for each strain, not saved)
        %a. column1: bacteria ID
        %b. column2: matrix of 7 columns containing all the info of the cell reversals/jiggles phases
            % i) column 1: phase sign (1 if projection=1 in that movement phase or -1 if projection=-1 in that movement phase)
            % ii) column 2: number of time steps of that phase (counts+1)
            % iii) column 3: 1 if sign is different that previous phase, 0 otherwise
            % iv) column 4: 1 if current and previsous phase are longer than limit_counts (in time frames), 0 otherwise.
            % v) columns 5: 1 if  current and previsous phase are longer than limit_minimum (in time frames) AND if current or previsous phase are smaller than limit_counts
            % iv) column 6: column3 * column 4. If 1= reversal
            % vii) column 7: column 3* column 5. If 1= jiggle
        %c. column 3: total number of reversals for folder
        %d. column 4: total number of jiggling for folder
        %e. column 5: RMSD (not used in the end)
        %f. column 6: total count of reversals + jiggles
    %2. reversals_results is a cell of 3 columns, and number of lines depends on the number of strains (saved)
        %a. column 1: strain & date
        %b. column 2: matrix of 7 columns containing all info on reversals and jiggles
            % i) column 1: folder
            % ii) column 2: total tracking time (in s)
            % iii) column 3: total number of reversals
            % iv) column 4: total number of jiggles
            % v) columns 5: total number tracks with reversals or jiggles
            % iv) column 6: % total number of moving cells
            % vii) column 7: % total number of non moving cells
        %c. column 3: Root Mean Square Displacement data (not used in the end)
            % i) column1: folder
            % ii) column2: RMSD of reversing cells (not used in the end)
            % iii) column3: RMSD of moving NOT reversing cells (not used in the end)
    

clear all
close all

%% To modify:

directory='directory\';

% Select folders from xlsx file (Format of columns 1, 2, 3 must be Pil_types, dates, intervals, respectively (see Table "Sample Information"))
[num,txt,~]=xlsread(strcat(directory,'Input.xlsx')); % must be located in 'directory'
dates = num(:,1); % read as a column vector
Pil_types = txt(:,1); % read as a cell with one column
intervals = txt(:,3); % read as a cell with one column

limit_counts=5; % consecutive timepoint threshold to count as reversal or jiggle (depends on image time interval!) (reversals+jiggles were combined in the end into directional changes, because separating them didn't make sense after all)
limit_minimum=2; % consecutive timepoint threshold to count as significant directional change

projection_plot=0; % CAREFULL!!! Only use if one folder only! 1 if you want to plot all the projection graph of the reversing/jiggling cells

%% Variables
m=0;

for type=1:1:size(Pil_types,1)

    Pil_type=Pil_types{type}
    date=num2str(dates(type))
    interval=intervals{type}
    
    adresse1=strcat(directory,Pil_type,'\',date,'\',interval,'\');
    num_folder=length(dir(adresse1))-2;
    
    %% define variables
    RMSD_total=[];
    RMSD_reverse=[];
    m=m+1;

    %% Loop over folders
  for folder=1:1:num_folder
    %% Load variables and add path
    addpath(strcat(directory,'Functions'));
    adresse=strcat(adresse1,num2str(folder))
    addpath(adresse)
    load(strcat(adresse,'\variables.mat'),'cell_prop','BactID','Data_speed', 'BactID_non_moving')
    load(strcat(adresse,'\parameters.mat'),'delta_t');

    %% Step 1: Calculate reversals
    [reversal,RMSD_total_tmp]=get_reversals(cell_prop,BactID,Data_speed);
    RMSD_total=[RMSD_total,RMSD_total_tmp]; %% the RMSD off all cells, here RMSD_total contains all cells of 1 type.

    %% Step 2: Save reversals
    filename=strcat(adresse,'\variables.mat');
    save(filename,'reversal', '-append') % to add the reversal data in the 'variables.mat'

    %% Step 3: Count reversals and jiggles
     nbr_reversal=size(reversal,1);
     s=1;
     total_counts=cell(1,6);
    for i=1:1:nbr_reversal
      v_dot_x=reversal{i,2};
      time=size(v_dot_x,1);
      
      % filter projection to make it easier to see moving phases towards
      % initial leading pole or towards initial lagging pole
      for t=1:1:time
        v_dot_x(t)=round(v_dot_x(t)); % if 0.5<v_dot_x(t)<1 -> v_dot_x(t)=1. Easier to see in plot and does not influence the reversal/jiggle behaviour
        if v_dot_x(t)==0
             v_dot_x(t)=nan; % like this if v_dot_x(t)==0 it won't be counted and plotted
        end
      end
% counting starts here:
      counts=0;
      j=0;
      for t=2:1:time % from 2 because I compare to previous time 
        if sign(v_dot_x(t))==sign(v_dot_x(t-1)) % if 2 consecutive projection point have same sign -> add one count
             counts=counts+1;
        elseif ~isnan(sign(v_dot_x(t-1))) && counts>0 % else if we have a change of sign then save data into total_counts
              j=j+1;
              total_counts{i,1}=reversal{i,1};
              total_counts{i,2}(j,1)=sign(v_dot_x(t-1));
              total_counts{i,2}(j,2)=counts+1;
              counts=0;
        end 
        if t==time  % insert data of last phase
              j=j+1;
              total_counts{i,1}=reversal{i,1};
              total_counts{i,2}(j,1)=sign(v_dot_x(t-1));
              total_counts{i,2}(j,2)=counts+1;
              counts=0;
        end
      end
      n=[];
      for r=2:1:j % if 2 consecutive phase has same sign I combine them as 1 phase
        if total_counts{i,2}(r,1)==total_counts{i,2}(r-1,1)
              total_counts{i,2}(r,2)=total_counts{i,2}(r,2)+total_counts{i,2}(r-1,2); 
              n=[n,r-1];
        end
      end
      total_counts{i,2}(n,:)=[];
        
      if size(total_counts{i,2},1)>=2 % for cells that have at least 2 phases
        for r=2:1:size(total_counts{i,2},1) % starts from 2 because I check to previous phase
             total_counts{i,2}(r,3)=(total_counts{i,2}(r,1)*total_counts{i,2}(r-1,1)<0);   
             total_counts{i,2}(r,4)=(total_counts{i,2}(r,2)>=limit_counts)*(total_counts{i,2}(r-1,2)>=limit_counts);
             total_counts{i,2}(r,5)=(total_counts{i,2}(r,2)>=limit_minimum)*(total_counts{i,2}(r,2)<limit_counts || total_counts{i,2}(r-1,2)<limit_counts)*(total_counts{i,2}(r-1,2)>=limit_minimum);
        end
        total_counts{i,2}(:,6)=total_counts{i,2}(:,3).*total_counts{i,2}(:,4);
        total_counts{i,2}(:,7)=total_counts{i,2}(:,3).*total_counts{i,2}(:,5); 
            
        total_counts{i,3}=sum(total_counts{i,2}(:,6));
        total_counts{i,4}=sum(total_counts{i,2}(:,7));
        total_counts{i,5}=reversal{i,3};
        total_counts{i,6}=(total_counts{i,3}+total_counts{i,4})~=0;
     end
  %% --------------------PLOT---------------------------------------------------------------------    
        if projection_plot
            if ~isempty(total_counts{i,3})
                nbr=find(BactID(:,1)==total_counts{i,1});
                if s==1
                   figure 
                end
                subplot(3,1,s)
                plot(BactID(nbr,3):1:BactID(nbr,3)+BactID(nbr,2)-1,v_dot_x,'k x','Linewidth',1.5)
                set(gca,'ycolor','k','Fontsize',15) 
                ylabel('Projection','Fontsize',20)
                xlabel('time frame','Fontsize',20)
                title(strcat('Bacterium',num2str(total_counts{i,1})))
                xlim([BactID(nbr,3)-3 BactID(nbr,3)+BactID(nbr,2)+20])

                s=s+1;
                if s>3
                   s=1;
                end
            end
        end
 %--------------------------------------------------------------------------------------------------------
    end
    
    %% Step 4: delete all the cells that have less that 2 phases
    indice=[];
    for l=1:1:size(total_counts,1)
        if isempty(total_counts{l,3})
            indice=[indice,l];
        end
    end
    total_counts(indice,:)=[]; 
    %% Step 5: RMSD of reversing cells
    RMSD_reverse=[RMSD_reverse;cell2mat(total_counts(:,5))]; %vector containing RMSD of reversing cells


    %% Step 6: RMSD all non reversing cells
    RMSD_no_reverse=RMSD_total;
    indice=[];
    for i=1:1:size(total_counts,1)
        k=find(total_counts{i,1}==BactID(:,1));
        indice=[indice,k];
    end
    RMSD_no_reverse(indice)=[]; % delete from RMSD_no_reverse the values of the reversing cells
    %% Step 7: insert data corresponding to type into reversals_results. Which will contains all the types info
    reversals_results{m,1}=strcat(Pil_type,'|',num2str(date)); %name of type

    reversals_results{m,2}(folder,1)=folder;
    reversals_results{m,2}(folder,2)=sum(BactID(:,2))*delta_t; % total tracking time in seconds

    if ~isempty(total_counts)
        reversals_results{m,2}(folder,3)=sum([total_counts{:,3}]);  % total # of reversals of strain
        reversals_results{m,2}(folder,4)=sum([total_counts{:,4}]);  % total # of jiggles of strain
        reversals_results{m,2}(folder,5)=sum([total_counts{:,6}]);  % total num of cell reversing or jiggles
        reversals_results{m,2}(folder,6)=size(BactID,1);            % total # of moving cells
        reversals_results{m,2}(folder,7)=size(BactID_non_moving,1); % total # of non moving cells
    else
        reversals_results{m,2}(folder,3)=0;  % total # of reversals of strain
        reversals_results{m,2}(folder,4)=0;  % total # of jiggles of strain
        reversals_results{m,2}(folder,5)=0;      % total num of cell reversing or jiggles
        reversals_results{m,2}(folder,6)=size(BactID,1);            % total # of moving cells
        reversals_results{m,2}(folder,7)=size(BactID_non_moving,1); % total # of non moving cells  
    end
    
    reversals_results{m,3}{folder,1}=folder;
    reversals_results{m,3}{folder,2}=RMSD_reverse; % RMSD of reversing cells
    reversals_results{m,3}{folder,3}=RMSD_no_reverse'; % RMSD of moving and NOT reversing cells
%     rmpath(adresse1)
  end
    rmpath(adresse)
end
%%
save(strcat(directory,'Graphs\reversals_data.mat'),'reversals_results');