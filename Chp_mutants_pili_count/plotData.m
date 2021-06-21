function [ BootSummary ] = plotData( DataSummary, FieldIN, Indexes, BootFields, BootFieldIndex, BootN, Shift, Title, YLabel, Legends, Method, CircleSize, Colors )
%plotData( DataSummary, FieldIN, Indexes, BootFields, BootFieldIndex,
%BootN, Shift, Title, YLabel, Legends, Method, CircleSize, Colors ) plots
%and compute statistics on the data input as DataSummary.
%DataSummary: a structure containing all the data from each strain,
%FieldIN: The Structure field of the data of interest,
%Indexes: Index of the rows and columns of the data of interest,
%BootFields: field names for %the output structure BootSummary,
%BootFieldIndex: index of the bootsrtap field to include in the output,
%BootN: Number of Bootstrap replicates,
%Shift: jitter width for plotting the individual data points,
%Title: Title of the graph,
%Ylabel: lable of the value of interest on the y axis,
%Legends: Name of the strain of interest,
%Method: takes 'Distribution' if we want mean and std or 'Bootstrap' for
%boostrap meadian and confidence intervals,
%CircleSize: size of the circles for individual datapoints,
%Colors: list of colors to use according to the strain.

%   Detailed explanation goes here
    NBStrains=length(DataSummary);
    maxylim=0;
    for i=1:NBStrains
        BRfields=fieldnames(DataSummary(i).Stats);
        if(length(BRfields)~=1)
            pos=linspace(-Shift*2, Shift*2, length(BRfields));
        else
            pos=0;
        end
        for br=1:length(BRfields)
            Finput=fieldnames(DataSummary(i).Stats.(char(BRfields(br))));
            F_ind=find(strcmp(Finput,FieldIN));
            BootstrapDataSet=zeros(BootN,NBStrains);
            MeanData=zeros(NBStrains,1);
            STDData=zeros(NBStrains,1);
        
            BootSummary(i).Strain=DataSummary(i).Strain;
            ExtractedField=DataSummary(i).Stats.(char(BRfields(br))).(Finput{F_ind});
            ShortenDataSet=ExtractedField(Indexes{:}); %Get the data of interest (look at CellDataHeader)
            IndNaN = isnan(ShortenDataSet);
            ShortenDataSet(IndNaN)=[]; %Remove nan values
            if (not(strcmp(Method,'Distribution')))
                %Computation of the bootstrap dataset of resampled medians
                if (length(ShortenDataSet)<2)
                    if(length(ShortenDataSet)==1)
                        BootstrapDataSet(:,i)=ShortenDataSet;
                    else
                        BootstrapDataSet(:,i)=0;
                    end
                else
                    BootstrapDataSet(:,i)=bootstrp(BootN, @(x) median(x),  ShortenDataSet);
                end
                BootSummary(i).Stats.(char(BRfields(br))).(BootFields{BootFieldIndex(1)})=BootstrapDataSet(:,i);
            else
                %Computation of the mean and standard deviation of the dataset
                if (length(ShortenDataSet)<1)
                    ShortenDataSet=0;
                end
                MeanData(i)=median(ShortenDataSet);
                STDData(i)=std(ShortenDataSet);
            end
            if (max(ShortenDataSet)>maxylim)
                maxylim=max(ShortenDataSet);
            end
            %BootSummary(i).Stats.(char(BRfields(br))).(BootFields{BootFieldIndex(1)})=BootstrapDataSet(:,i);
            X=((NBStrains+1-i)+Shift -((NBStrains+1-i)-Shift)).*rand(length(ShortenDataSet),1)+ ((NBStrains+1-i)-Shift);
            scatter(ShortenDataSet,X,CircleSize,Colors{i});
            %scatter(X,ShortenDataSet,CircleSize,[0.7 0.7 0.7]);
            hold on;
        
            title(strcat(Title, ' -   ', Method));
            xlabel(YLabel);
            %legend(Legends);
            BootstrapMed=zeros(NBStrains,1);
            BootstrapCI=zeros(NBStrains,2);
            if (not(strcmp(Method,'Distribution')))
                
                    BootstrapMed(i)=median(BootstrapDataSet(:,i));
                    BootSummary(i).Stats.(char(BRfields(br))).(BootFields{BootFieldIndex(2)})=BootstrapMed(i);
                    BootstrapCI(i,:)=ci_percentile(BootstrapDataSet(:,i));
                    BootSummary(i).Stats.(char(BRfields(br))).(BootFields{BootFieldIndex(3)})=BootstrapCI(i,:);
                    %plot([i+br/7 i+br/7],BootstrapCI(i,:), 'k', 'LineWidth',2);
                    %plot([i+pos(br) i+pos(br)],BootstrapCI(i,:), 'Color',Colors{br} , 'LineWidth',2);
                    %plot(i,BootstrapMed(i), 'Color',Colors{i} , 'Marker', 'O', 'MarkerSize', 9, 'LineWidth',2);
                    %plot(i+pos(br),BootstrapMed(i), 'Color',Colors{br} , 'Marker', 'O', 'MarkerSize', 9, 'LineWidth',2);
            else

                    BootstrapMed(i)=MeanData(i);
                    BootSummary(i).Stats.(char(BRfields(br))).(BootFields{BootFieldIndex(2)})=BootstrapMed(i);
                    BootstrapCI(i,:)=[(MeanData(i)-STDData(i)) (MeanData(i)+STDData(i))];
                    BootSummary(i).Stats.(char(BRfields(br))).(BootFields{BootFieldIndex(3)})=BootstrapCI(i,:);
                    %plot([i+pos(br) i+pos(br)],BootstrapCI(i,:), 'Color',Colors{br}, 'LineWidth',2);
                    %plot(i+pos(br),BootstrapMed(i), 'kO','MarkerFace', 'w', 'MarkerSize', 9, 'LineWidth',2);
            end
            yticks(1:NBStrains);
            yticklabels(flip(Legends));
            ytickangle(0);
            ylim([0 (NBStrains+1)]);
            set(gca,'TickLabelInterpreter','none')
        end
        means=zeros(length(BRfields),1);
        for br_i=1:length(BRfields)
            means(br_i)=BootSummary(i).Stats.(char(BRfields(br_i))).(BootFields{BootFieldIndex(2)});
        end
        if (not(strcmp(Method,'Distribution')))
            if (length(BRfields)>1)
                bootmeans=bootstrp(BootN, @(y) median(y),  means);
            else
                bootmeans=means;
            end
            bootmeans_CI=ci_percentile(bootmeans);
            plot(ones(2,1)*median(bootmeans), [(NBStrains+1-i)-0.4, (NBStrains+1-i)+0.4], 'k', 'LineWidth',3);
            plot( bootmeans_CI,ones(2,1)*(NBStrains+1-i), 'k', 'LineWidth',3);
        else
            plot(ones(2,1)*median(means),[(NBStrains+1-i)-0.4, (NBStrains+1-i)+0.4] , 'k', 'LineWidth',3);
            plot([median(means)-std(means), median(means)+std(means)],ones(2,1)*(NBStrains+1-i) , 'k', 'LineWidth',3);
        end
    end
    xlim([0 maxylim*1.05]);
end

