import xarray as xr
import pandas as pd

## create gas parameter to insert below, substitute manually for each iteration of dscim-facts-epa
GAS='HFC23_HFC32_HFC125'
# GAS='HFC134a_HFC143a_HFC227ea'
# GAS='HFC236fa_HFC245fa'

## create list of variables
variables = {
        "gmst":"temperature",
        "ohc":"ocean_heat_content"
        }

## function to loop through variables and create nc4 files from the csv files
for VAR in variables.keys():
    
    ## read data
    data = pd.read_parquet(f"../gmst_and_ohc/{VAR}_pulse_epa_{GAS}.parquet", engine='fastparquet')

    ## control variables only vary by runid and year, choose a single pulse year
    control = data.query('gas == "HFC23" and pulse_year == 2020').set_index(["runid","year"])[f"control_{variables[VAR]}"].to_xarray()
    # control = data.query('gas == "HFC134a" and pulse_year == 2020').set_index(["runid","year"])[f"control_{variables[VAR]}"].to_xarray()
    # control = data.query('gas == "HFC236fa" and pulse_year == 2020').set_index(["runid","year"])[f"control_{variables[VAR]}"].to_xarray()

    ## pulse variables vary by runid, year, pulse_year, and gas
    pulse = data.set_index(["runid","year","pulse_year","gas"])[f"pulse_{variables[VAR]}"].to_xarray()

    ## merge together into one xr.Dataset before saving
    xr.merge([control,pulse]).to_netcdf(f"../../dscim-facts-epa/scripts/input/climate/{VAR}_pulse.nc4")

## end of script. have a great day!
