library(tidyverse)
library(readr)

# ===Explanation: ----
# - Files: 
#     - table_s1_comorbidities_table_1_ is used for identifying LC cases. 
#     - er_visit_codelist is for selecting people with eligible outcome. 
# - Issue: 
#     - The length of er_visit is shorter, containing less respiratory cases. 
# - Tasks: 
#     - Create comorbidities codelists for defining effect modifiers 
#     - Combine two codelists, and include lung diseases to the er_visit list

# Read in datasets
# Codelists for identifying LC cases 
table_s1_comorbidities_table_1_ <- read_csv("codelist_organise/table_s1_comorbidities_table (1).csv")

# Check codelist 
table_s1_comorbidities_table_1_ |> names()
table_s1_comorbidities_table_1_$Category |> table()
table_s1_comorbidities_table_1_ <- table_s1_comorbidities_table_1_ |> 
      dplyr::select("ICD.10","eng","Comorbidities_Group","Category")


# Codelists for identifying ER visits
er_visit_codelist <- read_csv("codelist_organise/er_visit_codelist.csv")
er_visit_codelist |> names()
er_visit_codelist$category |> table()


# Task 1: Create effect modifiers codelists -----
# 1. Mental health
mental_health <- table_s1_comorbidities_table_1_ |> filter(
      Category == "mental_health_disorders") |> 
      dplyr::select("ICD.10", "eng", "Category" )
mental_health |> write_csv("codelist_organise/mental_health_icd10.csv")

# 2. Respiratroy diseases
respiratory_diseases <-  table_s1_comorbidities_table_1_ |> filter(
      Category == "asthma" | Category == "lung") |> 
      dplyr::select("ICD.10","eng", "Category" )
respiratory_diseases |> write_csv("codelist_organise/respiratory_diseases.csv")

# Heart disease
heart_disease <-  table_s1_comorbidities_table_1_ |> filter(
      Category == "heart_disease") |> 
      dplyr::select("ICD.10","eng", "Category" )
heart_disease |> write_csv("codelist_organise/heart_disease.csv")


# Task 2: Fix the short outcome codelist issue -----
table_s1_comorbidities_table_1_ |> names()
er_visit_codelist |> names() # variables are different
er_visit_codelist$category |> table()

er_visit_codelist_rev <- er_visit_codelist |> 
      dplyr::filter(category!="respiratory") # Remove old codes 

# revise respiratory codelist
respiratory <- respiratory_diseases |> 
      rename(subcategory = Category) |> 
      mutate(category = "respiratory")

# Combine the codes
er_visit_codelist_rev <- rbind(er_visit_codelist_rev, respiratory)
er_visit_codelist_rev |> write_csv("codelist_organise/er_visit_codelist_rev.csv")
