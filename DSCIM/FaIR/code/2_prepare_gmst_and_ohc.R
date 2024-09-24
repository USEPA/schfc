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
gases = c('HFC23', 'HFC32', 'HFC125')
# gases = c('HFC134a', 'HFC143a', 'HFC227ea')
# gases = c('HFC236fa', 'HFC245fa')

# ## create list of emissions years
years = seq(2020, 2050, 10)

## global mean surface temperature
## blank canvas
data = tibble()

for (GAS in gases){
  
  for (YEAR in years) {
    
    data = 
      bind_rows(
        data,
        ## read global mean surface temperature and export to single file for use in generate_input_files.py
        left_join(
          read_parquet(paste0('gmst_and_ohc/', GAS, '-', YEAR, '/results/model_1/TempNorm_1850to1900_global_temperature_norm.parquet')) %>% 
            rename(year                = time, 
                   control_temperature = 2, 
                   runid               = trialnum) %>% 
            # filter(year >= 1850) %>%
            mutate(pulse_year = as.integer(YEAR), 
                   year       = as.integer(year),
                   runid      = as.integer(runid),
                   gas        = GAS),
          read_parquet(paste0('gmst_and_ohc/', GAS, '-', YEAR, '/results/model_2/TempNorm_1850to1900_global_temperature_norm.parquet')) %>% 
            rename(year              = time, 
                   pulse_temperature = 2, 
                   runid             = trialnum) %>% 
            # filter(year >= 1850) %>%
            mutate(pulse_year = as.integer(YEAR), 
                   year       = as.integer(year),
                   runid      = as.integer(runid),
                   gas        = GAS),
          by = join_by(runid, year, gas, pulse_year)
        ) %>% 
          relocate(runid, year, gas, pulse_year)
      ) 
  }
  
}

## export
data %>% write_parquet('gmst_and_ohc/gmst_pulse_epa_HFC23_HFC32_HFC125.parquet')
# data %>% write_parquet('gmst_and_ohc/gmst_pulse_epa_HFC134a_HFC143a_HFC227ea.parquet')
# data %>% write_parquet('gmst_and_ohc/gmst_pulse_epa_HFC236fa_HFC245fa.parquet')

## ocean heat content
## blank canvas
data = tibble()
for (GAS in gases){
  
  for (YEAR in years) {
    data = 
      bind_rows(
        data,
        ## read ocean heat content data from MimiGIVE
        left_join(
          read_parquet(paste0('gmst_and_ohc/', GAS, '-', YEAR, '/results/model_1/OceanHeatAccumulator_del_ohc_accum.parquet')) %>% 
            rename(year                       = time, 
                   control_ocean_heat_content = 2, 
                   runid                      = trialnum) %>% 
            mutate(control_ocean_heat_content = control_ocean_heat_content * 1e22, ## rescale to J per: https://github.com/rffscghg/MimiGIVE.jl/blob/main/src/components/OceanHeatAccumulator.jl
                   pulse_year = as.integer(YEAR), 
                   year       = as.integer(year),
                   runid      = as.integer(runid),
                   gas        = GAS),
          read_parquet(paste0('gmst_and_ohc/', GAS, '-', YEAR, '/results/model_2/OceanHeatAccumulator_del_ohc_accum.parquet')) %>% 
            rename(year                       = time, 
                   pulse_ocean_heat_content   = 2, 
                   runid                      = trialnum) %>% 
            mutate(pulse_ocean_heat_content = pulse_ocean_heat_content * 1e22, ## rescale to J per: https://github.com/rffscghg/MimiGIVE.jl/blob/main/src/components/OceanHeatAccumulator.jl
                   pulse_year = as.integer(YEAR), 
                   year       = as.integer(year),
                   runid      = as.integer(runid),
                   gas        = GAS),
          by = join_by(year, runid, gas, pulse_year)
        ) %>% 
          relocate(runid, year, gas, pulse_year)
      )
  }
  
}

## export
data %>% write_parquet('gmst_and_ohc/ohc_pulse_epa_HFC23_HFC32_HFC125.parquet')
# data %>% write_parquet('gmst_and_ohc/ohc_pulse_epa_HFC134a_HFC143a_HFC227ea.parquet')
# data %>% write_parquet('gmst_and_ohc/ohc_pulse_epa_HFC236fa_HFC245fa.parquet')

## end of script. have a great day!