% AUTOMATISATION de l'analyse avec BAcStalk
%% BackStalk
function []=BacStalk_automated(adresse,time,mean_cell_size,min_cell_size,delta_x,search_radius,dilation_width)%directory,Pil_type,date,interval,Pil_nbr)
% for Pil_nbr=10:1:14
%% Modify
% directory='X:\Iscia_WS\PersatLAb-master\';
% Pil_type='H-U';
% dates={'160720'};%;'160720';'210720';'210720';'230720';'230720'}; % if more: {'XX';'YY'} 
% intervals={'2s interval-1h'};%;'2s interval-2h';'2s interval-1h';'2s interval-2h';'2s interval-1h';'2s interval-2h'}; % if more: {'XX';'YY'}, !!same order as date !!
% 
% for d=1:1:size(dates,1)
% date=dates{d};
% interval=intervals{d};

%adresse1=strcat(directory,'Pil',Pil_type,'\',date,'\',interval);
 %   addpath(adresse1);
    
   %num_folders=length(dir(adresse1))-3
   %for folder=1:1:1%num_folders
%         Pil_nbr
%         %% Step 1:Load data
%         date
%         adresse=strcat(directory,'Pil',Pil_type,'\',date,'\',interval,'\',num2str(Pil_nbr));
%         addpath(adresse) % for the folder   
        filename=cell(1,time);
        for t=1:1:time
        filename{t}=char(strcat('C0-data_t',sprintfc('%03d',t-1),'.tif'));
        end

        % start
        BacStalk(mean_cell_size,min_cell_size,delta_x,search_radius,dilation_width)

        % lets add the files
        BacStalk_data = getUIData(gcf);
        addFiles(BacStalk_data,[],filename,adresse)

        % update channel 1
        BacStalk_data = getUIData(gcf);
        updateFileList(BacStalk_data,[])

        % Apply no Stalks
        BacStalk_data = getUIData(gcf);
        applyPreSettings(BacStalk_data,[],'stalks');

        %% Step 2:
        %Not NEEDED
        BacStalk_data = getUIData(gcf);
        showCellDetectionTab(BacStalk_data,[])

        %lets process all images
        BacStalk_data = getUIData(gcf);
        processImages(BacStalk_data,[],'all')

        % let's trak all the cells
        BacStalk_data = getUIData(gcf);
        trackCells(BacStalk_data,[])

        %% Step 3:
        % let's save the data
        %NOT NEEDED
        BacStalk_data = getUIData(gcf);
        showAnalysisTab(BacStalk_data,[]);

        % save data
        BacStalk_data = getUIData(gcf);
        saveData(BacStalk_data,[],adresse);

        %% close BacStalk
        BacStalk_data = getUIData(gcf);
        closeFigure(BacStalk_data,[]);
        
        %rmpath(adresse)
   %end
  % rmpath(adresse1)
end
%end
