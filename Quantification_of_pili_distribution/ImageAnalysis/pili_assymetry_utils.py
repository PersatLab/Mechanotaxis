"""
Utilities to analyze pili assymetric distribution between the two poles of a bacterium
The csv files must be called "exportedData_<strain-name-with-dash-separation>_<Fluorescent-reporter-with-dash-separation>_<growth-condition>_BR=<biological-replicate-number>.csv"
As an example: "exportedData_fliC-_PaQa_liq_BR=1.csv"
"""
import os
import glob
import numpy as np

import matplotlib.pyplot as plt
import pandas as pd
import math

def getProbs(csv_file, save_csv_name, tot_pili_limit, nb_pili_differences, strain):
    df_raw = pd.read_csv(csv_file, sep=',', na_values='*')
    df_full = df_raw.loc[df_raw['Strain'] == strain]
    df_full=df_full.assign(TotalPili=df_full['Nb_Pili_PoleBright']+df_full['Nb_Pili_PoleDim'])
    df = df_full.loc[df_full['TotalPili'] > 1]
    df=df_full.assign(DeltaPili=(df['Nb_Pili_PoleBright']-df['Nb_Pili_PoleDim']).abs())
    a=[None]*tot_pili_limit
    b=[None]*tot_pili_limit
    n=[None]*tot_pili_limit
    assym=[None]*tot_pili_limit
    probs=np.zeros([nb_pili_differences,tot_pili_limit])
    for n_pili in range(tot_pili_limit):
        df_temp=df.loc[df['TotalPili'] == n_pili+2]
        n[n_pili]=len(df_temp)
        if(n[n_pili]>0):
            a[n_pili]=len(df_temp.loc[df['DeltaPili'] == 0])
            b[n_pili]=len(df_temp.loc[df['DeltaPili'] > 0])
            assym[n_pili]=b[n_pili]/n[n_pili]
            for delta in range(nb_pili_differences):
                #print('For '+ str(delta)+' pili difference, there are '+str(len(df_temp.loc[df_temp['DeltaPili'] == delta]))+' cells and '+str(n[n_pili])+' cells that have '+str(n_pili+2)+'pili')
                probs[delta, n_pili]=len(df_temp.loc[df_temp['DeltaPili'] == delta])/n[n_pili]
        else:
            assym[n_pili]=0
            for delta in range(nb_pili_differences):
                probs[delta, n_pili]=0
            
    pili=np.arange(2,tot_pili_limit+2)
    df_probs=pd.DataFrame(probs, columns = list(pili))
    df_probs.to_csv( save_csv_name, index=False, encoding='utf-8-sig')
    return pili, assym, n, probs, df_probs
    
def plot_pili_comparison(ax, pili_number, diff_number, probs_fliC, probs_pilGcpdAfliC, probs_cpdAfliC, probs_pilHcyaBfliC, probs, y_label):
    ax.set_ylim(0,1)
    ax.set_xlim(0,5)
    ind_row=diff_number+1
    ind_col=pili_number-2
    ax.plot(1, np.sum(probs_fliC[slice(ind_row),ind_col], axis=0), 'ok')
    ax.plot(2, np.sum(probs_pilGcpdAfliC[slice(ind_row),ind_col], axis=0), 'og')
    ax.plot(3, np.sum(probs_cpdAfliC[slice(ind_row),ind_col], axis=0), 'oc')
    ax.plot(4, np.sum(probs_pilHcyaBfliC[slice(ind_row),ind_col], axis=0), 'om')
    ref_prob=np.ones(6)*np.sum(probs[slice(ind_row),ind_col], axis=0)
    ax.plot([0,1,2,3,4,5],ref_prob, 'r')
    #plt.legend(labels=('fliC-', 'pilGcpdAfliC', 'cpdAfliC', 'Expected'), loc=1)
    ax.set(ylabel=y_label)
    ax.set(xticklabels=['', 'fliC-', 'pilG-cpdA-fliC-', 'cpdA-fliC-', 'pilH-cyaB-fliC-', ''])
    ax.tick_params(axis='x', rotation=45)
    ax.set(title="Cells with "+str(pili_number)+" pili")

def capitalize_nth(s, n):
    return s[:n].lower() + s[n:].capitalize()

print("pili_assymetry_utils loaded successfully")