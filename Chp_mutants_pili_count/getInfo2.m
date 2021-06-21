function [ Summary] = getInfo(  Workbook, Sheet, Startrow, Endrow, PixelSize, FrameTime)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    % Load Data
    [~,~,biologicalreplicate,cell,pili,cellposition,Hops,framestart,framestop,piluslength] = importfileChpData2(Workbook, Sheet, Startrow, Endrow);
    StrainNb=1;
    Summary(StrainNb).Strain=Sheet;
    Summary(StrainNb).CellsDataHeader={'IndCells' 'PiliPerCells' 'RetPerCells' 'RetPerPili' 'CellTimes' 'RetFreq' };
    EndIndex=Endrow-Startrow+1;
    
    % Get Indexes of Biological replicates
    NbBioRep=length(unique(biologicalreplicate));
    for i=1:NbBioRep
        IndBioRep(i).indexes=find(biologicalreplicate==i);
    end
    Summary(StrainNb).BioRep=NbBioRep;
    Summary(StrainNb).IndBioRep=IndBioRep;
    
    % Get Number of cells for each biological replicate
    NbCellsPerBioRep=zeros(NbBioRep,1);
    if(NbBioRep<2)
        NbCellsPerBioRep=length(unique(cell));
    else
        for i=1:NbBioRep
            NbCellsPerBioRep(i)=length(unique(cell(IndBioRep(i).indexes)));
        end
    end
    Summary(StrainNb).CellsPerBioRep=NbCellsPerBioRep;
    
    % Get the index of the cells
    for br=1:NbBioRep
        BR=char(strcat('BR',num2str(br)));
        cell_list=unique(cell(IndBioRep(br).indexes));
        for i=1:NbCellsPerBioRep(br)
            Summary(StrainNb).Stats.(BR).IndCells(i)=find(cell==cell_list(i), 1 );
        end
        % Compute pili lengths
        PiliLengths=piluslength*PixelSize;
        Summary(StrainNb).Stats.(BR).PiliLengths=PiliLengths(IndBioRep(br).indexes);

        % Get number of pili per cell
        PiliPerCell=pili(Summary(StrainNb).Stats.(BR).IndCells);
        % Compute the time of analysis for each cell
        CellTimes = (framestop(Summary(StrainNb).Stats.(BR).IndCells) - framestart(Summary(StrainNb).Stats.(BR).IndCells))*FrameTime;
        

        [ ExtFreq, RetPerCell, CellsWOpili, IndCellsWOpili ] = getRetFreq3(Summary(StrainNb).Stats.(BR).PiliLengths, cell(IndBioRep(br).indexes), cell_list, CellTimes ,PiliPerCell);
        %Compute Retraction per pili
        %RetPerPiliPerTime= RetPerCell./PiliPerCell./CellTimes;
        RetPerPiliPerTime= RetPerCell./CellTimes; %This is to know the retraction freuqency

        Summary(StrainNb).Stats.(BR).CellsData=[transpose(Summary(StrainNb).Stats.(BR).IndCells) PiliPerCell RetPerCell RetPerPiliPerTime CellTimes ExtFreq];
        Summary(StrainNb).Stats.(BR).CellsWOpili=CellsWOpili;
        Summary(StrainNb).Stats.(BR).IndCellsWOpili=IndCellsWOpili;
    end
    
    
    
    
end

