%%
% BacStalk
%
% Copyright (c) 2018 Raimo Hartmann & Muriel van Teeseling <bacstalk@gmail.com>
% Copyright (c) 2018 Drescher-lab, Max Planck Institute for Terrestrial Microbiology, Marburg, Germany
% Copyright (c) 2018 Thanbichler-lab, Philipps Universitaet, Marburg, Germany
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%%

function data = BacStalk(mean_cell_size,min_cell_size,delta_x,search_radius,dilation_width,varargin)

fprintf('=== BacStalk ===\n')
fprintf('Copyright (c) 2019 by Raimo Hartmann and Muriel van Teeseling\n');
fprintf('  Max Planck Institute for Terrestrial Microbiology, Marburg\n');
fprintf('  Philipps Universitaet, Marburg\n');
fprintf('Loading... ');

data = struct;

% Add folder "includes" to path
if isdeployed
    guiPath = '';
else
    guiPath = mfilename('fullpath');
    guiPath = fileparts(guiPath);
    addpath(genpath(fullfile(guiPath, 'includes')));
end
data.guiPath = guiPath;
   
% Cells w/o stalks
data.settings.algnmentOptions{1} = {'Cell pole', ...
    'Cell center'};
data.settings.sortOptions{1} = {'Cell length', 'Same order as shown in table'};

% Cells w stalks
data.settings.algnmentOptions{2} = {'Cell pole', ...
    'Cell center', ...
    'Cell-stalk', ...
    'Stalk center', ...
    'Stalk end'};
data.settings.sortOptions{2} = {'Cell length', 'Stalk length', 'Cell+stalk length', 'Same order as shown in table'};

% Cells w stalks and budding cell
data.settings.algnmentOptions{3} = {'Cell pole of mother cell', ...
    'Cell center of mother cell', ...
    'Mother cell-stalk', ...
    'Stalk center', ...
    'Stalk-bud', ...
    'Cell center of bud', ...
    'Cell pole of bud'};
data.settings.sortOptions{3} = {'Mother cell length', 'Stalk length', 'Mother cell+stalk length', 'Bud length', 'Bud area', 'Mother cell+bud length', 'Mother cell+stalk+bud length', 'Same order as shown in table'};

data.settings.displayCellOptions{1} = {'All cells', ...
    'Only deleted cells',...
    'All cells incl. deleted cells'};

data.settings.displayCellOptions{2} = {'All cells', ...
    'Only swarmer cells w/o stalks', ...
    'Only cells with stalks', ...
    'Only deleted cells',...
    'All cells incl. deleted cells'};

data.settings.displayCellOptions{3} = {'All cells', ...
    'Only swarmer cells w/o stalks', ...
    'Only cells with stalks', ...
    'Only cells with stalks w/o buds', ...
    'Only mother cells with stalks connected to buds', ...
    'Only buds',...
    'Only deleted cells',...
    'All cells incl. deleted cells'};


% Create interface
f = createInterface(data,mean_cell_size,min_cell_size,delta_x,search_radius,dilation_width);
data = getUIData(f);

% Check for toolboxes
if ~isToolboxAvailable('Image Processing Toolbox')
    msgbox('StalkStalker requires the "Image Processing Toolbox".', 'Toolbox missing', 'error', 'modal');
    delete(f);
end

if ~isToolboxAvailable('Parallel Computing Toolbox')
    msgbox('Parallel image processing is disabled because the "Parallel Computing Toolbox" is missing.', 'Toolbox missing', 'warn', 'modal');
    set(findobj(data.mainFigure, 'Tag', 'ParallelProcessing'), 'Enable', 'off', 'Value', 0)
end

fprintf('Done.\n');


