
import os
import numpy as np
import pandas as pd
import plotly.graph_objects as go
import plotly.figure_factory as ff
from plotly.offline import plot

#%% Importing csv files

## Helps to display all rows and columns in pandas
pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows', None)

## Import DEI_CSV file
os.getcwd()
os.chdir('E:/p33/P33-DEI-dashboard-project/data/')
df = pd.read_csv('df_DEI_tidy_final.csv')
df.head()


#%% select metrics that are used 

var = df.metrics_new.unique()
print(var)

var_selected = [
    
# k-8 ---------------------
## math prof
                '2021___city_chi___k8_4th___math_prof&abov___cps',
                '2021___usa___k8_4th___math_prof&abov',
                '2021___city_chi___k8_8th___math_prof&abov___cps',
                '2021___usa___k8_8th___math_prof&abov',
## math adv               
                '2021___city_chi___k8_4th___math_advc___cps',
                '2021___usa___k8_4th___math_advc',
                '2021___city_chi___k8_8th___math_advc___cps',
                '2021___usa___k8_8th___math_advc',
## math algebra 
                '2017___city_chi___k8_8th___math_algebra_enrol___cps',
                '2017___usa___k8_8th___math_algebra_enrol',               
                '2021___city_chi___k8_8th___math_algebra_pass___cps',
                '2021___usa___k8_8th___math_algebra_pass',
            
## magnet enroll                
                '2021___city_chi___k8_total___mag_stem_enrol___cps',
## internet access
                '2019___city_chi___k8_total___NOinternet_age5to17___cps',                
                '2019___usa___k8_total___NOinternet_age5to17',
## population                  
                '2022___city_chi___k8_4th___popul___cps',
                '2020___usa___k8_4th___popul',
                '2022___city_chi___k8_8th___popul___cps',
                '2020___usa___k8_8th___popul',
                '2022___city_chi___k8_total___popul___cps',
                '2022___usa___age_5to17__popul',
                '2022___city_chi___age_5to17__popul___cps',            
          
            
# high school   -----------            
## sat math exceeds
                '2021___city_chi___hs___sat_math_exceeds___cps',
                '2021___usa___col___sat_math_exceeds',
## sat math meet and exceeds
                '2021___city_chi___hs___sat_math_meet&exceeds___cps',
                '2021___usa___col___sat_math_meet&exceeds',
## ap cs               
                '2021___city_chi___hs___apcs_score3/4',
                '2021___usa___hs___apcs_score3/4',
                '2021___city_chi___hs___apcs_score5___cps',
                '2021___usa___hs___apcs_score5',
                '2021___state_il___hs___apcs_enrol',
                '2021___usa___hs___apcs_enrol',
## magnet enrol
                '2021___city_chi___hs___mag_enrol___cps',
## cs interest
                '2021___city_chi___hs___cs_interested___cps',
## adv math ?????? TBC
                '2017___city_chi___hs___math_advc___cps',
                '2017___usa___hs___math_advc_enroll',
## population
                '2021___city_chi___hs_SATtaker___popul___cps',
                '2021___usa___hs_SATtaker___popul',
                '2021___city_chi___hs_apcs___popul___cps',
                '2021___usa___hs_apcs___popul',
                '2022___city_chi___hs_total___popul___cps',

# College -----------------
## CS confer
                '2021___state_il___col___cs_confer',
                '2021___usa___col___cs_confer',
## CS enrol                
                '2021___state_il___col___cs_enrol',
                '2021___usa___col___cs_enrol',              
## T3 cs enrol
                '2021___state_il___col___t3_cs_enrol',
                '2021___usa___col___t3_cs_enrol',                
## T3 cs confer
                '2021___state_il___col___t3_cs_confer',
                '2021___usa___col___t3_cs_confer',
## hs grads population              
                '2021___state_il___hs___total_grad',
                '2022___usa___hs_grads___popul',        
## population             
                '2022___state_il___col___total_enrol',
                '2021___usa___col___total_enrol',
                '2020___state_il___col___total_confer',
                '2021___usa___col___total_confer', 
## t3 population
                '2021___state_il___col___t3_enrol',
                '2021___usa___col___t3_enrol',                  
                '2021___state_il___col___t3_confer',
                '2021___usa___col___t3_confer',
                
                
# employement --------------
## tech job
                '2021___region_chi_msa___emp___csjob_t11_age19to24',
                '2021___usa___emp___csjob_t11_age19to24',
                '2021___region_chi_msa___emp___total_degree_holder',
                '2021___usa___emp___total_degree_holder',
## top3 tech jobs
                '2021___region_chi_msa___emp___csjob_t3',
                '2021___usa___emp___csjob_t3'
]


#%% Prepare a extracted dataset 
# pick ethnic groups

## create a new dataset contained metrics presented in the last section  
df_clean = df[df.metrics_new.isin(var_selected)]

## focus on black, hispanic, white and asian ethnic individual groups 
df_clean_fourGroups = df_clean[(df_clean['var_ethnic'] != "all") &
   (df_clean['var_ethnic'] != "black_hispanic") &
   (df_clean['var_ethnic'] != "white_asian")
   ]


#%% Define the metrics function (two scopes)
# This metric function generates a new dataset contained the value of metricOne/PopulaitonOne
# and the value of metricTwo/PopulaitonTwo for different ethnic groups at two geographical scopes.

# define the metric funtion
def metric_DEI_twoScopes(df,metricOne,metricTwo,populOne,PopulTwo):
    
    ''' extract numerators '''
    df_subset = df[(df["metrics_new"] == metricOne) | (df["metrics_new"] == metricTwo) ]   
    ''' rename the value in subset dataset to subset_popul '''
    df_subset.rename(columns = {'population':'subset_popul'}, inplace = True)
    ''' extract denominators '''
    df_popul = df[(df["metrics_new"] == populOne) | (df["metrics_new"] == PopulTwo) ]
    ''' merge two extracted datasets '''
    df_merge = pd.merge(df_subset, df_popul,  how = 'left', left_on=['var_scope','var_ethnic'], right_on = ['var_scope','var_ethnic'])
    ''' define the methodology '''
    df_merge['metric_value'] = (df_merge['subset_popul'] / df_merge['population'])
    ''' drop redundant variables in merged dataframe '''
    df_metric = df_merge.loc[:,['metrics_new_x','var_scope','var_ethnic','subset_popul','population','metric_value']] 

    print(df_metric)

# test the function
metric_DEI_twoScopes(df_clean_fourGroups,
           '2021___city_chi___k8_4th___math_prof&abov___cps',  # numerators for city of chicago
           '2021___usa___k8_4th___math_prof&abov', # numerators for US
           '2022___city_chi___k8_4th___popul___cps', # denominators for city of chicago 
           '2020___usa___k8_4th___popul') # denominators for US 



#%% Define the metrics function (one scopes)
# This metric function generates a new dataset contained the value of metricOne/PopulaitonOne 
# for different ethnic groups at one geographical scope.

# define the metric funtion
def metric_DEI_oneScope(df,metricOne,populOne):
    
    ''' extract numerators '''
    df_subset = df[(df["metrics_new"] == metricOne)]   
    ''' rename the value in subset dataset to subset_popul '''
    df_subset.rename(columns = {'population':'subset_popul'}, inplace = True)
    ''' extract denominators '''
    df_popul = df[(df["metrics_new"] == populOne)]
    ''' merge two extracted datasets '''
    df_merge = pd.merge(df_subset, df_popul,  how = 'left', left_on=['var_scope','var_ethnic'], right_on = ['var_scope','var_ethnic'])
    ''' define the methodology '''
    df_merge['metric_value'] = (df_merge['subset_popul'] / df_merge['population'])
    ''' drop redundant variables in merged dataframe '''
    df_metric = df_merge.loc[:,['metrics_new_x','var_scope','var_ethnic','subset_popul','population','metric_value']] 

    print(df_metric)

# test the function
metric_DEI_oneScope(df_clean_fourGroups,
                    '2021___city_chi___k8_4th___math_prof&abov___cps', # numerators for city of chicago
                    '2022___city_chi___k8_4th___popul___cps') # denominators for city of chicago 

#%% define the visualization function

 
 