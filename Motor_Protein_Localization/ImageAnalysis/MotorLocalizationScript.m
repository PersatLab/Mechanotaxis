%% Initialization
clear all; close all; clc;
tic
%% Set Constant variables
currentFolder = pwd;
data_root_path=strcat(currentFolder, "/data");
addpath('./functions')

% mNeonGreen_fimX dataset files
fimX_liq_files={'/DataSet_mNG_fimX_fliC-_liq_BR=1.mat','/DataSet_mNG_fimX_fliC-_liq_BR=2.mat','/DataSet_mNG_fimX_fliC-_liq_BR=3.mat'};
fimX_pilH_liq_files={'/DataSet_mNG_fimX_pilH-fliC-_liq_BR=1.mat', '/DataSet_mNG_fimX_pilH-fliC-_liq_BR=2.mat', '/DataSet_mNG_fimX_pilH-fliC-_liq_BR=3.mat'};
fimX_pilG_liq_files={'/DataSet_mNG_fimX_pilG-fliC-_liq_BR=1.mat','/DataSet_mNG_fimX_pilG-fliC-_liq_BR=2.mat','/DataSet_mNG_fimX_pilG-fliC-_liq_BR=3.mat'};
fimX_cpdA_liq_files={'/DataSet_mNG_fimX_cpdA-fliC-_liq_BR=1.mat', '/DataSet_mNG_fimX_cpdA-fliC-_liq_BR=2.mat', '/DataSet_mNG_fimX_cpdA-fliC-_liq_BR=3.mat'};

% pilB_mNeonGreen dataset files
pilB_liq_files={'/DataSet_pilB_mNG_liq_BR=1.mat', '/DataSet_pilB_mNG_liq_BR=2.mat', '/DataSet_pilB_mNG_liq_BR=3.mat'};
pilB_pilH_liq_files={'/DataSet_pilB_mNG_pilH-_liq_BR=1.mat', '/DataSet_pilB_mNG_pilH-_liq_BR=2.mat', '/DataSet_pilB_mNG_pilH-_liq_BR=3.mat'};
pilB_pilG_liq_files={'/DataSet_pilB_mNG_pilG-_liq_BR=1.mat','/DataSet_pilB_mNG_pilG-_liq_BR=2.mat','/DataSet_pilB_mNG_pilG-_liq_BR=3.mat'};
pilB_cpdA_liq_files={'/DataSet_pilB_mNG_cpdA-_liq_BR=1.mat', '/DataSet_pilB_mNG_cpdA-_liq_BR=2.mat', '/DataSet_pilB_mNG_cpdA-_liq_BR=3.mat'};

% Inducible pilB_mNG with arabinose
pilB_0_0ara_files={'/DataSet_pilB-_pilB_mNG_0ara_BR=1.mat'};
pilB_0_03ara_files={'/DataSet_pilB-_pilB_mNG_0-03ara_BR=1.mat'};
pilB_0_1ara_files={'/DataSet_pilB-_pilB_mNG_0-1ara_BR=1.mat'};

% mNeonGreen_pilH dataset files
pilH_liq_files={'/DataSet_mNG_pilH_liq_BR=1.mat', '/DataSet_mNG_pilH_liq_BR=2.mat', '/DataSet_mNG_pilH_liq_BR=3.mat'};

% mNeonGreen_pilH dataset files
pilG_liq_files={'/DataSet_mNG_pilG_liq_BR=1.mat', '/DataSet_mNG_pilG_liq_BR=2.mat', '/DataSet_mNG_pilG_liq_BR=3.mat'};

% Field name of fluorescence profile data in the BacStalk Struct Dataset
fluo_FieldNames='MedialAxisIntensity_mNeonGreen';

%% Compute profile stats
NbUpSamples=200; %Up sample the intensity profile to get similar length vectors to compare.
Biological_reps=3;
k=linspace(0,1,NbUpSamples); %k is a ordered vector from 1 to 200
CellLengthLiq=5; %in �m;
CellLengthSol=5; %in �m;

%Generate Biological replicates corresponding names
fields=cell(Biological_reps, 1);
for i=1:Biological_reps
    name=strcat('BR',num2str(i));
    fields(i)= {name};
end

for y=1:Biological_reps
    %FimX
    [MeanFimXliq(y,:), StdFimXliq(y,:), NFimXliq(y), ProfileFimXliq.(char(fields(y))), FluoMeansFimXliq.(char(fields(y))), CellWidthFimXliq.(char(fields(y))), CellLengthFimXliq.(char(fields(y))), CellIDFimXliq.(char(fields(y)))]=getMeanProfile(strcat(data_root_path, fimX_liq_files{y}), k, NbUpSamples, fluo_FieldNames, CellLengthLiq);
    temp=trapz(MeanFimXliq(y,:));
    MeanFimXliq(y,:)=MeanFimXliq(y,:)/temp;
    
    [MeanFimXpilHliq(y,:), StdFimXpilHliq(y,:), NFimXpilHliq(y), ProfileFimXpilHliq.(char(fields(y))), FluoMeansFimXpilHliq.(char(fields(y))), CellWidthFimXpilHliq.(char(fields(y))), CellLengthFimXpilHliq.(char(fields(y))), CellIDFimXpilHliq.(char(fields(y)))]=getMeanProfile(strcat(data_root_path, fimX_pilH_liq_files{y}), k, NbUpSamples, fluo_FieldNames, CellLengthLiq);
    temp=trapz(MeanFimXpilHliq(y,:));
    MeanFimXpilHliq(y,:)=MeanFimXpilHliq(y,:)/temp;
    
    [MeanFimXpilGliq(y,:), StdFimXpilGliq(y,:), NFimXpilGliq(y), ProfileFimXpilGliq.(char(fields(y))), FluoMeansFimXpilGliq.(char(fields(y))), CellWidthFimXpilGliq.(char(fields(y))), CellLengthFimXpilGliq.(char(fields(y))), CellIDFimXpilGliq.(char(fields(y)))]=getMeanProfile(strcat(data_root_path, fimX_pilG_liq_files{y}), k, NbUpSamples, fluo_FieldNames, CellLengthLiq);
    temp=trapz(MeanFimXpilGliq(y,:));
    MeanFimXpilGliq(y,:)=MeanFimXpilGliq(y,:)/temp;
    
    [MeanFimXcpdAliq(y,:), StdFimXcpdAliq(y,:), NFimXcpdAliq(y), ProfileFimXcpdAliq.(char(fields(y))), FluoMeansFimXcpdAliq.(char(fields(y))), CellWidthFimXcpdAliq.(char(fields(y))), CellLengthFimXcpdAliq.(char(fields(y))), CellIDFimXcpdAliq.(char(fields(y)))]=getMeanProfile(strcat(data_root_path, fimX_cpdA_liq_files{y}), k, NbUpSamples, fluo_FieldNames, CellLengthLiq);
    temp=trapz(MeanFimXcpdAliq(y,:));
    MeanFimXcpdAliq(y,:)=MeanFimXcpdAliq(y,:)/temp;
    
    %PilB
    [MeanPilBliq(y,:), StdPilBliq(y,:), NpilBliq(y), ProfilePilBliq.(char(fields(y))), FluoMeansPilBliq.(char(fields(y))), CellWidthPilBliq.(char(fields(y))), CellLengthPilBliq.(char(fields(y))), CellIDPilBliq.(char(fields(y)))]=getMeanProfile(strcat(data_root_path, pilB_liq_files{y}), k, NbUpSamples, fluo_FieldNames, CellLengthLiq);
    temp=trapz(MeanPilBliq(y,:));
    MeanPilBliq(y,:)=MeanPilBliq(y,:)/temp;
    
    [MeanPilBpilHliq(y,:), StdPilBpilHliq(y,:), NpilBpilHliq(y), ProfilePilBpilHliq.(char(fields(y))), FluoMeansPilBpilHliq.(char(fields(y))), CellWidthPilBpilHliq.(char(fields(y))), CellLengthPilBpilHliq.(char(fields(y))), CellIDPilBpilHliq.(char(fields(y)))]=getMeanProfile(strcat(data_root_path, pilB_pilH_liq_files{y}), k, NbUpSamples, fluo_FieldNames, CellLengthLiq);
    temp=trapz(MeanPilBpilHliq(y,:));
    MeanPilBpilHliq(y,:)=MeanPilBpilHliq(y,:)/temp; 
    
    [MeanPilBpilGliq(y,:), StdPilBpilGliq(y,:), NpilBpilGliq(y), ProfilePilBpilGliq.(char(fields(y))), FluoMeansPilBpilGliq.(char(fields(y))), CellWidthPilBpilGliq.(char(fields(y))), CellLengthPilBpilGliq.(char(fields(y))), CellIDPilBpilGliq.(char(fields(y)))]=getMeanProfile(strcat(data_root_path, pilB_pilG_liq_files{y}), k, NbUpSamples, fluo_FieldNames, CellLengthLiq);
    temp=trapz(MeanPilBpilGliq(y,:));
    MeanPilBpilGliq(y,:)=MeanPilBpilGliq(y,:)/temp;     
    
    [MeanPilBcpdAliq(y,:), StdPilBcpdAliq(y,:), NpilBcpdAliq(y), ProfilePilBcpdAliq.(char(fields(y))), FluoMeansPilBcpdAliq.(char(fields(y))), CellWidthPilBcpdAliq.(char(fields(y))), CellLengthPilBcpdAliq.(char(fields(y))), CellIDPilBcpdAliq.(char(fields(y)))]=getMeanProfile(strcat(data_root_path, pilB_cpdA_liq_files{y}), k, NbUpSamples, fluo_FieldNames, CellLengthLiq);
    temp=trapz(MeanPilBcpdAliq(y,:));
    MeanPilBcpdAliq(y,:)=MeanPilBcpdAliq(y,:)/temp;
    
    %PilH
    [MeanPilHliq(y,:), StdPilHliq(y,:), NpilHliq(y), ProfilePilHliq.(char(fields(y))), FluoMeansPilHliq.(char(fields(y))), CellWidthPilHliq.(char(fields(y))), CellLengthPilHliq.(char(fields(y))), CellIDPilHliq.(char(fields(y)))]=getMeanProfile(strcat(data_root_path, pilH_liq_files{y}), k, NbUpSamples, fluo_FieldNames, CellLengthLiq);
    temp=trapz(MeanPilHliq(y,:));
    MeanPilHliq(y,:)=MeanPilHliq(y,:)/temp;
    
    %PilG
    [MeanPilGliq(y,:), StdPilGliq(y,:), NpilGliq(y), ProfilePilGliq.(char(fields(y))), FluoMeansPilGliq.(char(fields(y))), CellWidthPilGliq.(char(fields(y))), CellLengthPilGliq.(char(fields(y))), CellIDPilGliq.(char(fields(y)))]=getMeanProfile(strcat(data_root_path, pilG_liq_files{y}), k, NbUpSamples, fluo_FieldNames, CellLengthLiq);
    temp=trapz(MeanPilGliq(y,:));
    MeanPilGliq(y,:)=MeanPilGliq(y,:)/temp;
end

%% Compute profiles for Inducible PilB_mNG
for y=1:1
    [MeanpilB_0_0ara(y,:), StdpilB_0_0ara(y,:), NpilB_0_0ara(y), ProfilePilB_0_0ara.(char(fields(y))), FluoMeansPilB_0_0ara.(char(fields(y))), CellWidthPilB_0_0ara.(char(fields(y))), CellLengthPilB_0_0ara.(char(fields(y))), CellIDPilB_0_0ara.(char(fields(y)))]=getMeanProfile(strcat(data_root_path, pilB_0_0ara_files{y}), k, NbUpSamples, fluo_FieldNames, CellLengthSol);
    temp=trapz(MeanpilB_0_0ara(y,:));
    MeanpilB_0_0ara(y,:)=MeanpilB_0_0ara(y,:)/temp;
    [MeanpilB_0_03ara(y,:), StdpilB_0_03ara(y,:), NpilB_0_03ara(y), ProfilePilB_0_03ara.(char(fields(y))), FluoMeansPilB_0_03ara.(char(fields(y))), CellWidthPilB_0_03ara.(char(fields(y))), CellLengthPilB_0_03ara.(char(fields(y))), CellIDPilB_0_03ara.(char(fields(y)))]=getMeanProfile(strcat(data_root_path, pilB_0_03ara_files{y}), k, NbUpSamples, fluo_FieldNames, CellLengthSol);
    temp=trapz(MeanpilB_0_03ara(y,:));
    MeanpilB_0_03ara(y,:)=MeanpilB_0_03ara(y,:)/temp;
    [MeanpilB_0_1ara(y,:), StdpilB_0_1ara(y,:), NpilB_0_1ara(y), ProfilePilB_0_1ara.(char(fields(y))), FluoMeansPilB_0_1ara.(char(fields(y))), CellWidthPilB_0_1ara.(char(fields(y))), CellLengthPilB_0_1ara.(char(fields(y))), CellIDPilB_0_1ara.(char(fields(y)))]=getMeanProfile(strcat(data_root_path, pilB_0_1ara_files{y}), k, NbUpSamples, fluo_FieldNames, CellLengthSol);
    temp=trapz(MeanpilB_0_1ara(y,:));
    MeanpilB_0_1ara(y,:)=MeanpilB_0_1ara(y,:)/temp;
end

%% Compute polar ratios
BootN=300;
% PilB
[RatPilBliq, BootRatPilBliq, MeanRatPilBliq, stdRatPilBliq, PolarisationPilBliq, MeanPolarisationPilBliq]=polarRatios2(ProfilePilBliq, CellWidthPilBliq, CellLengthPilBliq, k, BootN);
[RatPilBpilHliq, BootRatPilBpilHliq, MeanRatPilBpilHliq, stdRatPilBpilHliq, PolarisationPilBpilHliq, MeanPolarisationPilBpilHliq]=polarRatios2(ProfilePilBpilHliq, CellWidthPilBpilHliq, CellLengthPilBpilHliq, k, BootN);
[RatPilBpilGliq, BootRatPilBpilGliq, MeanRatPilBpilGliq, stdRatPilBpilGliq, PolarisationPilBpilGliq, MeanPolarisationPilBpilGliq]=polarRatios2(ProfilePilBpilGliq,  CellWidthPilBpilGliq, CellLengthPilBpilGliq, k, BootN);
[RatPilBcpdAliq, BootRatPilBcpdAliq, MeanRatPilBcpdAliq, stdRatPilBcpdAliq, PolarisationPilBcpdAliq, MeanPolarisationPilBcpdAliq]=polarRatios2(ProfilePilBcpdAliq,  CellWidthPilBcpdAliq, CellLengthPilBcpdAliq, k, BootN);

% FimX
[RatFimXliq, BootRatFimXliq, MeanRatFimXliq, stdRatFimXliq, PolarisationFimXliq, MeanPolarisationFimXliq]=polarRatios2(ProfileFimXliq, CellWidthFimXliq, CellLengthFimXliq, k, BootN);
[RatFimXpilHliq, BootRatFimXpilHliq, MeanRatFimXpilHliq, stdRatFimXpilHliq, PolarisationFimXpilHliq, MeanPolarisationFimXpilHliq]=polarRatios2(ProfileFimXpilHliq, CellWidthFimXpilHliq, CellLengthFimXpilHliq, k, BootN);
[RatFimXpilGliq, BootRatFimXpilGliq, MeanRatFimXpilGliq, stdRatFimXpilGliq, PolarisationFimXpilGliq, MeanPolarisationFimXpilGliq]=polarRatios2(ProfileFimXpilGliq,  CellWidthFimXpilGliq, CellLengthFimXpilGliq, k, BootN);
[RatFimXcpdAliq, BootRatFimXcpdAliq, MeanRatFimXcpdAliq, stdRatFimXcpdAliq, PolarisationFimXcpdAliq, MeanPolarisationFimXcpdAliq]=polarRatios2(ProfileFimXcpdAliq,  CellWidthFimXcpdAliq, CellLengthFimXcpdAliq, k, BootN);

% Response Regulators
[RatPilHliq, BootRatPilHliq, MeanRatPilHliq, stdRatPilHliq, PolarisationPilHliq, MeanPolarisationPilHliq]=polarRatios2(ProfilePilHliq, CellWidthPilHliq, CellLengthPilHliq, k, BootN);
[RatPilGliq, BootRatPilGliq, MeanRatPilGliq, stdRatPilGliq, PolarisationPilGliq, MeanPolarisationPilGliq]=polarRatios2(ProfilePilGliq,  CellWidthPilGliq, CellLengthPilGliq, k, BootN);

% Inducible PilB_mNG
[RatPilB_0_0ara, BootPilB_0_0ara, MeanRatPilB_0_0ara, stdRatPilB_0_0ara, PolarisationPilB_0_0ara, MeanPolarisationPilB_0_0ara]=polarRatios2(ProfilePilB_0_0ara, CellWidthPilB_0_0ara, CellLengthPilB_0_0ara, k, BootN);
[RatPilB_0_03ara, BootPilB_0_03ara, MeanRatPilB_0_03ara, stdRatPilB_0_03ara, PolarisationPilB_0_03ara, MeanPolarisationPilB_0_03ara]=polarRatios2(ProfilePilB_0_03ara, CellWidthPilB_0_03ara, CellLengthPilB_0_03ara, k, BootN);
[RatPilB_0_1ara, BootPilB_0_1ara, MeanRatPilB_0_1ara, stdRatPilB_0_1ara, PolarisationPilB_0_1ara, MeanPolarisationPilB_0_1ara]=polarRatios2(ProfilePilB_0_1ara, CellWidthPilB_0_1ara, CellLengthPilB_0_1ara, k, BootN);

save('WorkSpace_Final.mat');
%% Plot profiles

save_path='final_figures/';
k=linspace(-1,1,NbUpSamples);
% PilB_mNG main figure
figure(1)
y_limit=max(max((MeanPilBpilHliq)+0.1*max(MeanPilBpilHliq),[],2));
alpha=0.4;
linewidth_main=2;
dim=1;
Legend = {'WT', 'ΔpilG', 'ΔpilH', 'ΔcpdA'};
Title = 'PilB localization profiles Fig 5C';
Colors_main = [170 170 170; 0 166 156; 236 32 36; 139 197 63];
Y_limit=[0, y_limit];
plotProfiles(Title, Legend, alpha, linewidth_main, dim, Colors_main, false, Y_limit, k, MeanPilBliq, MeanPilBpilGliq, MeanPilBpilHliq, MeanPilBcpdAliq);
saveas(gcf, strcat(save_path,'Fig 5C'), 'fig');
saveas(gcf, strcat(save_path,'Fig 5C'), 'epsc');

% mNG_FimX main figure
figure(2)
Title = 'FimX localization profiles Fig 5D';
plotProfiles(Title, Legend, alpha, linewidth_main, dim, Colors_main, false, Y_limit, k, MeanFimXliq, MeanFimXpilGliq, MeanFimXpilHliq, MeanFimXcpdAliq);
saveas(gcf, strcat(save_path,'Fig 5D'), 'fig');
saveas(gcf, strcat(save_path,'Fig 5D'), 'epsc');



% Response Regulators
figure(3)
subplot(2,1,1)
Legend = {'PilG', 'PilH'};
Title = 'Response Regulators Fig 6B';
Colors_RR = [0 166 156; 236 32 36];
Y_limit=[0, 0.015];
plotProfiles(Title, Legend, alpha, linewidth_main, dim, Colors_RR, false, Y_limit, k, MeanPilGliq, MeanPilHliq)


% Inducible PilB
figure(4)
subplot(1,3,1);
Legend = {'0.0 g/l arabinose', '0.3 g/l arabinose', '1.0 g/l arabinose'};
Title = 'Arabinose inducible pilB_mNG Fig S9A';
Colors_ARA = [200 200 200; 150 150 150; 100 100 100];
Y_limit=[0, 0.015];
plotProfiles(Title, Legend, alpha, linewidth_main, dim, Colors_ARA, false, Y_limit, k, MeanpilB_0_0ara, MeanpilB_0_03ara, MeanpilB_0_1ara)


% Plot polar localization

% Response Regulators
figure(3)
subplot(2,1,2)
DataMarkerSize=8;
Legends_RR={'PilG', 'PilH'};
Title='Response Regulators polar localization Fig 6C';
YLable='Polar localization index';
Ylimit=[0, 1];
plotPolarityMeans(Title, YLable, Ylimit, DataMarkerSize, Legends_RR, Colors_RR, MeanRatPilGliq, MeanRatPilHliq)
saveas(gcf, strcat(save_path,'Fig 6BC'), 'fig');
saveas(gcf, strcat(save_path,'Fig 6BC'), 'epsc');

% PilB
figure(5)
subplot(2,1,1)
DataMarkerSize=8;
Title = 'PilB polar localization index Fig 5E';
Legends_main = {'WT', 'ΔpilG', 'ΔpilH', 'ΔcpdA'};
plotPolarityMeans(Title, YLable, Ylimit, DataMarkerSize, Legends_main, Colors_main, MeanRatPilBliq, MeanRatPilBpilGliq, MeanRatPilBpilHliq, MeanRatPilBcpdAliq)


% FimX
figure(6)
subplot(2,1,1)
Title = 'FimX polar localization index Fig 5G';
plotPolarityMeans(Title, YLable, Ylimit, DataMarkerSize, Legends_main, Colors_main, MeanRatFimXliq, MeanRatFimXpilGliq, MeanRatFimXpilHliq, MeanRatFimXcpdAliq)

%PilB arabinose induced
figure(4)
subplot(1,3,2);
Title = 'pilB polar localization index arabinosed induced Fig S9B';
Legends_induced = {'0.0 g/l arabinose', '0.3 g/l arabinose', '1.0 g/l arabinose'};
plotPolarityMeans(Title, YLable, [0, 0.5], DataMarkerSize, Legends_induced, Colors_ARA, MeanRatPilB_0_0ara, MeanRatPilB_0_03ara, MeanRatPilB_0_1ara)

% Plot symetry index
YLable='Symmetry index';
Ylimit=[0.5, 1];

% PilB
figure(5)
subplot(2,1,2)
DataMarkerSize=10;
Title = 'PilB symmetry index Fig 5F';
plotPolarityMeans(Title, YLable, Ylimit, DataMarkerSize, Legends_main, Colors_main, MeanPolarisationPilBliq, MeanPolarisationPilBpilGliq, MeanPolarisationPilBpilHliq, MeanPolarisationPilBcpdAliq);
saveas(gcf, strcat(save_path,'Fig 5EF'), 'fig');
saveas(gcf, strcat(save_path,'Fig 5EF'), 'epsc');

% FimX
figure(6)
subplot(2,1,2)
Title = 'FimX symmetry index Fig 5H';
plotPolarityMeans(Title, YLable, Ylimit, DataMarkerSize, Legends_main, Colors_main, MeanPolarisationFimXliq, MeanPolarisationFimXpilGliq, MeanPolarisationFimXpilHliq, MeanPolarisationFimXcpdAliq);
saveas(gcf, strcat(save_path,'Fig 5GH'), 'fig');
saveas(gcf, strcat(save_path,'Fig 5GH'), 'epsc');

%PilB arabinose induced
figure(4)
subplot(1,3,3);
Title = 'pilB symmetry index arabinosed induced Fig S9C';
YLabel = 'polarization index';
plotPolarityMeans(Title, YLable, [0.5, 0.75], DataMarkerSize, Legends_induced, Colors_ARA, MeanPolarisationPilB_0_0ara, MeanPolarisationPilB_0_03ara, MeanPolarisationPilB_0_1ara)
saveas(gcf, strcat(save_path,'Fig S9'), 'fig');
saveas(gcf, strcat(save_path,'Fig S9'), 'epsc');
%%
toc