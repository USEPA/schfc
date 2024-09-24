## written by: US EPA, National Center for Environmental Economics; August 2024
## creates a table of annual schfcs as simple averages across the three damage modules (GIVE, the Meta-Analysis, and DSCIM)

##########################
#################  library
##########################

## clear workspace
rm(list = ls())
gc()

## this function will check if a package is installed, and if not, install it
list.of.packages <- c('magrittr','tidyverse',
                      'arrow',
                      'stringi')
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.rstudio.com/")
lapply(list.of.packages, library, character.only = TRUE)

##########################
#################### parts
##########################

## function to read give data
read_give <- function(x) {
  filename = basename(x)
  read_parquet(x) %>%
    mutate(gas             = stri_split(filename, fixed = '-')[[1]][2],
           damage.function = 'GIVE (2022)',
           emission.year   = as.numeric(str_remove_all(stri_split(filename, fixed = '-')[[1]][4],'.parquet'))) %>% 
    relocate(damage.function, gas, emission.year, discount_rate, schfc)
}

## function to read meta-analysis data
read_meta <- function(x) {
  filename = basename(x)
  read_parquet(x) %>%
    mutate(gas             = stri_split(filename, fixed = '-')[[1]][2],
           damage.function = 'Meta-Analysis (2017)',
           emission.year   = as.numeric(str_remove_all(stri_split(filename, fixed = '-')[[1]][4],'.parquet'))) %>% 
    relocate(damage.function, gas, emission.year, discount_rate, schfc)
}

## function to read dscim data
read_dscim <- function(x) {
  filename = basename(x)
  read_csv(x, show_col_types = F) %>%
    select(sector, discount_rate, scghg) %>%
    mutate(scghg            = round(scghg),
           sector           = case_when(sector == 'combined' ~ 'total', 
                                        T ~ sector),
           gas              = stri_split(filename, fixed='-')[[1]][3],
           damage.function  = 'DSCIM (2022)',
           emission.year    = as.numeric(str_remove_all(stri_split(filename, fixed='-')[[1]][6],'.csv'))) %>%
    rename(schfc = scghg)
}


##########################
##################### give
##########################

## path to give directory
path.give = paste0('../GIVE/output/schfcs/')

## read in give data
give = 
  list.files(path.give, pattern = "*.parquet", full.names = T) %>%
  map_df(~read_give(.)) 

##########################
############ meta-analysis
##########################

## path to meta-analysis directory
path.meta = paste0('../Meta-Analysis/output/schfcs/')

## read in meta-analysis data
meta = 
  list.files(path.meta, pattern = "*.parquet", full.names = T)  %>%
  map_df(~read_meta(.))

##########################
#################### dscim
##########################

## path to dscim directory of global scghgs
path.dscim = paste0('../DSCIM/output/global_scghgs')

## read in dscim data
dscim =
  list.files(path.dscim, pattern = '*.csv', full.names = T)  %>%
  map_df(~read_dscim(.))

##########################
################## process
##########################

## combine from above
data =
  bind_rows(give, 
            meta, 
            dscim) %>%
  group_by(gas, emission.year, discount_rate) %>% 
  summarise(schfc = mean(schfc), .groups = 'drop')

## function for formatting
comma = scales::label_comma(accuracy = 1, big.mark = ',')

## linearly interpolate to annual and export
data %>%
  pivot_wider(names_from = c(discount_rate), values_from = schfc) %>%
  group_by(gas) %>% 
  complete(emission.year = seq(first(emission.year), last(emission.year))) %>%
  filter(emission.year %in% 2020:2050) %>% 
  mutate(emission.year = as.character(emission.year)) %>% 
  mutate_if(is.numeric, zoo::na.approx) %>% 
  mutate_if(is.numeric, round) %>% 
  mutate_if(is.numeric, comma) %>% 
  ungroup %>% 
  relocate(gas, 
           emission.year,
           `2.5% Ramsey`,
           `2.0% Ramsey`,
           `1.5% Ramsey`) %>% 
  mutate_all(as.character) %>% 
  arrange(match(gas, c('HFC23', 'HFC32', 'HFC125', 'HFC134a', 'HFC143a', 'HFC227ea', 'HFC236fa', 'HFC245fa')),
          emission.year) %>% 
  write_csv('output/schfc_annual.csv')

## end of script, have a great day.