"""
Utilities to compute pili distribution and fluorescence localization of motors and response regulator PilG.
"""

import os
import glob
import numpy as np
import bokeh.io
import bokeh.plotting
import bokeh.palettes
from bokeh.transform import jitter
import seaborn as sns
import matplotlib
from bokeh.models import HoverTool
from scipy import stats
import pandas as pd
import random

from bokeh.io import output_file, show
from bokeh.models import ColumnDataSource
from bokeh.plotting import figure
from bokeh.transform import dodge

import matplotlib
import matplotlib.pyplot as plt

from bokeh.layouts import row


def persentage_difference_biorep(df_in, nb_pili_threshold):
    df_raw=df_in
    df_raw['TotalPili']=df_raw['Nb_Pili_PoleBright']+df_raw['Nb_Pili_PoleDim']
    df_temp=df_raw.loc[df_raw['TotalPili']>nb_pili_threshold]
    biorep=df_temp.BiologicalReplicate.unique()
    N_cells_morePiliBright=[None]*len(biorep)
    N_cells_morePiliDim=[None]*len(biorep)
    N_cells_samePili=[None]*len(biorep)
    #n=len(NPili_DimPole)
    n=[None]*len(biorep)
    persentage_piliBright=[None]*len(biorep)
    persentage_piliDim=[None]*len(biorep)
    persentage_samepili=[None]*len(biorep)
    for br in biorep:
        df=df_temp.loc[df_raw['BiologicalReplicate']== br]
        NPili_DimPole=np.array(df.Nb_Pili_PoleDim)
        NPili_BrightPole=np.array(df.Nb_Pili_PoleBright)
        pili_nb_diff=[]
        fluo_diff=[]
        cells_morePiliBright=[]
        cells_morePiliDim=[]                                                     
        cells_samePili=[]
        for i in range(len(NPili_DimPole)):
            if(NPili_BrightPole[i]!=0 or NPili_DimPole[i] != 0):
                if(NPili_BrightPole[i] > NPili_DimPole[i]):
                    cells_morePiliBright.append(1)
                    cells_morePiliDim.append(0)
                    cells_samePili.append(0)
                elif (NPili_BrightPole[i] < NPili_DimPole[i]):
                    cells_morePiliBright.append(0)
                    cells_morePiliDim.append(1)
                    cells_samePili.append(0)
                else:
                    cells_morePiliBright.append(0)
                    cells_morePiliDim.append(0)
                    cells_samePili.append(1)
        N_cells_morePiliBright[br-1]=sum(cells_morePiliBright)
        N_cells_morePiliDim[br-1]=sum(cells_morePiliDim)
        N_cells_samePili[br-1]=sum(cells_samePili)
        n[br-1]=len(cells_morePiliBright)
        persentage_piliBright[br-1]=N_cells_morePiliBright[br-1]/n[br-1]
        persentage_piliDim[br-1]=N_cells_morePiliDim[br-1]/n[br-1]
        persentage_samepili[br-1]=N_cells_samePili[br-1]/n[br-1]
    return persentage_piliBright, persentage_piliDim, persentage_samepili, N_cells_morePiliBright, N_cells_morePiliDim, N_cells_samePili, n

def plot_mean(piliDim, p, x_loc):
    for i in range(len(piliDim)):
        pos=x_loc+i
        p.line(
            y=[pos-0.1, pos+0.1],
            x=[piliDim[i], piliDim[i]], 
            line_color = 'black',
            line_width = 4,
            alpha=1
        )
        
def plot_data(piliDim, p, x_loc, color, filling, jitter_width, legends):
    if filling is True:
        fill=color
    else:
        fill=[None]*len(piliDim)
    for i in range(len(piliDim)):
        pos=x_loc+i
        for j in range(len(piliDim[i])):
            p.circle(
                y=pos+random.uniform(-jitter_width, jitter_width),
                x=piliDim[i][j], 
                line_color = color[i],
                fill_color = fill[i],
                size = 10,
                legend_label = legends,
                alpha=0.8
            )

print('pili_fluo_utils loaded successfully')