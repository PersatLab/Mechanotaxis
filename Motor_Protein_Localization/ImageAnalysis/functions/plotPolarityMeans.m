function [] = plotPolarityMeans(Title, YLable, Y_Limit, DataMarkerSize, Legends, Colors, varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
legends=Legends;
for i=1:length(varargin)
    hold on;
    j=(length(varargin)+1-i);
    legends(j)=Legends(i);
    x=ones(1,length(varargin{i}))*j;
    plot(varargin{i}, x, 'LineStyle','none', 'Marker', 'o', 'MarkerSize', DataMarkerSize, 'MarkerEdgeColor', Colors(i,:)/256)
    plot([mean(varargin{i}) mean(varargin{i})],[j-0.1 j+0.1], 'k', 'LineWidth', 2)
    plot([mean(varargin{i})-std(varargin{i}) mean(varargin{i})+std(varargin{i})],[j j], 'k', 'LineWidth', 2)
end


% ICPilB_high=[[mean(MeanRatPilBsol,0)-std(MeanRatPilBsol,0); mean(MeanRatPilBpilHliq,0)-std(MeanRatPilBpilHliq,0); mean(MeanRatPilBcpdAliq,0)-std(MeanRatPilBcpdAliq,0); mean(MeanRatPilBpilGcpdAliq,0)-std(MeanRatPilBpilGcpdAliq,0)] [mean(MeanRatPilBsol,0)+std(MeanRatPilBsol,0); mean(MeanRatPilBpilHliq,0)+std(MeanRatPilBpilHliq,0); mean(MeanRatPilBcpdAliq,0)+std(MeanRatPilBcpdAliq,0); mean(MeanRatPilBpilGcpdAliq,0)+std(MeanRatPilBpilGcpdAliq,0)]];
% for i=1:4
%     plot([i i],ICPilB_high(i,:), 'k', 'LineWidth',2);
% end

ylim([0,length(varargin)+1]);
xlim(Y_Limit);
yticks(1:length(varargin)+1);
yticklabels(legends);
%xtickangle(45);
title(Title);
xlabel(YLable);
end

