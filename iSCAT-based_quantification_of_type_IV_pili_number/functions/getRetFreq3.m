function [ ExtFreq, RetPerCell, CellsWOpili, IndCellsWOret] = getRetFreq3(PiliLengths, Cells, Cell_list, CellTimes ,PiliPerCell)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
IndCellsWOret=find(isnan(PiliLengths));
CellsWOret=Cells(IndCellsWOret);
IndCellsWOpili=find(PiliPerCell==0);
CellsWOpili=length(IndCellsWOpili);
RetPerCell=zeros(length(Cell_list),1);
for i=1:length(RetPerCell)
    if(~isempty(CellsWOret))
        if(find(CellsWOret==Cell_list(i)))
            RetPerCell(i)=NaN;
        else
            RetPerCell(i)=length(find(Cells==Cell_list(i)));
        end
    else
        RetPerCell(i)=length(find(Cells==Cell_list(i)));
    end
end


ExtFreq=PiliPerCell./CellTimes;

end

