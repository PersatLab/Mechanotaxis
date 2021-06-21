% This scrips plots the alignement factors saved in alignement_data.mat

clear all
close all

directory='directory\';

%% MODIFY:
PilB_mNG=1; mNG_PilT=1; mNG_PilU=1;
mNG_PilG=1; mNG_PilH=1; mNG_FimX=1;

Pil_type=[mNG_FimX, PilB_mNG, mNG_PilT, mNG_PilU, mNG_PilG, mNG_PilH];

%% load variables
load('alignment_data.mat') % loads analysis file that was done with script "save_alignment_data.m"

%% load functions
addpath(strcat(directory,'Functions')); 
addpath(directory);

%% Graph
index=find(Pil_type==1);
nbr_collumn=sum(Pil_type);
colour = ["b o","m o","g o","r o"];

figure('units','normalized','outerposition',[0 0 1 1])

for i=1:1:nbr_collumn
     type=index(1,i);
     data=align_counts{type,2};
     num_day=unique(data(:,1));
     mean_day=zeros(size(num_day,1),1);
     for day=1:1:size(num_day,1)
        indice=find(data(:,1)==num_day(day));
        mean_day(day,1)=(sum(data(indice,3))/sum(data(indice,4)))*100;
        tracks_total_day = sum(align_counts{type, 2}(indice,4));
        
        hold on
        plot(type,mean_day(day,1),colour(day),'MarkerSize',10, 'Linewidth',1.5);
        text(type+0.2,mean_day(day,1),num2str(tracks_total_day));
     end
     total_mean=mean(mean_day(:,1));
     hold on 
     plot([type-0.1 type+0.1], [total_mean total_mean], 'k-','Linewidth',2);    
end
set(gca, 'XTickLabel',{'',align_counts{:,1}},'Fontsize',15,'TickLabelInterpreter','none')
ylabel('Fraction of cells with Alignment > 0 (%)')
title('Moving Asymmetric Cells');
axis([0 nbr_collumn+1 0 100])
xticks([0:1:nbr_collumn+1])
xtickangle(15)

%% Histogram of all Alignment factors

index=find(Pil_type==1);
nbr_collumn=sum(Pil_type);
leg = [];

% figure('units','normalized','outerposition',[0 0 1 1])
% hold on

for i=1:1:nbr_collumn
    figure('units','normalized','outerposition',[0 0 1 1])
    type=index(1,i);
    data=align_counts{type,3};

    histogram(data,20,'Normalization','probability');
    axis([-1.2 1.2 0 1])
    title("Histogram of Alignment Factors of Asymmetric Moving Cells",'FontSize',15);
    xlabel('Alignment factor','FontSize',15)
    ylabel('Probability','FontSize',15)
    legend(align_counts{type, 1},'FontSize',15,'Interpreter','none','Location','northwest')
%     leg = [leg, align_counts{type, 1}];

end
% legend(leg,'FontSize',15,'Interpreter','none','Location','northwest')

