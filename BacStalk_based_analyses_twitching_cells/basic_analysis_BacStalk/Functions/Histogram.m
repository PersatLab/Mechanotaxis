function [results,median_bact,mean_bact] = Histogram(nbr_bact,Data_alignment)

%% for every cell I look when alignement is zero: zero values are not considered
for nbr=1:1:nbr_bact
indice=Data_alignment{nbr,3}==0;
Data_alignment{nbr,3}(indice)=[];

indice=isnan(Data_alignment{nbr,3});
Data_alignment{nbr,3}(indice)=[];
end

%% now the values are ordered to create the histogram
results=[];
median_bact=zeros(nbr_bact,1);
mean_bact=zeros(nbr_bact,1);
for nbr=1:1:nbr_bact
    results=[results; Data_alignment{nbr,3}];
    median_bact(nbr)=median(Data_alignment{nbr,3});
    mean_bact(nbr)=mean(Data_alignment{nbr,3});   
end
end

