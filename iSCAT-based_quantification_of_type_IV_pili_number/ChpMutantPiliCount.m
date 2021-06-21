clear all; close all; clc;
tic;
%% Load Data
addpath('./data', './functions')
Workbook='Chp-cAMP_experiments_summary.xlsx';
Sheet={'fliC-_liq','fliC-_sol','cpdA-fliC-','pilH-fliC-', 'pilH-cyaB-fliC-', 'cyaB-fliC-', 'pilG-fliC-', 'pilG-cpdA-fliC-'}; 
%Colors={[0.4, 0.4, 0.4],[0.6, 0.6, 0.6],'r','r','r', 'r', [0.4, 0.4, 0.4],[0.6, 0.6, 0.6], 'g','b', 'g', 'g', 'g', [0.4, 0.0, 0.4], [0.4, 0.0, 0.4] };
Colors={[31, 119, 180]/256,[174, 199, 232]/256,[255, 187, 120]/256,[255, 127, 14]/256, [197, 176, 213]/256, [255, 152, 150]/256, [214, 39, 40]/256, [152, 223, 138]/256 };
Startrow=[2 2 2 2 2 2 2 2 2];
%       WTl WTs cA H   HcB cB  G  GcA
Endrow=[717 1031 528 2145 470 301 99 146];
PixelSize=0.0636; %�m
FrameTime=1/2.5; %s
NBStrains=length(Endrow);

CellsDataHeader={'IndCells' 'PiliPerCells' 'RetPerCells' 'RetFreq' 'CellTimes' 'ExtFreq' };
DataSummary=struct('Strain', {}, 'BioRep', {}, 'IndBioRep', {}, 'CellsPerBioRep', {}, 'CellsDataHeader', {}, 'Stats', {});
BootstrapSummary=struct('Strain', {}, 'PiliPerCell', {},'PiliPerCellMed', {},'PiliPerCellCI', {}, 'FreqRet', {},'FreqRetMed', {},'FreqRetCI', {}, 'RetPerPili', {},'RetPerPiliMed', {},'RetPerPiliCI', {}, 'Lengths', {}, 'LengthsMean', {}, 'LengthsSE', {});
F_boot=fieldnames(BootstrapSummary);
%% extracting some data
for StrainNb=1:NBStrains
    A=getInfo2(Workbook, char(Sheet(1,StrainNb)), Startrow(StrainNb), Endrow(StrainNb), PixelSize, FrameTime);
    DataSummary=[DataSummary;A];
end

ver=1;
hor=2;
Shift=0.15;
BootN=300;
CircleSize=24;

figure(1);
%% Pili per cells
[ BootPiliPerCell2 ] = plotData( DataSummary([1,2,3,4,5,6,7,8]), 'CellsData', {':',2},F_boot,[2, 3, 4], BootN, Shift, 'Pili per cell', 'pili', Sheet([1,2,3,4,5,6,7,8]), 'Bootstrap', CircleSize, Colors );

toc;