##########################
#################  library
##########################

## clear workspace
rm(list = ls())
gc()

## This function will check if a package is installed, and if not, install it
list.of.packages <- c('magrittr','tidyverse',
                      'arrow')

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.rstudio.com/")
lapply(list.of.packages, library, character.only = TRUE)

##########################
####################  data
##########################

## create list of gases
gases = c('HFC23', 'HFC32', 'HFC125', 'HFC134a', 'HFC143a', 'HFC227ea', 'HFC236fa','HFC245fa')

## create list of emissions years
years = seq(2020, 2050, 10)

## loop
for (GAS in gases){
  for (YEAR in years) {
    
    ## echo in console
    print(paste0('Compressing ', GAS, ' in year ', YEAR))
    
    ## baseline gmst
    read_csv(paste0('gmst_and_ohc/', GAS, '-', YEAR, '/results/model_1/TempNorm_1850to1900_global_temperature_norm.csv'),
             show_col_types = F) %>%
      write_parquet(paste0('gmst_and_ohc/', GAS, '-', YEAR, '/results/model_1/TempNorm_1850to1900_global_temperature_norm.parquet'))

    ## perturbed gmst
    read_csv(paste0('gmst_and_ohc/', GAS, '-', YEAR, '/results/model_2/TempNorm_1850to1900_global_temperature_norm.csv'),
             show_col_types = F) %>%
      write_parquet(paste0('gmst_and_ohc/', GAS, '-', YEAR, '/results/model_2/TempNorm_1850to1900_global_temperature_norm.parquet'))

    ## baseline ocean heat accumulation
    read_csv(paste0('gmst_and_ohc/', GAS, '-', YEAR, '/results/model_1/OceanHeatAccumulator_del_ohc_accum.csv'),
             show_col_types = F) %>% 
      write_parquet(paste0('gmst_and_ohc/', GAS, '-', YEAR, '/results/model_1/OceanHeatAccumulator_del_ohc_accum.parquet'))
     
    ## perturbed ocean heat accumulation
    read_csv(paste0('gmst_and_ohc/', GAS, '-', YEAR, '/results/model_2/OceanHeatAccumulator_del_ohc_accum.csv'),
             show_col_types = F) %>% 
      write_parquet(paste0('gmst_and_ohc/', GAS, '-', YEAR, '/results/model_2/OceanHeatAccumulator_del_ohc_accum.parquet'))
    
  }
}

## end of script. have a great day!