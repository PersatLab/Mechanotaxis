%% draw  reversals phase contrast
clear all
close all
clc;

%% Paths
directory= pwd;
%addpath(strcat(directory,'Functions')); % for general functions
savefolder=strcat(directory, '\Reversal_dynamics\');
addpath(savefolder);
Data=import_reversal_dynamics('Combined_reversals_fluorescence_FimX_PilG.csv');
BootN=100;
CircleSize=20;
Shift=0.05;
figure
Strains=unique(Data.Strain);
strain_idx={};
color=[250, 175, 64 ; 0, 166, 156]./256;
for s=1:length(Strains)
    strain_idx{s} = find(Data.Strain==Strains(s));
    tau_s=Data.Taus(strain_idx{s});
    boot_mean(:,s)=bootstrp(BootN, @(x) mean(x),  tau_s);
    X=(s/2+Shift -(s/2-Shift)).*rand(length(tau_s),1)+ (s/2-Shift);
    scatter(tau_s,X,CircleSize,color(s,:));
    ylim([0 1.5]);
    hold on;
    boot_mean_mean=mean(boot_mean(:,s));
    CI = ci_percentile(boot_mean(:,s));
    plot([boot_mean_mean boot_mean_mean],[s/2-Shift s/2+Shift],'k', 'LineWidth', 3);
    plot(CI,[s/2 s/2],'k', 'LineWidth', 3);
end
title('Figure S13');
yticks([0.5 1])
yticklabels({'FimX','PilG'})
xlabel('Reversal delay time Tau (s)');
disp(flip(mean(boot_mean)));