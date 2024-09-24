######################################
############################  preamble
######################################

## set the environment
using Pkg;
Pkg.activate(joinpath(@__DIR__, ".."));

## instantiate the environment
Pkg.instantiate();

## precompile
using Mimi, MimiGIVE, MimiRFFSPs, Random, CSV, DataFrames, DataDeps, Distributed, Statistics, Parquet;

## automatically download data dependancies (rffsps)
ENV["DATADEPS_ALWAYS_ACCEPT"] = "true"
MimiRFFSPs.datadep"rffsps_v5"

######################################
##################### model parameters
######################################

## set random seed for monte carlo 
seed = 42;

## set number of monte carlo draws
n = 10_000;

## specify list of emissions years
years = [2020, 2030, 2040, 2050];

## specify list of gases
gases = [:HFC23, :HFC32, :HFC125, :HFC134a, :HFC143a, :HFC227ea, :HFC236fa, :HFC245fa]

## set named list of discount rates
discount_rates = [(label = "2.0% Ramsey", prtp = exp(0.001972641)-1, eta  = 1.244459020)];

## read the series of rffsp-fair pairings. these were randomly selected pairings. read GIVE documentation for other functionality.
fair_parameter_set_ids = CSV.File(joinpath(@__DIR__, "../input/rffsp_fair_sequence.csv"))["fair_id"][1:n];
rffsp_sampling_ids     = CSV.File(joinpath(@__DIR__, "../input/rffsp_fair_sequence.csv"))["rffsp_id"][1:n];

## GIVE results are in 2005 USD, this is the price deflator to bring the results to 2020 USD. accessed 10/19/2022. source: https://apps.bea.gov/iTable/iTable.cfm?reqid=19&step=3&isuri=1&select_all_years=0&nipa_table_list=13&series=a&first_year=2005&last_year=2020&scale=-99&categories=survey&thetable=
pricelevel_2005_to_2020 = 113.784/87.504;

## save model inputs for dscim-facts-epa
save_list = 
    [
       (:TempNorm_1850to1900,  :global_temperature_norm),   ## Global surface temperature anomaly (K) from preinudstrial
       (:OceanHeatAccumulator, :del_ohc_accum)              ## Accumulated Ocean heat content anomaly from FaIR
    ];

######################################
###################### set up parallel
######################################

## add procs 
addprocs(32);

## distribute packages
@everywhere using Pkg;
@everywhere Pkg.activate(joinpath(@__DIR__, ".."));
@everywhere using Mimi, MimiGIVE, Random, CSV, DataFrames, Distributed, Statistics, Parquet;

######################################
###################### estimate schfcs
######################################

pmap((year, gas) for 
    year in years, 
    gas in gases) do (year, gas)
        
    ## set random seed
    Random.seed!(seed);

    ## get model 
    m = MimiGIVE.get_model();

    ## specify meta analysis damages to speed up the model, does not have an effect on the save_list objects
    update_param!(m, :DamageAggregator, :include_ag, false);
    update_param!(m, :DamageAggregator, :include_cromar_mortality, false);
    update_param!(m, :DamageAggregator, :include_slr, false);
    update_param!(m, :DamageAggregator, :include_energy, false);
    update_param!(m, :DamageAggregator, :include_hs_damage, true);
    update_param!(m, :hs_damage,        :specification, 7);
    update_param!(m, :hs_damage,        :effects, :base);

    ## print iterations into console
    println("Now doing $gas in $year")

    ## specify output directory if save_list (above) is not empty (uncomment the next line)
    output_dir = joinpath(@__DIR__, "gmst_and_ohc/$gas-$year")

    results = 
        MimiGIVE.compute_scc(m, 
                             n                       = n , 
                             gas                     = gas, 
                             year                    = year, 
                             discount_rates          = discount_rates, 
                             pulse_size              = 1.0,                      ## scales the defalut pulse size 
                             fair_parameter_set      = :deterministic,           ## optionally read the rffsp-fair parameter sequence from file
                             fair_parameter_set_ids  = fair_parameter_set_ids,   ## optionally read the rffsp-fair parameter sequence from file
                             rffsp_sampling          = :deterministic,           ## optionally read the rffsp-fair parameter sequence from file
                             rffsp_sampling_ids      = rffsp_sampling_ids,       ## optionally read the rffsp-fair parameter sequence from file
                             save_list               = save_list,                ## comment out if save_list is empty
                             output_dir              = output_dir);               ## comment out if save_list is empty

end

## end of script, have a great day.