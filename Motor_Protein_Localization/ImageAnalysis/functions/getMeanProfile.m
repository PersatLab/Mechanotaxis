function [ Mean, Std, N, Profiles, FluoMean, CellWidth, CellLength, CellID] = getMeanProfile( Path, k, NbUpSamples, FieldName, Cell_Length )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    %% Loading data
    DataSet=load(Path);
    PixSize=str2double(DataSet.params.Scaling.String);
    
    %% Extracting Dataset information
    NbFrames=max(size(DataSet.frames));
    LenInPix= Cell_Length/PixSize;
    NbCells=zeros(NbFrames,1); NbCellsKept=zeros(NbFrames,1); totCells=0; totKeptCells=0;
    for i=1:NbFrames
        NbCells(i)=max(size(DataSet.frames(i).cells.Stats));
        n=zeros(NbCells(i),1);
        for j=1:NbCells(i)
            if ((~DataSet.frames(i).cells.Stats(j).CellDeleted) &&(DataSet.frames(i).cells.Stats(j).CellLength)< LenInPix)
                n(j)=0;
            else
                n(j)=1;
            end
        end
        NbCellsKept(i)=length(find(n==0));
        totCells=totCells+NbCells(i);
        totKeptCells=totKeptCells+NbCellsKept(i);

    end 

    %% Upsampling of intensity profiles
    Profiles=zeros(totKeptCells, NbUpSamples);
    FluoMean=zeros(totKeptCells, 1);
    CellWidth=zeros(totKeptCells, 1);
    CellLength=zeros(totKeptCells, 1);
    CellID=zeros(totKeptCells, 1);
    Area=zeros(totKeptCells, 1);
    TotalFluo=zeros(totKeptCells, 1);
    n=1;
    for h=1:NbFrames
        for i=1:NbCells(h)
            if((~DataSet.frames(h).cells.Stats(i).CellDeleted) && (DataSet.frames(h).cells.Stats(i).CellLength)< LenInPix)
                x=(0:length(DataSet.frames(h).cells.Stats(i).(FieldName))-1)/(length(DataSet.frames(h).cells.Stats(i).(FieldName))-1);
                y=DataSet.frames(h).cells.Stats(i).(FieldName);
                FluoMean(n)=DataSet.frames(h).cells.Stats(i).('MeanCellIntensity_mNeonGreen');
                CellWidth(n)=DataSet.frames(h).cells.Stats(i).('CellWidth');
                CellLength(n)=DataSet.frames(h).cells.Stats(i).('CellLength');
                CellID(n)=DataSet.frames(h).cells.Stats(i).('CellID');
                Area(n)=DataSet.frames(h).cells.Stats(i).('Area');
                TotalFluo(n)=FluoMean(n)*Area(n);
                index=find(y==max(y));
                if(index<=length(y)/2)
                    y=fliplr(y);
                end
                for j=1:NbUpSamples
                    Profiles(n,j)=interp1(x,y,k(j)); %interpolate values from original profile in order to get all the same number of values
                end
                temp=trapz(Profiles(n,:));
                Profiles(n,:)=Profiles(n,:)/temp;
                n=n+1;
            end
        end
    end

    Mean=mean(Profiles);
    Std=std(Profiles);
    N=totKeptCells;
end


