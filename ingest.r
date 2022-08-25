list.of.packages <- c(
    'tidyverse',
    'dplyr',
    'tidyr',
    'ggfortify',
    'stargazer',
    'pscl'
    # 'arrow'
)
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

# Apache Arrow installation ionstructions from https://arrow.apache.org/docs/r/articles/install.html
options(
  HTTPUserAgent =
    sprintf(
      "R/%s R (%s)",
      getRversion(),
      paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])
    )
)
if(!("arrow" %in% installed.packages()[,"Package"])) install.packages("arrow", repos = "https://packagemanager.rstudio.com/all/__linux__/focal/latest")
append(list.of.packages, "arrow")

lapply(list.of.packages, library, character.only = TRUE)
library("arrow")

write_parquet

df_DEI_demo <- read.csv('DEI_CSV/df_demo_08152022.csv')
df_DEI_parametric <- read.csv('DEI_CSV/df_parametrics_08152022.csv')

#2 Clean raw Dataset

## 2.1 df_DEI_parametric

# lower cases in demo col
df_DEI_parametric_lower <- df_DEI_parametric %>%
  mutate(Demographic = tolower(Demographic),
         var_est = tolower(var_est))

# label variables and education stage 
colnames(df_DEI_parametric_lower)

df_DEI_parametric_label <- df_DEI_parametric_lower %>%
  mutate(var_key = case_when(

    # uni and top uni   
    str_detect(Demographic,"usa degree conferra") ~ "total_confer",
    str_detect(Demographic,"universities enrollment") ~ "total_enrol",
    str_detect(Demographic,"universities 2022 enrollment") ~ "total_enrol",
    str_detect(Demographic,"universities conferral") ~ "total_confer",
    str_detect(Demographic,"mit enrollment") ~ "t3_mit_total_enrol",  
    str_detect(Demographic,"mit cs enrollment") ~ "t3_mit_cs_enrol",   
    str_detect(Demographic,"mellon enrollment") ~ "t3_mellon_total_enrol",  
    str_detect(Demographic,"carnegie mellon cs enrollment") ~ "t3_mellon_cs_enrol",
    str_detect(Demographic,"stanford enrollment") ~ "t3_stanford_total_enrol",
    str_detect(Demographic,"stanford cs enrollment") ~ "t3_stanford_cs_enrol",
    str_detect(Demographic,"top three illinois universities cs 2021 conferral") ~ "t3_cs_confer",
    str_detect(Demographic,"top three usa universities cs conferral") ~ "t3_cs_confer",
    str_detect(Demographic,"top three usa universities cs conferral") ~ "t3_cs_confer", 
    str_detect(Demographic,"top three illinois universities cs 2022 enrollment") ~ "t3_cs_enrol", 
    
    # ap cs 
    str_detect(Demographic,"ap cs pass") ~ "apcs_pass",
    str_detect(Demographic,"ap cs enrollment") ~ "apcs_enrol",
    str_detect(Demographic,"ap cs enroll") ~ "apcs_enrol",
    str_detect(Demographic,"ap cs scored 3 or 4 ") ~ "apcs_score34",
    str_detect(Demographic,"ap cs scored 5") ~ "apcs_score5", 
    # cs  
    str_detect(Demographic,"offering cs") ~ "cs_classOffered",
    str_detect(Demographic,"interest in cs") ~ "cs_interested",
    str_detect(Demographic,"cs enrollment") ~ "cs_enrol",
    str_detect(Demographic,"cs/computing enrollment") ~ "cs_enrol",
    str_detect(Demographic,"cs 2022 enrollment") ~ "cs_enrol",
    str_detect(Demographic,"cs 2021 conferral") ~ "cs_confer",
    str_detect(Demographic,"cs degree conferral") ~ "cs_confer",
    str_detect(Demographic,"cs conferral") ~ "cs_confer",
    str_detect(Demographic,"computing conferral") ~ "cs_confer",
    
    # k-8
    str_detect(Demographic,"k-8 stem magnet school enrollment") ~ "mag_stem_enrol",
    
    # hs
    str_detect(Demographic,"magnet hs enrollment") ~ "mag_enrol", 
    str_detect(Demographic,"hs graduates") ~ "total_grad", 
    
    # sat   
    str_detect(Demographic,"sat exceeds") ~ "sat_math_exceeds",
    str_detect(Demographic,"sat exceeds in math") ~ "sat_math_exceeds", 
    str_detect(Demographic,"sat benchmark") ~ "sat_bench", 
    str_detect(Demographic,"sat math bench mark ") ~ "sat_math_bench", 
    str_detect(Demographic,"sat meets and exceeds") ~ "sat_math_meet&exceeds", 
    
    # math   
    str_detect(Demographic,"advanced in math") ~ "math_advc",
    str_detect(Demographic,"math advanced") ~ "math_advc",
    str_detect(Demographic,"proficient in math") ~ "math_prof",
    str_detect(Demographic,"math proficient and above") ~ "math_prof&abov",
    str_detect(Demographic,"below basic in math") ~ "math_belowBasic",
    str_detect(Demographic,"basic in math") ~ "math_basic",

    # employment
    str_detect(Demographic,"top 3 highest paying cs jobs") ~ "csjob_t3",
    str_detect(Demographic,"employee demographics") ~ "csjob_t11",
    str_detect(Demographic,"11 top tech jobs") ~ "csjob_t11",
    str_detect(Demographic,"19-24 year olds in tech") ~ "csjob_t11_age19to24",
    # internet
    str_detect(Demographic,"aged 5-17 number of students without internet access") ~ "NOinternet_age5to17"
    )
  ) %>%
  
  # create educational stage
  mutate(var_stage = case_when(str_detect(Demographic,"4th") ~ "k8_4th",
                               str_detect(Demographic,"5th-8th") ~ "k8_5to8th",
                               str_detect(Demographic,"8th") ~ "k8_8th",
                               str_detect(Demographic,"k-8") |
                                 str_detect(Demographic,"5-17") ~ "k8_total",
     
    str_detect(Demographic,"college") |
      str_detect(Demographic,"universities") |
        str_detect(Demographic,"degree") |
          str_detect(Demographic,"carnegie mellon") |
            str_detect(Demographic,"mit") | 
              str_detect(Demographic,"stanford") | 
                str_detect(Demographic,"computing") ~ "col",
    
    str_detect(Demographic,"sat") |
      str_detect(Demographic,"ap") |
        str_detect(Demographic,"9th-12th") |
          str_detect(Demographic,"hs") ~ "hs",
    
    str_detect(Demographic,"employment") |
       str_detect(Demographic,"employee") | 
         str_detect(Demographic,"jobs") |
           str_detect(Demographic,"tech") ~ "emp")
    
  ) %>%  
  
  ## Create scope var.
  mutate(var_scope = case_when(
    str_detect(Demographic,"mit") | 
      str_detect(Demographic,"stanford") | 
        str_detect(Demographic,"carnegie") ~ "college",
    
    str_detect(Demographic,"msa") |
      str_detect(Demographic,"employee") |
        str_detect(Demographic,"19-24 year olds in tech workforce") ~ "region_chi_msa",
    
    str_detect(Demographic,"cps") | 
      str_detect(Demographic,"in math") ~ "city_chi",  	

    str_detect(Demographic,"illinois") |
        str_detect(Demographic,"ap cs") |
          str_detect(Demographic,"ibhe") |
          str_detect(Demographic,"3 year cs/computing") ~ "state_il", 
    
    str_detect(Demographic,"usa") |
        str_detect(Demographic,"number of students") ~ "usa"
    )
  ) %>%
  
  select(Demographic,var_yr,var_scope,var_stage,var_key,everything())

colnames(df_DEI_parametric_label)

# write.csv(df_DEI_parametric_label,"E:/p33/P33-DEI-dashboard-project/df_DEI_parametric_label_forreview.csv", row.names = FALSE)

# create cols of variables: var_x

df_DEI_parametric_mutated <- df_DEI_parametric_label %>%
  
  ## create var_dim 
  mutate(var_dim = case_when(
    
    ### excellence
    str_detect(Demographic,"scored 5") ~ "excellence",
    str_detect(Demographic,"advanced") ~ "excellence",
    str_detect(Demographic,"pass") ~ "excellence",
    str_detect(Demographic,"top three") ~ "excellence",
    str_detect(Demographic,"top") ~ "excellence", 
    str_detect(Demographic,"high") ~ "excellence",
    str_detect(Demographic,"exceeds") ~ "excellence",
    ### proficiency
    str_detect(Demographic,"scored 3") ~ "proficiency",
    str_detect(Demographic,"proficient") ~ "proficiency",
    str_detect(Demographic,"persistent") ~ "proficiency",
    str_detect(Demographic,"conferral") ~ "proficiency",
    str_detect(Demographic,"benchmark") ~ "proficiency",
    str_detect(Demographic,"meets and exceeds") ~ "proficiency",
    str_detect(Demographic,"employee demographics") ~ "proficiency",
    ### access
    str_detect(Demographic,"enrollment") ~ "access",
    str_detect(Demographic,"enroll") ~ "access",

    ### access
    str_detect(Demographic,"19-24") ~ "access",
    str_detect(Demographic,"amazon survey") ~ "access",
    str_detect(Demographic,"lack of internet access") ~ "access",
    str_detect(Demographic,"number of students") ~ "access",
    str_detect(Demographic,"amazon survey") ~ "access"
    )
  ) %>%
  
  mutate(var_dim = case_when(
    ## revision: three top school enrollment to excellence
    str_detect(Demographic,"mit") ~ "excellence",
    str_detect(Demographic,"stanford") ~ "excellence",
    str_detect(Demographic,"carnegie") ~ "excellence",
    TRUE ~ var_dim
    )
  ) %>%
  
  ## create var_source
  mutate(var_source = str_extract(Demographic,"(?<=\\().+?(?=\\))")
          ) %>%
  
  ## create new var for ethnic groups 
  mutate(Black_Hispanic = Black + Hispanic,
         White_Asian = White + Asian) %>%

  ## create var_type
  mutate(var_type = ifelse(All < 1,'prob','count')) %>%
  
  ## reorganize the order of cols for pivot_longer
  select(All,Black_Hispanic,White_Asian,Black,Hispanic,White,Asian,var_dim,everything())

colnames(df_DEI_parametric_mutated)

df_DEI_parametric_mutated_long <- df_DEI_parametric_mutated %>%
  pivot_longer(1:7,names_to = "var_ethinc",values_to = "var_value") %>%
  mutate(var_ethinc = tolower(var_ethinc))

df_DEI_parametric_tidy <- df_DEI_parametric_mutated_long

# write.csv(df_DEI_parametric_mutated_long,"E:/p33/P33-DEI-dashboard-project/df_DEI_parametric_tidy.csv", row.names = FALSE)

## 2.2 df_DEI_demo

df_DEI_demo_long <- df_DEI_demo %>%
  mutate(Demographics = tolower(Demographics)) %>%
  select(-estimated) %>%
  pivot_longer(2:6,
               names_to = "var_ethnic",
               values_to = "population") 

# create cols of variables: var_x

df_DEI_demo_mutated_long <- df_DEI_demo_long %>%
  
  ## create var. of scope
  mutate(var_scope = case_when(
    str_detect(Demographics,"chicago msa") ~ "region_chi_msa", 
    
    str_detect(Demographics,"cps") |
      str_detect(Demographics,"chicago") |
        str_detect(Demographics,"all people in chicago")~ "city_chi",
    
    str_detect(Demographics,"illinois") ~ "state_il",
    
    str_detect(Demographics,"us") |
      str_detect(Demographics,"usa") |
        str_detect(Demographics,"national") ~ "usa" )
    ) %>%
  
  ## educational stage
    mutate(var_stage = case_when(
      
    str_detect(Demographics,"4th") |
      str_detect(Demographics,"8th") |
        str_detect(Demographics,"k-8") ~ "k8",
    
    str_detect(Demographics,"9th") |
      str_detect(Demographics,"10th") |
        str_detect(Demographics,"11th") |
          str_detect(Demographics,"12th") |
            str_detect(Demographics,"sat") |
              str_detect(Demographics,"highschool") |
                str_detect(Demographics,"hs") ~ "hs",
     
    str_detect(Demographics,"college") |
      str_detect(Demographics,"degrees") |
        str_detect(Demographics,"18-24")  ~ "col",
    
    str_detect(Demographics,"employee") |
      str_detect(Demographics,"jobs") |
        str_detect(Demographics,"20-64") |
          str_detect(Demographics,"tech") |
            str_detect(Demographics,"us population") |
              str_detect(Demographics,"all people") ~ "emp")
    )%>%
  
  ## create var_source
  mutate(var_source = str_extract(Demographics,"(?<=\\().+?(?=\\))")
          ) %>%
  
  ## create variable of years
  mutate(var_yr_ob = case_when(
    str_detect(Demographics,"2022") ~ 2022,
    str_detect(Demographics,"2021-2022") ~ 2021,
    str_detect(Demographics,"2020") ~ 2020,
    str_detect(Demographics,"2019") ~ 2019,
    TRUE ~ 2021)) %>%
  
  ## create variable of school types
  mutate(var_schoolType = case_when(
    str_detect(Demographics,"cps") ~ "cps",
    str_detect(Demographics,"all") ~ 'all',
    TRUE ~ 'tbc')
    ) %>%
  
  ## create variable of grades
  mutate(x = case_when(
    str_detect(Demographics,"4th grade") ~ "k8_4th",
    str_detect(Demographics,"8th grade") ~ "k8_8th",
    str_detect(Demographics,"k-8") ~ "k8_total",
    
    str_detect(Demographics,"cps 9th grade") ~ "hs_9th",
    str_detect(Demographics,"cps 10th grade") ~ "hs_10th",
    str_detect(Demographics,"cps 11th grade") ~ "hs_11th",
    str_detect(Demographics,"cps 12th grade") |
      str_detect(Demographics,"hs seniors") ~ "hs_12th",
    str_detect(Demographics,"hs graduates") |
      str_detect(Demographics,"us highschool graduates") ~ "hs_grads",
    str_detect(Demographics,"cps hs") |
      str_detect(Demographics,"all highschool")|
        str_detect(Demographics,"us highschool population") ~ "hs_total",
    str_detect(Demographics,"sat takers") ~ "hs_SATtaker",
    
    str_detect(Demographics,"all college students") ~ "col_total",
    str_detect(Demographics,"all degrees conferred") ~ "col_conferred",
    
    str_detect(Demographics,"degree holders") ~ "degreeHolders_total",

    str_detect(Demographics,"us population") ~ "national_total",
    str_detect(Demographics,"all people in chicago ") ~ "city_total",
    str_detect(Demographics,"18-24") ~ "age_18to24",
    str_detect(Demographics,"20-64") ~ "age_20to64")
  )

colnames(df_DEI_demo_mutated_long)

df_DEI_demo_tidy <- df_DEI_demo_mutated_long %>%
  rename(note = Demographics,
         demographics = x) %>%
  filter(note != 'all college students - all cs/computing degree enrollment') %>%
  select(demographics,var_schoolType,var_scope,var_ethnic,population,var_yr_ob,note,var_sample,var_source)

# write.csv(df_DEI_demo_mutated_long,"E:/p33/P33-DEI-dashboard-project/df_DEI_demo_tidy_for_review 07281007.csv", row.names = FALSE)

# 3 Merge into one dataset (TBF)

# preparing demo data for merging


colnames(df_DEI_demo_tidy)

df_DEI_demo_tidy_formerge <- df_DEI_demo_tidy %>%
  select(1:6)

df_DEI_demo_tidy_formerge$X <- paste('demo',
                                     df_DEI_demo_tidy_formerge$var_yr_ob,
                                     df_DEI_demo_tidy_formerge$demographics,
                                     df_DEI_demo_tidy_formerge$var_schoolType, 
                                     df_DEI_demo_tidy_formerge$var_scope,
                                     df_DEI_demo_tidy_formerge$var_ethnic,
                                     sep = ":") 

df_DEI_demo_tidy_formerge <- df_DEI_demo_tidy_formerge %>%
  select(X,population) %>%
  pivot_wider(names_from = X,
              values_from = population)

colnames(df_DEI_demo_tidy_formerge)

# preparing parametric data set for merging

colnames(df_DEI_parametric_tidy)

df_DEI_parametric_tidy_formerge <- df_DEI_parametric_tidy %>%
  filter(!is.na(var_dim)) %>%
  select(var_yr,var_dim,var_stage,var_scope,Demographic,var_type,var_value)

df_DEI_parametric_tidy_formerge$X <- paste('para',
                                     df_DEI_parametric_tidy_formerge$var_yr,
                                     df_DEI_parametric_tidy_formerge$var_dim,
                                     df_DEI_parametric_tidy_formerge$var_stage,
                                     df_DEI_parametric_tidy_formerge$var_scope,
                                     df_DEI_parametric_tidy_formerge$Demographic,
                                     df_DEI_parametric_tidy_formerge$var_type,
                                     sep = ":") 



colnames(df_DEI_parametric_tidy_formerge)

write_parquet(df_DEI_parametric_tidy, "data/parametric.parquet")
