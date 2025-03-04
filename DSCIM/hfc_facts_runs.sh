#!/bin/bash
# Stop script when non-facts error occurs
set -e

# Set overwrite to 1 to overwrite previous results (if they exist), 0 otherwise
overwrite=0

# Define arrays for pulse years and gases
pulse_years=(2020 2030 2040 2050)

# Comment out these in sequence, one at a time
gases=("HFC23" "HFC32" "HFC125")
# gases=("HFC134a" "HFC143a" "HFC227ea")
# gases=("HFC236fa" "HFC245fa")

# Desired control/pulse file paths
gmst_file="/opt/dscim-facts-epa/scripts/input/climate/gmst_pulse.nc4"
ohc_file="/opt/dscim-facts-epa/scripts/input/climate/ohc_pulse.nc4"
# Desired GMSL pulse file path
gmsl_file="/opt/dscim-facts-epa/scripts/input/climate/facts_gmsl_pulse.nc4"
# Paths to directories
facts_dir="/opt/facts"
dscim_facts_epa_dir="/opt/dscim-facts-epa"
# Create FACTS experiments
python3 prepare_facts.py \
 --dscim_repo "${dscim_facts_epa_dir}" \
 --facts_repo "${facts_dir}" \
 --pulse_years "${pulse_years[@]}" \
 --gases "${gases[@]}" \
 --gmst_file $gmst_file \
 --ohc_file $ohc_file 
# Loop through the pulse years
for gas in "${gases[@]}"; do
    # Loop through the gases
    for year in "${pulse_years[@]}"; do    
        echo "Gas: $gas"
        echo "Pulse: $year"
        wfs=0
        gas_exp="${gas//_/.}"
        # Check if experiment output files have already been generated
        if [ -f $facts_dir/experiments/rff.$year.$gas_exp/output/rff.$year.$gas_exp.total.workflow.wf1f.global.nc ]; then
            wfs=$((wfs + 1))
        fi
        if [ -f $facts_dir/experiments/rff.$year.$gas_exp/output/rff.$year.$gas_exp.total.workflow.wf2f.global.nc ]; then
            wfs=$((wfs + 1))
        fi
        if (( $wfs != 2 | $overwrite == 1 )); then
            cd $facts_dir
            python3 runFACTS.py experiments/rff.$year.$gas_exp
        else 
            echo "experiment results found, not rerunning"
        fi
    done
done
echo "Generating control run GMSL"
wfs=0
if [ -f $facts_dir/experiments/rff.control.control/output/rff.control.control.total.workflow.wf1f.global.nc ]; then
    wfs=$((wfs + 1))
fi
if [ -f $facts_dir/experiments/rff.control.control/output/rff.control.control.total.workflow.wf2f.global.nc ]; then
    wfs=$((wfs + 1))
fi
if (( $wfs != 2 | $overwrite == 1 )); then
    cd $facts_dir
    python3 runFACTS.py experiments/rff.control.control
else 
    echo "experiment results found, not rerunning"
fi
cd $dscim_facts_epa_dir/scripts/facts.runs
# Take the outputs of the FACTS experiment and save in the proper format
python3 format_facts.py \
--facts_repo "${facts_dir}" \
--pulse_years "${pulse_years[@]}" \
--gases "${gases[@]}" \
--gmsl_file $gmsl_file
cd $dscim_facts_epa_dir/scripts
# Create config for dscim run
python3 create_config.py \
--gmsl_file $gmsl_file \
--gmst_file $gmst_file \
--pulse_years "${pulse_years[@]}" \
--gases "${gases[@]}" 
