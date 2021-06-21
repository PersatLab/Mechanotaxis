%% Plot  reversal frequency of single twitching cells (phase contrast only)
clear all
close all
%% load data
load('reversals_data.mat');

%% To modify:
title_graph='Time on surface=2 h   Min frames in same direction before and after reversal=2';

y_revs = 42;

%% needed info from loaded data
num_data=size(reversals_results,1);
num_strains=num_data/3; % for 3 replicates ONLY if same # of days for every strain
%% Graph: Number of directional changes per tracked time
figure('units','normalized','outerposition',[0 0 1 1])
x=0;
strain_list=[];

for n=1:3:num_data
    x=x+1;
    mean_pile=[];
    strain_list=[strain_list,split(reversals_results{n,1},'|')];
    
    r1=sum(reversals_results{n, 2}(:,3)); % # of all reversals on day 1
    r2=sum(reversals_results{n+1, 2}(:,3)); % # of all reversals on day 2
    r3=sum(reversals_results{n+2, 2}(:,3)); % # of all reversals on day 3
    j1=sum(reversals_results{n, 2}(:,4)); % # of all jiggles on day 1
    j2=sum(reversals_results{n+1, 2}(:,4)); % # of all jiggles on day 2
    j3=sum(reversals_results{n+2, 2}(:,4)); % # of all jiggles on day 3
    t1=sum(reversals_results{n,2}(:,2))/3600; % #tracking time in hours for day 1
    t2=sum(reversals_results{n+1,2}(:,2))/3600; % #tracking time in hours for day 2
    t3=sum(reversals_results{n+2,2}(:,2))/3600; % #tracking time in hours for day 3
    
    r=[r1,r2,r3];
    j=[j1,j2,j3];
    t=[t1,t2,t3];
    num_days=length(r);
    
    colour={'b x';'m x';'g x'};
    
    for d=1:1:num_days
        if t~=0
            hold on
            plot(x,(r(d)+j(d))/t(d),colour{d},'Linewidth',2) % plots combined reversal + jiggle frequency per h
            mean_pile=[mean_pile,(r(d)+j(d))/t(d)];
        end
    end
       
    avg=mean(mean_pile);
    plot([x-0.1 x+0.1],[avg avg],'k-','Linewidth',2)
end
title(title_graph)
xticks([0:1:num_strains+1])
ylim([0 y_revs]);
set(gca, 'XTickLabel',{' ',strain_list{1,1:1:num_strains}}, 'Fontsize',15)
xtickangle(15)
ylabel('# Directional changes / tracking time [1/h]')