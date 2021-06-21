% Plots graphs for asymmetric and symmetric distribution
% OUTPUT = 3 different graph with the distribution of symm and asymm cells 
         % 1 graph for moving cells
         % 1 graph for non moving cells
         % 1 graph for all the cells
         % coloured circles correspond to data from same days.
         % numbers of tracks are displayed next to circles (unfortunately overlayed when circles too close)
         
         
clear all
close all

%% MODIFY:
PilB_mNG=1; mNG_PilT=1; mNG_PilU=1;
mNG_PilG=1; mNG_PilH=1; mNG_FimX=1;

Pil_type=[PilB_mNG, mNG_PilT, mNG_PilU, mNG_PilG, mNG_PilH, mNG_FimX,]; 

%% Variables:
load('asymmetry_data.mat')

%% Graph Moving cells
index=find(Pil_type==1);
nbr_collumn=sum(Pil_type);
colour = ["b o","m o","g o","r o"];

figure('units','normalized','outerposition',[0 0 1 1])

subplot(1,3,1)
for i=1:1:nbr_collumn
      type=index(1,i);
      data=moving_distribution{type,2};
      num_day=unique(data(:,1));
      mean_day=zeros(size(num_day,1),1);
      for day=1:1:size(num_day,1)
        indice=find(data(:,1)==num_day(day));
        mean_day(day,1)=(sum(data(indice,3))/sum(data(indice,4)))*100;
        tracks_total_day = sum(moving_distribution{type, 2}(indice,4));
        
        hold on
        plot(type,mean_day(day,1),colour(day),'MarkerSize',6, 'Linewidth',1.5);
        text(type+0.2,mean_day(day,1),num2str(tracks_total_day));
      end  
      total_mean=mean(mean_day(:,1));
      hold on 
      plot([type-0.1 type+0.1], [total_mean total_mean], 'k-','Linewidth',2);            
end   
set(gca, 'XTickLabel',{'',moving_distribution{:,1}}, 'Fontsize',15, 'TickLabelInterpreter','none')
ylabel('Fraction of asymmetric cell [%]')
title('Moving cells');
axis([0 nbr_collumn+1 0 100])
xticks([0:1:nbr_collumn])
xtickangle(15)

%% Graph non-moving cells
subplot(1,3,2)
for i=1:1:nbr_collumn
      type=index(1,i);
      data=non_moving_distribution{type,2};
      num_day=unique(data(:,1));
       mean_day=zeros(size(num_day,1),1);
      for day=1:1:size(num_day,1)
        indice=find(data(:,1)==num_day(day));
        mean_day(day,1)=(sum(data(indice,3))/sum(data(indice,4)))*100;
        tracks_total_day = sum(non_moving_distribution{type, 2}(indice,4));
        
        hold on
        plot(type,mean_day(day,1),colour(day),'MarkerSize', 6, 'Linewidth',1.5);
        text(type+0.2,mean_day(day,1),num2str(tracks_total_day));
      end  
      total_mean=mean(mean_day(:,1));
      hold on 
      plot([type-0.1 type+0.1], [total_mean total_mean], 'k-','Linewidth',2);            
end   
set(gca, 'XTickLabel',{'',moving_distribution{:,1}}, 'Fontsize',15, 'TickLabelInterpreter','none')
ylabel('Fraction of asymmetric cell [%]')
title('Non Moving cells');
axis([0 nbr_collumn+1 0 100])
xticks([0:1:nbr_collumn])
xtickangle(15)

%% Graph all cells
subplot(1,3,3)
for i=1:1:nbr_collumn
    type=index(1,i);
      data1=moving_distribution{type,2};
      data2=non_moving_distribution{type,2};
      num_day=unique(data1(:,1));
      mean_day=zeros(size(num_day,1),1);
      for day=1:1:size(num_day,1)
        indice1=find(data1(:,1)==num_day(day));
        mean_day(day,1)=(sum(data1(indice1,3)+data2(indice1,3))/sum(data1(indice1,4)+data2(indice1,4)))*100;
        tracks_total_day = sum(moving_distribution{type, 2}(indice1,4)) + sum(non_moving_distribution{type, 2}(indice1,4));
        
        hold on
        plot(type,mean_day(day,1),colour(day),'MarkerSize', 6, 'Linewidth',1.5);
        text(type+0.2,mean_day(day,1),num2str(tracks_total_day));
      end  
      total_mean=mean(mean_day(:,1));
      hold on 
      plot([type-0.1 type+0.1], [total_mean total_mean], 'k-','Linewidth',2);
end   
set(gca, 'XTickLabel',{moving_distribution{:,1}}, 'Fontsize',15, 'TickLabelInterpreter','none')
ylabel('Fraction of asymmetric cell [%]')
title('All cells');
axis([0 nbr_collumn+1 0 100])
xticks([1:1:nbr_collumn])
xtickangle(15)
