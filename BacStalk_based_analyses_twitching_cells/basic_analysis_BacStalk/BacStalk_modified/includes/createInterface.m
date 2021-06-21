%%
% BacStalk
%
% Copyright (c) 2018 Raimo Hartmann & Muriel van Teeseling <bacstalk@gmail.com>
% Copyright (c) 2018 Drescher-lab, Max Planck Institute for Terrestrial Microbiology, Marburg, Germany
% Copyright (c) 2018 Thanbichler-lab, Philipps Universitaet, Marburg, Germany
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
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

function f = createInterface(data,mean_cell_size,min_cell_size,delta_x,search_radius,dilation_width)
%% Create splash screen
triggerSplashScreen(1, data);
s = getappdata(0,'aeSplashHandle');
set(s,'ProgressRatio', 0.1);

t = [];
fb = [];
m = [];

%% Initialize main figure
screenSize = get(0,'screensize');
if screenSize(3) >= 1600 
    position = [0.1 0.1 0.8 0.8];
else
    position = [0 0 1 0.9];
end

f = figure('Name', 'BacStalk', 'Units', 'Normalized', 'Position', ...
    position, 'Visible', 'off', 'CloseRequestFcn', @closeFigure);
f = addIcon(f);
data.mainFigure = f;

%% Parameters
tabColor = [0.7490 0.902 1];

%% Remove default uimenus
delete(findobj(findall(f),'type','uiMenu'));
delete(findobj(findall(f),'tag','Standard.EditPlot'));
delete(findobj(findall(f),'tag','Annotation.InsertLegend'));
delete(findobj(findall(f),'tag','Annotation.InsertColorbar'));
delete(findobj(findall(f),'tag','DataManager.Linking'));
delete(findobj(findall(f),'type','uiPushTool'));
delete(findobj(findall(f),'type','uiToggleSplitTool'));
delete(findobj(findall(f),'tag','Exploration.Rotate'));


%% Create menues
m.m1 = uimenu(f,'Label','File');
uimenu(m.m1,'Label','Load data', 'Callback', @loadData, 'Accelerator', 'o');
uimenu(m.m1,'Label','Save data', 'Callback', @saveData, 'Accelerator', 's');
uimenu(m.m1,'Label','Merge two files', 'Separator', 'on', 'Callback', @mergeFiles, 'Accelerator', 'm');
uimenu(m.m1,'Label','Export analysis-table to csv-file', 'Separator', 'on', 'Callback', @exportCSV, 'Enable', 'off', 'Accelerator', 'e');
uimenu(m.m1,'Label','Exit', 'Separator', 'on', 'Callback', @closeFigure, 'Accelerator', 'e');

m.m2 = uimenu(f,'Label','Tools', 'Enable', 'off');
m.c1 = uicontextmenu;

for mi = 1:2
    switch mi
        case 1
            m_h = m.m2;
        case 2
            m_h = m.c1;
    end
            
    uimenu(m_h,'Label','Delete image', 'Callback', @deleteImage);
    uimenu(m_h,'Label','Measure distance', 'Callback', {@addScalebar, 'distance'}, 'Separator', 'on', 'Accelerator', 'd');
    uimenu(m_h,'Label','Save screenshot', 'Callback', {@createScreenshot, 'screenshot'}, 'Separator', 'on');
    uimenu(m_h,'Label','Save movie', 'Callback', {@createScreenshot, 'movie'});
    if mi == 1 
        uimenu(m_h,'Label','Create multichannel demo-/kymograph', 'Callback', @multiChannelGraph, 'Separator', 'on');
    end
    uimenu(m_h,'Label','Add/update scalebar', 'Callback', {@addScalebar, 'scalebar'}, 'Separator', 'on');
    
    if mi == 2 
        uimenu(m_h,'Label','--- Help ---', 'Separator', 'on', 'Enable', 'off');
        uimenu(m_h,'Label','Delete cell/stalk:', 'Separator', 'on', 'Enable', 'off');
        uimenu(m_h,'Label',' -> Click on outline or ID', 'Enable', 'off');
        uimenu(m_h,'Label','Swap orientation:', 'Enable', 'off');
        uimenu(m_h,'Label',' -> Click on medial axis', 'Enable', 'off');
        uimenu(m_h,'Label','Undo deletion:', 'Enable', 'off');
        uimenu(m_h,'Label',' -> Click on deleted cell/stalk', 'Enable', 'off');
        uimenu(m_h,'Label','Display cell comment:', 'Enable', 'off');
        uimenu(m_h,'Label',' -> Right-click on deleted cell/stalk', 'Enable', 'off');
    end
end

m.m3 = uimenu(f,'Label','Help');
uimenu(m.m3,'Label','Help', 'Callback', @openHelp, 'Accelerator', 'h');
uimenu(m.m3,'Label','Video tutorials', 'Callback', {@openHelp, 'usage/video_tutorials.html'});
uimenu(m.m3,'Label','About', 'Callback', @about, 'Separator', 'on');

m.m4 = uicontextmenu(data.mainFigure);
uimenu(m.m4, 'Label', 'Delete scalebar', 'Callback', @deleteScalebar);

set(s,'ProgressRatio', 0.2);

%% Create layout
p0 = uix.CardPanel('Parent', f, 'Padding', 0, 'Tag', 'toggleScreen');
% Wrap a scroll-panel around everythin in case screen is too small
sc = uix.ScrollingPanel('Parent', p0);
tabGroup = uitabgroup('Parent', sc);
t(1).h = uitab('Parent', tabGroup, 'Title', 'Input', 'ButtonDownFcn', @showInputTab, 'BusyAction','queue','Interruptible', 'off');
t(2).h = uitab('Parent', tabGroup, 'Title', 'Cell/Stalk detection', 'ButtonDownFcn', @showCellDetectionTab, 'BusyAction','queue','Interruptible', 'off');
t(3).h = uitab('Parent', tabGroup, 'Title', 'Analysis', 'ButtonDownFcn', @showAnalysisTab, 'BusyAction','queue','Interruptible', 'off');
data.ui.tabGroup = tabGroup;
set(sc, 'MinimumHeights', 700, 'MinimumWidths', 1200);

% Busy screen
bb = uix.HButtonBox('Parent', p0, 'VerticalAlignment', 'middle',...
    'HorizontalAlignment', 'center', 'ButtonSize', [150 40]);
uicontrol('Parent', bb, 'Style', 'Text', 'String', 'Please wait...');
p0.Selection = 1;

%% Create main content

%% Input
% Flex box
fb(1).h = uix.HBoxFlex('Parent', t(1).h, 'Padding', 5, 'Spacing', 5);
% Left part
fb(1).p(1).h = uix.BoxPanel('Parent', fb(1).h, 'Title', 'File input', 'Padding', 5, ...
    'TitleColor', tabColor, 'ForegroundColor', 'black', 'HelpFcn', {@openHelp, 'usage/fileInput.html'});
% Right part
fb(1).vb(1).h = uix.VBox('Parent', fb(1).h, 'Spacing', 5);
% Parameters
fb(1).vb(1).params.h = uix.BoxPanel('Parent', fb(1).vb(1).h, 'Title', 'Parameters', 'Padding', 5, ...
    'TitleColor', tabColor, 'ForegroundColor', 'black', 'HelpFcn', {@openHelp, 'usage/fileInput.html#additional-parameters'});
% Cell type
fb(1).vb(1).cellType.h = uix.BoxPanel('Parent', fb(1).vb(1).h, 'Title', 'My cells...', 'Padding', 5, ...
    'TitleColor', [0.6784 0.9176 0.8549], 'ForegroundColor', 'black', 'HelpFcn', {@openHelp, 'usage/fileInput.html#additional-parameters'});
% Navigation
fb(1).vb(1).nav.h = uix.BoxPanel('Parent', fb(1).vb(1).h, 'Title', 'Navigation', 'Padding', 5, ...
    'TitleColor', [1.0000 0.6784 0.64310], 'ForegroundColor', 'black');
set(fb(1).vb(1).h, 'Heights', [170 -1 70]);

fb(1).h.Widths = [-1 300];

% Populate Input/Left
% Create devider for content
fb(1).p(1).hb(1).h = uix.HBoxFlex('Parent', fb(1).p(1).h, 'Spacing', 5);

set(s,'ProgressRatio', 0.3);

% File handling
g = uix.Grid('Parent', fb(1).p(1).hb(1).h, 'Spacing', 5, 'Spacing', 5);
bb = uix.HButtonBox('Parent', g, 'VerticalAlignment', 'top' ,...
     'HorizontalAlignment', 'left', 'ButtonSize', [100, 30]);
uicontrol('Parent', bb, 'Style', 'Pushbutton', 'String', 'Add file(s)', 'Tag', 'pb_addFiles', ...
    'Callback', @addFiles)
uicontrol('Parent', bb, 'Style', 'Pushbutton', 'String', 'Delete file (s)', 'Tag', 'pb_deleteFile', ...
    'Callback', @deleteFiles)
uicontrol('Parent', g, 'Style', 'Text', 'String', 'Selected files:', ...
    'Tag', 'text_files', 'HorizontalAlignment', 'left')
uicontrol('Parent', g, 'Style', 'Listbox', 'Tag', 'lb_files', 'Callback', @previewImage)

% Preview window
fb(1).p(1).hb(1).preview.h = uix.BoxPanel('Parent', g, 'Title', 'Preview', 'Padding', 5, ...
    'TitleColor', tabColor, 'ForegroundColor', 'black');
set(g, 'Widths', [-1], 'Heights', [50 20 -2 -1]);
data.axes.preview = axes('Parent', fb(1).p(1).hb(1).preview.h, ...
    'ActivePositionProperty', 'Position');
removeAxis(data.axes.preview);

% Divide Channel/Metadata/Filelist view
fb(1).p(1).hb(1).vb(1).h = uix.VBoxFlex('Parent', fb(1).p(1).hb(1).h , 'Spacing', 5);
fb(1).p(1).hb(1).vb(1).hb(1).h = uix.HBoxFlex('Parent', fb(1).p(1).hb(1).vb(1).h, 'Spacing', 5);

% Setup channels
channels = uix.Panel('Parent', fb(1).p(1).hb(1).vb(1).hb(1).h, 'Title', 'Channels', 'Padding', 5);
g = uix.Grid('Parent', channels, 'Spacing', 5);
bb = uix.HButtonBox('Parent', g, 'VerticalAlignment', 'top' ,...
     'HorizontalAlignment', 'left', 'ButtonSize', [100, 30]);
bb1 = uix.VButtonBox('Parent', g, 'VerticalAlignment', 'top' ,...
    'HorizontalAlignment', 'left', 'ButtonSize', [400, 100], 'Spacing', 10);
uicontrol('Parent', bb, 'Style', 'Pushbutton', 'String', 'Add channel', ...
    'HorizontalAlignment', 'left', 'Callback', {@addChannel, bb1})
set(g, 'Widths', [-1], 'Heights', [50 -1]);
data.ui.channelBox = bb1;

% Setup metadata
meta = uix.Panel('Parent', fb(1).p(1).hb(1).vb(1).hb(1).h, 'Title', 'Metadata', 'Padding', 5);
g = uix.Grid('Parent', meta, 'Spacing', 5);
bb = uix.HButtonBox('Parent', g, 'VerticalAlignment', 'top' ,...
     'HorizontalAlignment', 'left', 'ButtonSize', [100, 30]);
bb2 = uix.VButtonBox('Parent', g, 'VerticalAlignment', 'top' ,...
    'HorizontalAlignment', 'left', 'ButtonSize', [400, 120], 'Spacing', 10);
uicontrol('Parent', bb, 'Style', 'Pushbutton', 'String', 'Add metadata', ...
    'HorizontalAlignment', 'left', 'Callback', {@addMetadata, bb2})
set(g, 'Widths', [-1], 'Heights', [50 -1]);
data.ui.metadataBox = bb2;

% Setup filelist
filelist = uix.Panel('Parent', fb(1).p(1).hb(1).vb(1).h, 'Title', 'File list', 'Padding', 5);
data.files = uitable('Parent', filelist, 'Tag', 'tbl_files', 'Data', [], 'CellSelectionCallback', @previewImage);

% Add one Channel/Metadata element
addChannel(bb1);
addMetadata(bb2);

% Set sizes of [Input]/[Channels & Metadata]
fb(1).p(1).hb(1).h.Widths = [-1 -3];

% Populate Parameters/Right
g = uix.Grid('Parent', fb(1).vb(1).params.h, 'Padding', 5);
parameters = {'Drift correction', false, '', 'Requires a time series with high temporal resolution', 'Checkbox', [], 'boolean';...
              'Scaling', delta_x, 'micron', 'Pixel dimension in micromenters', 'Edit', [0.01 100], 'float'};

heights = generateParameters(g, parameters);
Scaling_h = findobj(data.mainFigure, 'Tag', 'Scaling');
Scaling_h.Callback = @changeScaling;
driftCorrection_h = findobj(data.mainFigure, 'Tag', 'DriftCorrection');
set(driftCorrection_h, 'Enable', 'off', 'Value', 0);

set(g, 'Widths', -1, 'Heights', heights);

% Populate "My Cells..."/Right
g = uix.Grid('Parent', fb(1).vb(1).cellType.h, 'Padding', 5);
parameters = {'... have stalks', false, '', 'Cells grow stalks/flagella', 'Checkbox', [], 'boolean';...
              '... form buds', false,'', 'Cells divide by stalked budding', 'Checkbox', [], 'boolean'};

heights = generateParameters(g, parameters);
HaveStalks_h = findobj(data.mainFigure, 'Tag', 'x___HaveStalks');
HaveStalks_h.Callback = {@applyPreSettings, 'stalks'};
FormBuds_h = findobj(data.mainFigure, 'Tag', 'x___FormBuds');
FormBuds_h.Callback = {@applyPreSettings, 'buds'};

uicontrol('Parent', g, 'Style', 'Text', 'String', 'Please set up the right values depending on your cell type to turn stalk (and bud) detection on or off.', ...
    'FontAngle', 'italic', 'HorizontalAlignment', 'left');

set(g, 'Widths', -1, 'Heights', [heights 80]);

set(s,'ProgressRatio', 0.4);
% bb = uix.VButtonBox('Parent', fb(1).vb(1).params.h, 'VerticalAlignment', 'top' ,...
%     'HorizontalAlignment', 'left', 'ButtonSize', [300, 50]);
% uicontrol('Parent', bb, 'Style', 'Checkbox', 'String', 'Drift correction', ...
%     'Tag', 'cb_driftCorrection', 'Enable', 'off')
% uicontrol('Parent', bb, 'Style', 'text', 'String', 'Requires a time series with high temporal resolution', ...
%     'Tag', 'text_driftCorrection_desc', 'HorizontalAlignment', 'left', 'FontAngle', 'italic')

% Add navigation buttons
bb = uix.HButtonBox('Parent', fb(1).vb(1).nav.h, 'VerticalAlignment', 'top' ,...
     'HorizontalAlignment', 'center', 'ButtonSize', [200, 30]);
uicontrol('Parent', bb, 'Style', 'Pushbutton', 'String', 'Step 2: Cell/Stalk detection >', ...
    'HorizontalAlignment', 'left', 'Callback', @showCellDetectionTab, 'BusyAction','queue','Interruptible', 'off')

%% Cell/stalk detection
fb(2).h = uix.HBoxFlex('Parent', t(2).h, 'Padding', 5, 'Spacing', 5);

% Left part
fb(2).p(1).h = uix.BoxPanel('Parent', fb(2).h, 'Title', 'Image / Segmentation', 'Padding', 5, ...
    'TitleColor', tabColor, 'ForegroundColor', 'black', 'HelpFcn', {@openHelp, 'usage/segmentation.html'});
% Right part
fb(2).g(1).h = uix.Grid('Parent', fb(2).h, 'Padding', 0, 'Spacing', 5);

% Parameters
fb(2).g(1).bp(1).h = uix.BoxPanel('Parent', fb(2).g(1).h, 'Title', 'Parameters', 'Padding', 5, ...
    'TitleColor', tabColor, 'ForegroundColor', 'black', 'HelpFcn', {@openHelp, 'usage/segmentation.html#parameters'});
fb(2).g(1).params.h = uix.ScrollingPanel('Parent', fb(2).g(1).bp(1).h);
% Progress
fb(2).g(1).progress.h = uix.BoxPanel('Parent', fb(2).g(1).h, 'Title', 'Progress', 'Padding', 5, ...
    'TitleColor', tabColor, 'ForegroundColor', 'black');
% Control
fb(2).g(1).controls.h = uix.BoxPanel('Parent', fb(2).g(1).h, 'Title', 'Controls', 'Padding', 5, ...
    'TitleColor', tabColor, 'ForegroundColor', 'black');
% Navigation
fb(2).g(1).nav.h = uix.BoxPanel('Parent', fb(2).g(1).h, 'Title', 'Navigation', 'Padding', 5, ...
    'TitleColor', [1.0000 0.6784 0.64310], 'ForegroundColor', 'black');

set(fb(2).g(1).h, 'Heights', [-1 70 100 70], 'Widths', -1);
fb(2).h.Widths = [-1 305];

% Populate Cell/stalk detection/Left
fb(2).p(1).vb(1).h = uix.VBox('Parent', fb(2).p(1).h, 'Spacing', 5);

% [Image] / [Cell list]
fb(2).p(1).vb(1).hb(1).h = uix.HBoxFlex('Parent', fb(2).p(1).vb(1).h, 'Spacing', 5);

imagePanel = uix.Panel('Parent', fb(2).p(1).vb(1).hb(1).h, 'Title', 'Image', ...
    'Padding', 5);

% [Cell list] / [Track list]
fb(2).p(1).vb(1).hb(1).vb(1).h = uix.VBoxFlex('Parent', fb(2).p(1).vb(1).hb(1).h, 'Padding', 0,...
    'Spacing', 5);

cellListPanel = uix.Panel('Parent', fb(2).p(1).vb(1).hb(1).vb(1).h, 'Title', 'Cell list', 'Padding', 5);
trackListPanel = uix.Panel('Parent', fb(2).p(1).vb(1).hb(1).vb(1).h, 'Title', 'Track list', 'Padding', 5);

fb(2).p(1).vb(1).hb(1).vb(1).h.Heights = [-3 -1];
fb(2).p(1).vb(1).hb(1).h.Widths = [-4 -1];

% Image
data.axes.main = axes('Parent', imagePanel, 'ActivePositionProperty', 'Position', 'NextPlot', 'add');
removeAxis(data.axes.main);
set(zoom(data.axes.main),'ActionPostCallback',{@updateROI, 'zoom'});
set(pan(data.mainFigure),'ActionPostCallback',{@updateROI, 'zoom'});

% Cell list
hb = uix.VBox('Parent', cellListPanel, 'Spacing', 5);
[jtable, jscrollpane] = createJavaTable(hb, @clickCellTable);
data.tables.tableCells = {jtable, jscrollpane};

g = uix.Grid('Parent', hb);
uicontrol('Parent', g, 'Style', 'Pushbutton', 'String', 'Restore zoom', ...
    'HorizontalAlignment', 'left', 'Callback', @restoreZoom)
uicontrol('Parent', g, 'Style', 'Pushbutton', 'String', 'Remove cells outside ROI', ...
    'HorizontalAlignment', 'left', 'Callback', @updateCellsInRoi)
set(g, 'Heights', -1, 'Widths', [-90 -145]);
hb.Heights = [-1, 25];

% Track list
[jtable, jscrollpane] = createJavaTable(trackListPanel, {@clickTrackTable, 'segmentationTab'});
data.tables.tableTracksSegmentation = {jtable, jscrollpane};

set(s,'ProgressRatio', 0.5);

% Image display: slider/channel selector
fb(2).p(1).vb(1).nav.h = uix.BoxPanel('Parent', fb(2).p(1).vb(1).h, 'Title', 'Image slider', 'Padding', 5, ...
    'TitleColor', tabColor, 'ForegroundColor', 'black');
g = uix.Grid('Parent', fb(2).p(1).vb(1).nav.h, 'Spacing', 5, 'Padding', 0);
uix.Empty('Parent', g);
uicontrol('Parent', g, 'Style', 'Slider', 'Tag', 'slider_im', 'BusyAction','queue',...
    'Callback', @moveSlider, 'BusyAction', 'Cancel', 'Interruptible', 'off');

uix.Empty('Parent', g);
text_h = uicontrol('Parent', g, 'Style', 'text', 'String', 'Channel', ...
    'HorizontalAlignment', 'left');
jh = findjobj(text_h);
jh.setVerticalAlignment(javax.swing.JLabel.CENTER)

uicontrol('Parent', g, 'Style', 'Popupmenu', 'String', {'Phase-contrast'}, ...
    'Tag', 'popm_channel', 'Callback', @changeChannel)
uix.Empty('Parent', g);
text_h = uicontrol('Parent', g, 'Style', 'text', 'String', 'Colormap', ...
    'HorizontalAlignment', 'left');
jh = findjobj(text_h);
jh.setVerticalAlignment(javax.swing.JLabel.CENTER)
uicontrol('Parent', g, 'Style', 'Popupmenu', 'String', {'Gray',...
    'RedBlue', 'Parula', 'Jet', 'Hsv', 'Hot'}, ...
    'Tag', 'popm_colormap', 'Callback', @changeColormap)
uix.Empty('Parent', g);
text_h = uicontrol('Parent', g, 'Style', 'text', 'String', 'Intensity scale [min max]', ...
    'HorizontalAlignment', 'left');
jh = findjobj(text_h);
jh.setVerticalAlignment(javax.swing.JLabel.CENTER)
uicontrol('Parent', g, 'Style', 'edit', 'String', '0', 'FontSize', 8, ...
    'HorizontalAlignment', 'left', 'Tag', 'ed_climMin', 'Enable', 'off', 'Callback', @changeColorlimits);
uicontrol('Parent', g, 'Style', 'edit', 'String', '1', 'FontSize', 8, ...
    'HorizontalAlignment', 'left', 'Tag', 'ed_climMax', 'Enable', 'off', 'Callback', @changeColorlimits);
uicontrol('Parent', g, 'Style', 'checkbox', 'String', 'Auto', 'Value', 1,...
    'HorizontalAlignment', 'left', 'Tag', 'cb_climAuto', 'Callback', @changeColorlimits);

uix.Empty('Parent', g);
uicontrol('Parent', g, 'Style', 'Checkbox', 'String', 'Show overlays', ...
    'Tag', 'cb_overlays', 'Callback', @displayImage, 'Value', 1)
set(g, 'Widths', [-1 -10 -1 50 100 -1 60 50 10 125 30 30 60 -1 100], 'Heights', 20);
set(fb(2).p(1).vb(1).h , 'Heights', [-1 64]);

% Split in ROI and parameter part
fb(2).g(1).params.vb(1).h = uix.VBox('Parent', fb(2).g(1).params.h, 'Spacing', 10);

% ROI controls
g = uix.Grid('Parent', fb(2).g(1).params.vb(1).h);
g1 = uix.Grid('Parent', g, 'Spacing', 3);

uicontrol('Parent', g1, 'Style', 'text', 'String', 'ROI', ...
    'HorizontalAlignment', 'left')
uicontrol('Parent', g1, 'Style', 'Edit', 'String', '', ...
    'Tag', 'ed_ROI', 'Callback', {@updateROI, 'update'})
uicontrol('Parent', g1, 'Style', 'Pushbutton', 'String', 'Set', ...
    'Tag', 'pb_ROIset', 'Callback', {@updateROI, 'set'})
uicontrol('Parent', g1, 'Style', 'Pushbutton', 'String', 'Clear', ...
    'Tag', 'pb_ROIclear', 'Callback', {@updateROI, 'clear'})
uicontrol('Parent', g1, 'Style', 'Pushbutton', 'String', 'Apply to all', ...
    'Tag', 'pb_ROIapplyAll', 'Callback', {@updateROI, 'applyAll'})
uix.Empty('Parent', g1);


set(g1, 'Widths', [30, -1, 28, 36, 65, 5], 'Heights', 20);
uicontrol('Parent', g, 'Style', 'text', 'String', 'Define a region of interest [x y width height]', ...
    'HorizontalAlignment', 'left', 'FontAngle', 'italic')
set(g, 'Widths', -1, 'Heights', [20 40]);

% Create Segmentation vs tracking tabs
tabGroup = uitabgroup('Parent', fb(2).g(1).params.vb(1).h);
tabs(1).h = uitab('Parent', tabGroup, 'Title', 'Segmentation');
tabs(2).h = uitab('Parent', tabGroup, 'Title', 'Tracking');
tabs(3).h = uitab('Parent', tabGroup, 'Title', 'Display');
tabs(4).h = uitab('Parent', tabGroup, 'Title', 'Advanced');

% Populate Cell/stalk detection/Right
g = uix.Grid('Parent', tabs(1).h, 'Padding', 5);

parameters = {'Cell size', mean_cell_size, 'px', 'Typical cell diameter', 'Edit', [5 200], 'integer';...
              'Min cell size', min_cell_size, 'px', 'Minimum cell diameter', 'Edit', [5 200], 'integer';...
              'Cell expansion width', '2', 'px', 'Cell is expanded by this length to search for the stalk attachment point', 'Edit', [1 10], 'integer';...
              'Stalk screening length', '150', 'px', 'Maximum stalk screening distance', 'Edit', [1 1000], 'integer';...
              'Min stalk length', '5', 'px', 'Minimum stalk length', 'Edit', [0 1000], 'integer';...
              'Max stalk flexibility', '2', '', {'Maximum stalk flexibility [length/end-to-end distance]', '1: very rigid, 5: very flexible'}, 'Edit', [1 5], 'float';...
              'Stalk screening width', '3', 'px', 'Width of stalk intensity minima', 'Edit', [2 5], 'integer';...
              'Stalk sensitivity', '1', '', {'Sensitivity of stalk propagation', '0.1: high sensitivity, 2: low sensitivity'}, 'Edit', [0 2], 'float';...
              'Exclude cells close by', true, '', 'Delete cells which are too close by', 'Checkbox', [], 'boolean'};
%'Detect stalks', true, '', 'Turn stalk/bud detection on/off', 'Checkbox', '', 'boolean';...         

heights = generateParameters(g, parameters);
CellSize_h = findobj(data.mainFigure, 'Tag', 'CellSize');
CellSize_h.Callback = {@updateROI, 'update'};

%DetectStalks_h = findobj(data.mainFigure, 'Tag', 'DetectStalks');
%DetectStalks_h.Callback = @toggleDetectStalks;

set(g, 'Widths', -1, 'Heights', heights);
tabHeights(1) = sum(repmat([20,40], 1, size(parameters,1)))+100;

% Populate Cell tracking/Right
g = uix.Grid('Parent', tabs(2).h, 'Padding', 5);
parameters = {'Search radius', search_radius, 'px', 'Cells inside the search radius are considered (px)', 'Edit', [0 100], 'float';...
              'Dilation width', dilation_width, 'px', 'Cell dilation (px) before comparing overlap', 'Edit', [0 100], 'integer'};
heights = generateParameters(g, parameters);
uicontrol('Parent', g, 'Style', 'text', 'String', 'Be aware: only binary fission is taken into account (not stalked budding)!', ...
    'HorizontalAlignment', 'left', 'FontAngle', 'italic')
set(g, 'Widths', -1, 'Heights', [heights 30]);
tabHeights(2) = sum(repmat([20,40], 1, size(parameters,1)))+130;

% Populate Display/Right
g = uix.Grid('Parent', tabs(3).h, 'Padding', 5);
parameters = {'Overlay font size', '10', 'points', 'Font size of cellID / trackID', 'Edit', [1 50], 'float';...
              'Line width', '0.75', 'points', 'Line widths of overlays', 'Edit', [0.5 10], 'float';...
              'Plot resolution', '2', 'px', '1: high resolution (slow), 5: low resolution (fast)', 'Edit', [1 5], 'integer';...
              'Show trackID', 1, '', {'Show trackID after cell tracking'}, 'Checkbox', [], [];...
              'Text color', [1 1 1] '', '', 'Color', [], [];...
              'Cell outline color', [0 1 0], '', '', 'Color', [], [];...
              'Medial axis color', [1 1 0], '', '', 'Color', [], [];...
              'Cell pole color', [1 1 0], '', '', 'Color', [], [];...
              'Stalk color 1', [0 0 1], '', '', 'Color', [], [];...
              'Stalk color 2', [1 0 0], '', '', 'Color', [], [];...
              'Trajectory color', [1 0 1], '', '', 'Color', [], [];...
              'Deleted object color', [0 0 0], '', '', 'Color', [], [];...
              'ROI color', [0.64 0.08 0.18], '', '', 'Color', [], []};
heights = generateParameters(g, parameters);
set(g, 'Widths', -1, 'Heights', heights);
tabHeights(3) = sum(repmat([20,40], 1, size(parameters,1)))+100;

set(s,'ProgressRatio', 0.6);

% Assign Callbacks
fontSize_h = findobj(data.mainFigure, 'tag', 'OverlayFontSize');
fontSize_h.Callback = @displayImage;
lineWidth_h = findobj(data.mainFigure, 'tag', 'LineWidth');
lineWidth_h.Callback = @displayImage;
showTrackID_h = findobj(data.mainFigure, 'tag', 'ShowTrackID');
showTrackID_h.Callback = @displayImage;
plotResolution_h = findobj(data.mainFigure, 'tag', 'PlotResolution');
plotResolution_h.Callback = @displayImage;

% Populate Other/Right
g = uix.Grid('Parent', tabs(4).h, 'Padding', 5);
parameters = {'Parallel processing', 1, '', {'Use multiple CPU cores',  '(requries ParallelToolbox)'}, 'Checkbox', [], [];...
              'Debugging', 0, '', 'Show debugging information', 'Checkbox', [], [];...
              'Cell channel', {'PhaseContrast'}, 1, 'Select channel containing cells', 'Popupmenu', [], [];...
              'Use binary masks', 0, '', 'Check, if images are containing pre-segmented binary masks obtained by 3rd-party software.', 'Checkbox', [], [];...
              'Cell background', {'Bright', 'Dark'}, 1, 'Select ''bright'', if cells are darker than the background (phase-contrast) and ''dark'' otherwise (fluorescence).', 'Popupmenu', [], [];...
              'Stalk channel', {'PhaseContrast'}, 1, 'Select channel containing stalks (usually the same as the cell channel)', 'Popupmenu', [], [];...
              'Stalk background', {'Bright', 'Dark'}, 1, 'Select ''bright'', if stalks are darker than the background (phase-contrast) and ''dark'' otherwise (fluorescence).', 'Popupmenu', [], []};
heights = generateParameters(g, parameters);
set(g, 'Widths', -1, 'Heights', heights);
tabHeights(3) = sum(repmat([20,40], 1, size(parameters,1)))+100;

UseBinaryMasks_h = findobj(data.mainFigure, 'Tag', 'UseBinaryMasks');
UseBinaryMasks_h.Callback = @toggeUseBinaryMasks;

set(fb(2).g(1).params.h, 'Heights', max(tabHeights), 'Widths', 265);
fb(2).g(1).params.vb(1).h.Heights = [50, -1];

% Add progress bar
% g = uix.Grid('Parent', fb(2).g(1).progress.h, 'Padding', 0, 'Spacing', 5); 
% data.axes.progress = axes('Parent', g, 'ActivePositionProperty', 'Position');
% removeAxis(data.axes.progress);
% uicontrol('Parent', g, 'Style', 'Text', 'String', '', ...
%     'HorizontalAlignment', 'left', 'FontAngle', 'italic', 'Tag', 'ed_progress')
% data.ui.cb = uicontrol('Parent', g, 'Style', 'Pushbutton', 'String', 'Cancel', ...
%     'HorizontalAlignment', 'center', 'Callback', @cancelProcessing, 'Tag', 'pb_cancel', 'Enable', 'off', 'UserData', false, 'Visible', 'on');
% uix.Empty('Parent', g);
% set(g, 'Widths', [-1 40], 'Heights', [-1 15]);

vb = uix.VBox('Parent', fb(2).g(1).progress.h, 'Padding', 0, 'Spacing', 5); 
g = uix.HBox('Parent', vb, 'Padding', 0, 'Spacing', 5); 
uicontrol('Parent', g, 'Style', 'Text', 'String', '', ...
    'HorizontalAlignment', 'left', 'FontAngle', 'italic', 'Tag', 'ed_progress')
g = uix.HBox('Parent', vb, 'Padding', 0, 'Spacing', 5); 
data.axes.progress = axes('Parent', g, 'ActivePositionProperty', 'Position');
removeAxis(data.axes.progress);
data.ui.cb = uicontrol('Parent', g, 'Style', 'Pushbutton', 'String', 'Cancel', ...
    'HorizontalAlignment', 'center', 'Callback', @cancelProcessing, 'Tag', 'pb_cancel', 'Enable', 'off', 'UserData', false, 'Visible', 'on');
set(g, 'Widths', [-1 40]);
set(vb, 'Heights', [-1 15]);

% Add control elements
g = uix.Grid('Parent', fb(2).g(1).controls.h, 'Padding', 0);
% First button-row (Processing)
bb = uix.HButtonBox('Parent', g, 'VerticalAlignment', 'top' ,...
     'HorizontalAlignment', 'center', 'ButtonSize', [200, 30]);
uicontrol('Parent', bb, 'Style', 'Pushbutton', 'String', 'Process image', ...
    'HorizontalAlignment', 'left', 'Callback', {@processImages, 'selected'})%, 'BusyAction','cancel', 'Interruptible', 'off')
uicontrol('Parent', bb, 'Style', 'Pushbutton', 'String', 'Process all images', ...
    'HorizontalAlignment', 'left', 'Callback', {@processImages, 'all'})%, 'BusyAction','cancel', 'Interruptible', 'off')
% Second button-row (Tracking)
bb = uix.HButtonBox('Parent', g, 'VerticalAlignment', 'top' ,...
     'HorizontalAlignment', 'center', 'ButtonSize', [200, 30]);
uicontrol('Parent', bb, 'Style', 'Pushbutton', 'String', 'Track cells', ...
    'HorizontalAlignment', 'left', 'Callback', @trackCells, ...
    'Tag', 'pb_trackCells', 'BusyAction','cancel', 'Enable', 'off', 'Interruptible', 'off')
uicontrol('Parent', bb, 'Style', 'Pushbutton', 'String', 'Show tracks', ...
    'HorizontalAlignment', 'left', 'Callback', @showTracks, ...
    'Tag', 'pb_showTracks', 'BusyAction','cancel', 'Enable', 'off', 'Interruptible', 'off')
set(g, 'Widths', -1, 'Heights', [-1 -1]);


% Add navigation buttons
bb = uix.HButtonBox('Parent', fb(2).g(1).nav.h, 'VerticalAlignment', 'top' ,...
     'HorizontalAlignment', 'center', 'ButtonSize', [200, 30]);
uicontrol('Parent', bb, 'Style', 'Pushbutton', 'String', '< Step 1: Input', ...
    'HorizontalAlignment', 'left', 'Callback', @showInputTab, 'BusyAction','queue','Interruptible', 'off')
uicontrol('Parent', bb, 'Style', 'Pushbutton', 'String', 'Step 3: Analysis >', ...
    'HorizontalAlignment', 'left', 'Callback', @showAnalysisTab, 'BusyAction','queue','Interruptible', 'off')

%% Analysis
fb(3).h = uix.HBoxFlex('Parent', t(3).h, 'Padding', 5, 'Spacing', 5);

% Left part
fb(3).g(1).h = uix.GridFlex('Parent', fb(3).h, 'Padding', 0, 'Spacing', 5);
fb(3).g(1).vb(1).h = uix.VBox('Parent', fb(3).g(1).h, 'Padding', 0, 'Spacing', 5);
% Buttons on top of cells list
g = uix.Grid('Parent', fb(3).g(1).vb(1).h, 'Spacing', 5);
uicontrol('Parent', g, 'Style', 'Text', 'String', 'Show', ...
    'HorizontalAlignment', 'left')
uicontrol('Parent', g, 'Style', 'Popupmenu', 'String', data.settings.displayCellOptions{3}, ...
    'HorizontalAlignment', 'left', 'Tag', 'popm_showCellType', 'Callback', @showCellType,...
    'BackgroundColor', [0.6784 0.9176 0.8549], 'FontWeight', 'bold')
uicontrol('Parent', g, 'Style', 'Pushbutton', 'String', 'Refresh', ...
    'HorizontalAlignment', 'center', 'Tag', 'pb_refreshResultsTable', 'Callback', @refreshResultsTable)
uix.Empty('Parent', g);

uicontrol('Parent', g, 'Style', 'Pushbutton', 'String', 'Select measurements', ...
    'HorizontalAlignment', 'center', 'Tag', 'pb_selectMeasurements', 'Callback', @selectMeasurements)
uix.Empty('Parent', g);

uicontrol('Parent', g, 'Style', 'Checkbox', 'String', 'Filter cell table by', ...
    'HorizontalAlignment', 'left', 'Callback', @updateFilterCells, 'Tag', 'cb_filterCells')
uicontrol('Parent', g, 'Style', 'Popupmenu', 'String', 'CellID', ...
    'HorizontalAlignment', 'left', 'Tag', 'popm_filterCellField', 'Callback', @updateFilterCells)
uicontrol('Parent', g, 'Style', 'Popupmenu', 'String', {'<', '<=', '==', '>=', '>', '~='}, ...
    'HorizontalAlignment', 'left', 'Tag', 'popm_filterOperator', 'Callback', @updateFilterCells)
uicontrol('Parent', g, 'Style', 'Edit', 'String', '1', ...
    'HorizontalAlignment', 'center', 'Tag', 'popm_filterValue', 'Callback', @updateFilterCells)
uix.Empty('Parent', g);

uicontrol('Parent', g, 'Style', 'Pushbutton', 'String', 'Show selected cell', ...
    'HorizontalAlignment', 'center', 'Tag', 'pb_showCells', 'Callback', @showCellsAnalysisTable)

set(g, 'Widths', [40 240 60 -1 120 -1 120 120 40 40 -1 120], 'Heights', -1);

set(s,'ProgressRatio', 0.7);

% Cell list
fb(3).g(1).vb(1).cellList.h = uix.BoxPanel('Parent', fb(3).g(1).vb(1).h, 'Title', 'Cell list', 'Padding', 5, ...
    'TitleColor', tabColor, 'ForegroundColor', 'black', 'HelpFcn', {@openHelp, 'usage/analysis.html'});
fb(3).g(1).vb(1).h.Heights = [20 -1];
fb(3).g(1).hb(1).h = uix.HBoxFlex('Parent', fb(3).g(1).h, 'Padding', 0, 'Spacing', 5);

% Cell table context menu
fb(3).g(1).bg(1).cellList.contextMenu = uicontextmenu(data.mainFigure);
uimenu(fb(3).g(1).bg(1).cellList.contextMenu, 'Label', 'Select displayed measurements', 'Callback', @selectMeasurements);

% Statistics
fb(3).g(1).hb(1).cellTable.h = uix.BoxPanel('Parent', fb(3).g(1).hb(1).h, 'Title', 'Statistics', 'Padding', 5, ...
    'TitleColor', tabColor, 'ForegroundColor', 'black');
% Track Table
fb(3).g(1).hb(1).trackTable.h  = uix.BoxPanel('Parent', fb(3).g(1).hb(1).h, 'Title', 'Tracks', 'Padding', 5, ...
    'TitleColor', tabColor, 'ForegroundColor', 'black');
fb(3).g(1).hb(1).h.Widths = [-1, 300];
set(fb(3).g(1).h, 'Heights', [-3 -1], 'Widths', -1);


% Right part
fb(3).vb(1).h = uix.VBox('Parent', fb(3).h, 'Spacing', 5);

% Analysis
fb(3).vb(1).analysis.h = uix.BoxPanel('Parent', fb(3).vb(1).h, 'Title', 'Data visualization', 'Padding', 5, ...
    'TitleColor', tabColor, 'ForegroundColor', 'black', 'HelpFcn', {@openHelp, 'usage/analysis.html#data-visualization'});


fb(3).vb(1).analysis.sc = uix.ScrollingPanel('Parent', fb(3).vb(1).analysis.h);
g = uix.Grid('Parent', fb(3).vb(1).analysis.sc, 'Spacing', 5);
% Histogram
p = uix.Panel('Parent', g, 'Title', 'Histogram', 'Padding', 10, 'FontWeight', 'bold');
g1 = uix.Grid('Parent', p, 'Spacing', 8);
% Left
uicontrol('Parent', g1, 'Style', 'Text', 'String', 'Measurement', ...
    'HorizontalAlignment', 'left')
uicontrol('Parent', g1, 'Style', 'Text', 'String', 'Bins', ...
    'HorizontalAlignment', 'left')
% uicontrol('Parent', g1, 'Style', 'Text', 'String', 'Log scale X', ...
%     'HorizontalAlignment', 'left')
% uicontrol('Parent', g1, 'Style', 'Text', 'String', 'Log scale Y', ...
%     'HorizontalAlignment', 'left')
uix.Empty('Parent', g1);
% Right
uicontrol('Parent', g1, 'Style', 'Popupmenu', 'String', 'None', ...
    'HorizontalAlignment', 'left', 'Tag', 'popm_histo_measurement')
uicontrol('Parent', g1, 'Style', 'Edit', 'String', '10', ...
    'HorizontalAlignment', 'left', 'Tag', 'ed_histo_spacing')
% uicontrol('Parent', g1, 'Style', 'Checkbox', 'String', '', ...
%     'HorizontalAlignment', 'left', 'Tag', 'cb_histo_xscale')
% uicontrol('Parent', g1, 'Style', 'Checkbox', 'String', '', ...
%     'HorizontalAlignment', 'left', 'Tag', 'cb_histo_yscale')
uicontrol('Parent', g1, 'Style', 'Pushbutton', 'String', 'Create', ...
    'HorizontalAlignment', 'center', 'Callback', @createHistogram)
set(g1, 'Heights', [20, 20, 20], 'Widths', [-1, -1]);

% Scatterplot
p = uix.Panel('Parent', g, 'Title', 'Scatterplot', 'Padding', 10, 'FontWeight', 'bold');
g1 = uix.Grid('Parent', p, 'Spacing', 8);
% Left
uicontrol('Parent', g1, 'Style', 'Text', 'String', 'Measurement (X)', ...
    'HorizontalAlignment', 'left')
uicontrol('Parent', g1, 'Style', 'Text', 'String', 'Measurement (Y)', ...
    'HorizontalAlignment', 'left')
uicontrol('Parent', g1, 'Style', 'Text', 'String', 'Log scale X', ...
    'HorizontalAlignment', 'left')
uicontrol('Parent', g1, 'Style', 'Text', 'String', 'Log scale Y', ...
    'HorizontalAlignment', 'left')
uix.Empty('Parent', g1);
% Right
uicontrol('Parent', g1, 'Style', 'Popupmenu', 'String', 'None', ...
    'HorizontalAlignment', 'left', 'Tag', 'popm_scatter_measurementX')
uicontrol('Parent', g1, 'Style', 'Popupmenu', 'String', 'None', ...
    'HorizontalAlignment', 'left', 'Tag', 'popm_scatter_measurementY')
uicontrol('Parent', g1, 'Style', 'Checkbox', 'String', '', ...
    'HorizontalAlignment', 'left', 'Tag', 'cb_scatter_scaleX')
uicontrol('Parent', g1, 'Style', 'Checkbox', 'String', '', ...
    'HorizontalAlignment', 'left', 'Tag', 'cb_scatter_scaleY')
uicontrol('Parent', g1, 'Style', 'Pushbutton', 'String', 'Create', ...
    'HorizontalAlignment', 'center', 'Callback', @createScatterplot)
set(g1, 'Heights', [20, 20, 20, 20, 20], 'Widths', [-1, -1]);

set(s,'ProgressRatio', 0.8);

% Demograph
p = uix.Panel('Parent', g, 'Title', 'Demograph', 'Padding', 10, 'FontWeight', 'bold');
g1 = uix.Grid('Parent', p, 'Spacing', 8);
% Left
uicontrol('Parent', g1, 'Style', 'Text', 'String', 'Alignment', ...
    'HorizontalAlignment', 'left')
uicontrol('Parent', g1, 'Style', 'Text', 'String', 'Measurement', ...
    'HorizontalAlignment', 'left')
uicontrol('Parent', g1, 'Style', 'Text', 'String', 'Type', ...
    'HorizontalAlignment', 'left')
uicontrol('Parent', g1, 'Style', 'Text', 'String', 'Orientate cells', ...
    'HorizontalAlignment', 'left')
uicontrol('Parent', g1, 'Style', 'Text', 'String', 'What to plot', ...
    'HorizontalAlignment', 'left')
uicontrol('Parent', g1, 'Style', 'Text', 'String', 'Sort by', ...
    'HorizontalAlignment', 'left')
uicontrol('Parent', g1, 'Style', 'Text', 'String', 'Colormap', ...
    'HorizontalAlignment', 'left')
uicontrol('Parent', g1, 'Style', 'Text', 'String', 'Subtract background', ...
    'HorizontalAlignment', 'left')
uicontrol('Parent', g1, 'Style', 'Text', 'String', 'Intensity normalization', ...
    'HorizontalAlignment', 'left')
uicontrol('Parent', g1, 'Style', 'Text', 'String', 'Highlight maxima', ...
    'HorizontalAlignment', 'left')
uicontrol('Parent', g1, 'Style', 'Text', 'String', 'Show full cell width', ...
    'HorizontalAlignment', 'left')
uix.Empty('Parent', g1);
% Right
uicontrol('Parent', g1, 'Style', 'Popupmenu', 'String', data.settings.algnmentOptions{1}, ...
    'HorizontalAlignment', 'left', 'Tag', 'popm_demo_alignment')
uicontrol('Parent', g1, 'Style', 'Popupmenu', 'String', 'None', ...
    'HorizontalAlignment', 'left', 'Tag', 'popm_demo_measurement')
uicontrol('Parent', g1, 'Style', 'Popupmenu', 'String', {'Mean', 'Max'}, ...
    'HorizontalAlignment', 'left', 'Tag', 'popm_demo_type', 'Callback', {@toggleMeasurementType, 'demo'})
uicontrol('Parent', g1, 'Style', 'Popupmenu', 'String', {'Unchanged',...
    'Intensity maxima first', 'Intensity maxima last'}, 'Tag', 'popm_demo_orientCells')
uicontrol('Parent', g1, 'Style', 'Popupmenu', 'String', {'Cells displayed in table', 'Selected cells in table'}, ...
    'HorizontalAlignment', 'left', 'Tag', 'popm_demo_plotRange')
uicontrol('Parent', g1, 'Style', 'Popupmenu', 'String', data.settings.sortOptions{1}, ...
    'HorizontalAlignment', 'left', 'Tag', 'popm_demo_sortMode')
uicontrol('Parent', g1, 'Style', 'Popupmenu', 'String', {'Gray',...
    'RedBlue', 'Parula', 'Jet', 'Hsv', 'Hot'}, 'Tag', 'popm_demo_colormap')
uicontrol('Parent', g1, 'Style', 'Checkbox', 'String', '', ...
    'HorizontalAlignment', 'left', 'Tag', 'cb_demo_subtractBackground')
uicontrol('Parent', g1, 'Style', 'Checkbox', 'String', '', ...
    'HorizontalAlignment', 'left', 'Tag', 'cb_demo_intensityNormalization')
uicontrol('Parent', g1, 'Style', 'Checkbox', 'String', '', ...
    'HorizontalAlignment', 'left', 'Tag', 'cb_demo_highlightMaxima')
uicontrol('Parent', g1, 'Style', 'Checkbox', 'String', '', ...
    'HorizontalAlignment', 'left', 'Tag', 'cb_demo_showFullCellWith', 'Callback', {@toggleMeasurementType, 'demo'})
uicontrol('Parent', g1, 'Style', 'Pushbutton', 'String', 'Create', ...
    'HorizontalAlignment', 'center', 'Callback', @createDemograph)
set(g1, 'Heights', [20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20], 'Widths', [-1, -1]);

% Kymograph
p = uix.Panel('Parent', g, 'Title', 'Kymograph', 'Padding', 10, 'Tag', 'panel_kymograph', 'Visible', 'off', 'FontWeight', 'bold');
g1 = uix.Grid('Parent', p, 'Spacing', 8);
% Left
uicontrol('Parent', g1, 'Style', 'Text', 'String', 'Track ID', ...
    'HorizontalAlignment', 'left')
uicontrol('Parent', g1, 'Style', 'Text', 'String', 'Frame range', ...
    'HorizontalAlignment', 'left')
uicontrol('Parent', g1, 'Style', 'Text', 'String', 'Alignment', ...
    'HorizontalAlignment', 'left')
uicontrol('Parent', g1, 'Style', 'Text', 'String', 'Measurement', ...
    'HorizontalAlignment', 'left')
uicontrol('Parent', g1, 'Style', 'Text', 'String', 'Type', ...
    'HorizontalAlignment', 'left')
uicontrol('Parent', g1, 'Style', 'Text', 'String', 'Orientate cells', ...
    'HorizontalAlignment', 'left')
uicontrol('Parent', g1, 'Style', 'Text', 'String', 'Colormap', ...
    'HorizontalAlignment', 'left')
uicontrol('Parent', g1, 'Style', 'Text', 'String', 'Subtract background', ...
    'HorizontalAlignment', 'left')
uicontrol('Parent', g1, 'Style', 'Text', 'String', 'Intensity normalization', ...
    'HorizontalAlignment', 'left')
uicontrol('Parent', g1, 'Style', 'Text', 'String', 'Highlight maxima', ...
    'HorizontalAlignment', 'left')
uicontrol('Parent', g1, 'Style', 'Text', 'String', 'Show full cell width', ...
    'HorizontalAlignment', 'left')
uix.Empty('Parent', g1);
% Right
uicontrol('Parent', g1, 'Style', 'Edit', 'String', '1', ...
    'HorizontalAlignment', 'left', 'Tag', 'ed_kymo_trackID', 'Callback', @checkInput, 'UserData', {'1', [], []})

g2 = uix.Grid('Parent', g1, 'Spacing', 5);
uicontrol('Parent', g2, 'Style', 'Edit', 'String', '1', ...
    'HorizontalAlignment', 'left', 'Tag', 'ed_kymo_trackStart', 'Callback', @checkInput, 'UserData', {'1', [], []})
uicontrol('Parent', g2, 'Style', 'Text', 'String', 'until', ...
    'HorizontalAlignment', 'left')
uicontrol('Parent', g2, 'Style', 'Edit', 'String', '2', ...
    'HorizontalAlignment', 'left', 'Tag', 'ed_kymo_trackEnd', 'Callback', @checkInput, 'UserData', {'1', [], []})

uicontrol('Parent', g1, 'Style', 'Popupmenu', 'String', data.settings.algnmentOptions{1}, ...
    'HorizontalAlignment', 'left', 'Tag', 'popm_kymo_alignment')
uicontrol('Parent', g1, 'Style', 'Popupmenu', 'String', 'None', ...
    'HorizontalAlignment', 'left', 'Tag', 'popm_kymo_measurement')
uicontrol('Parent', g1, 'Style', 'Popupmenu', 'String', {'Mean', 'Max'}, ...
    'HorizontalAlignment', 'left', 'Tag', 'popm_kymo_type', 'Callback', {@toggleMeasurementType, 'kymo'})
uicontrol('Parent', g1, 'Style', 'Popupmenu', 'String', {'Unchanged',...
    'Intensity maxima first', 'Intensity maxima last'}, 'Tag', 'popm_kymo_orientCells')
uicontrol('Parent', g1, 'Style', 'Popupmenu', 'String', {'Gray',...
    'RedBlue', 'Parula', 'Jet', 'Hsv', 'Hot'}, 'Tag', 'popm_kymo_colormap')
uicontrol('Parent', g1, 'Style', 'Checkbox', 'String', '', ...
    'HorizontalAlignment', 'left', 'Tag', 'cb_kymo_subtractBackground')
uicontrol('Parent', g1, 'Style', 'Checkbox', 'String', '', ...
    'HorizontalAlignment', 'left', 'Tag', 'cb_kymo_intensityNormalization')
uicontrol('Parent', g1, 'Style', 'Checkbox', 'String', '', ...
    'HorizontalAlignment', 'left', 'Tag', 'cb_kymo_highlightMaxima')
uicontrol('Parent', g1, 'Style', 'Checkbox', 'String', '', ...
    'HorizontalAlignment', 'left', 'Tag', 'cb_kymo_showFullCellWith', 'Callback', {@toggleMeasurementType, 'kymo'})
uicontrol('Parent', g1, 'Style', 'Pushbutton', 'String', 'Create', ...
    'HorizontalAlignment', 'center', 'Callback', @createKymograph)
set(g1, 'Heights', [20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20], 'Widths', [-1, -1]);

set(g, 'Heights', [115 172 367 367], 'Widths', -1);
fb(3).vb(1).analysis.sc.Heights = sum(g.Heights(1:3))+20;

set(s,'ProgressRatio', 0.9);

% Navigation
fb(3).vb(1).nav.h = uix.BoxPanel('Parent', fb(3).vb(1).h, 'Title', 'Navigation', 'Padding', 5, ...
    'TitleColor', [1.0000 0.6784 0.64310], 'ForegroundColor', 'black');
set(fb(3).vb(1).h, 'Heights', [-1 70]);

fb(3).h.Widths = [-1 300];

% Populate Analysis/Left
[jtable, jscrollpane] = createJavaTable(fb(3).g(1).vb(1).cellList.h, @clickAnalysisTable);
data.tables.tableAnalysis = {jtable, jscrollpane};
set(handle(jtable.getModel, 'CallbackProperties'), 'IndexChangedCallback', @calculateStatistics)

[jtable, jscrollpane] = createJavaTable(fb(3).g(1).hb(1).cellTable.h, []);
data.tables.tableStatistics = {jtable, jscrollpane};

[jtable, jscrollpane] = createJavaTable(fb(3).g(1).hb(1).trackTable.h, {@clickTrackTable, 'analysisTab'});
data.tables.tableSelectedTrack = {jtable, jscrollpane};




% Populate Analysis/Right
% Parameters
data.ui.sc = sc;
data.ui.fb = fb;
data.ui.m = m;

% Add navigation buttons
bb = uix.HButtonBox('Parent', fb(3).vb(1).nav.h, 'VerticalAlignment', 'top' ,...
     'HorizontalAlignment', 'center', 'ButtonSize', [200, 30]);
uicontrol('Parent', bb, 'Style', 'Pushbutton', 'String', '< Step 2: Cell/Stalk detection', ...
    'HorizontalAlignment', 'left', 'Callback', @showCellDetectionTab, 'BusyAction','queue','Interruptible', 'off')

% Center all text fields
texts_h = findobj(data.mainFigure, 'Type', 'Text');
for i = 1:numel(texts_h)
    jh = findjobj(text_h(i));
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER)
end

set(s,'ProgressRatio', 1);

% Make figure visible
f.Visible = 'on';
setUIData(f, data);

% Time resets the mouse pointer to "arrow" if Matlab is not busy in case it does not switch back
t = timer( 'ExecutionMode','fixedSpacing', 'Period', 10, ...
    'BusyMode','drop', 'Name', 'ResetMoisePointer', ...
    'TimerFcn',{@isBusy, data.mainFigure, data.ui.cb}, 'Tag', 'timer_busy');

start(t)

deleteSplashScreen(s);