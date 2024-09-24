# DSCIM: The Data-driven Spatial Climate Impact Model

This repository is an implementation of DSCIM, referred to as DSCIM-FACTS-EPA, that allows for alternative paths of global mean surface temperature (GMST) and ocean heat content (OHC) (typically from FaIR1.6.2). These instructions are to run DSCIM on a Windows machine in a Docker container. Similar steps can likely be taken on other operating systems, but they have not been tested. 

## Results Already Contained within this Repository
For ease of access, the results from running all of the steps outlined below are already preserved in this repository. These can be found in `DSCIM/output`. An interested user can replicate these results (the DSCIM SC-HFCs) using the following steps. 

## Setup
To begin we assume you have a system with `julia` and `conda` available from the command line, and some familiarity with it. See the main [README](README.md) of this repository for information on downloading and getting started with `julia` and `Mimi` and `GIVE`, which will be used to run the climate module `FaIR1.6.2`. A conda distribution is available from [miniconda](https://docs.conda.io/en/latest/miniconda.html), [Anaconda](https://www.anaconda.com/), or [mamba](https://mamba.readthedocs.io/en/latest/). This helps to ensure required software packages are correctly compiled and installed, replicating the analysis environment.

### Additional Software
- You will need [Python](https://www.python.org/downloads/).
- You will need pip: `python get-pip.py`
- You will need wget: `pip install wget`
- You will need a [Windows Subsystem for Linux](https://learn.microsoft.com/en-us/windows/wsl/install): `wsl --install`
- You will need a [Docker Desktop App](https://www.docker.com/products/docker-desktop/). Download and install. 

### Cloning the Repositories
Open a command terminal (`cmd`) and navigate to where you would like to clone the `dscim-facts-epa` and `facts` repositories. Then clone the repositories by typing: 

```bash
git clone https://github.com/ClimateImpactLab/dscim-facts-epa.git
```

In that same directory, you will also need a clone of the FACTS repository:

```bash
git clone https://github.com/radical-collaboration/facts.git
```

We only need to run the global FACTS model, so get the “only global” data using a new command terminal (not a PowerShell) and type:

```bash
wget -P facts/modules-data -i facts/modules-data/modules-data.global_only.urls.txt
```

Now, we need to set up the `dscim-facts-epa` environments. Navigate to `DSCIM/dscim-facts-epa` in the command line and first remove any previous environments with the same name and type:

```bash
conda remove -n dscim-facts-epa --all
```

If prompted, select `y` to continue (sometimes more than once). Then, set up the new environment with: 

```bash
conda env create -f environment.yml
```

Activate the environment with:

```bash
conda activate dscim-facts-epa
```

With the environment set up and active, the next step is downloading the required DSCIM-FACTS-EPA input data into the local directory. Navigate to the `DSCIM/dscim-facts-epa/scripts` directory and from the command line type:

```bash
python directory_setup.py
```

Note that this will download several gigabytes of data and may take several minutes, depending on your connection speed.

## Recovering new paths of Global Mean Surface Temperature (GMST) and Ocean Heat Content (OHC). 
The next step is generating new inputs of GMST and OHC for use in DSCIM-FACTS-EPA. We are assuming you have `julia` and `GIVE` installed and functioning (see [README](README.md)).

Navigate to `DSCIM/FaIR/code` in the command line and type: 

```bash
julia 1_recover_gmst_and_ohc.jl
```

This will take several hours (~1.6) to run each of the scenarios (with and without carbon feedbacks) in parallel, requiring two free processors. 1.4GB of free space will be necessary for the output. 

Next, open the `FaIR.Rproj` project file in `DSCIM/FaIR`. This will open RStudio. Open the file `DSCIM/FaIR/code/2_prepare_gmst_and_ohc.R`. We need to create three pairs of files, one for GMST and the other for OHC. Lines 22, 23, 24, and lines 69, 70, 71, and lines 111, 112, and 113 all need to be commented out one at a time and the whole script should be ran for each corresponding set (i.e., `CTL+A` followed by `CTL+ENTER`). That is, line 22, 69, and 111 should all be uncommented and ran together. Then, lines 23, 70, and 112 should be ran together. Finally, lines 24, 71, and 113 should be ran together. This will create the input files for `dscim-facts-epa` and will be referenced in the next step. 

## Replacing the default GMST and OHC inputs
This step needs to be done for a single set of no more than three gases. Open a new command line (`cmd`) and ensure you are _not_ in the `dscim-facts-epa` environment. Navigate to `DSCIM/FaIR/code` in the command line and type: 

```bash
py 3_generate_dscim_input_files.py
```

The script `3_generate_dscim_input_files.py` uses the output from running GIVE to replace the default DSCIM inputs with those generate by FaIR. Complete the estimation of the SC-HFC using the new input files you just created. Return to this step to run a new set of gases and repeat the process. That is, lines 5, 6, and 7 correspond to lines 22, 23, and 24, and have the three sets of gases already populated. Comment lines 5 and 22 out, and uncomment lines 6 and 23, and repeat the process all the way through (i.e., after running the first set all the way through, rerun `3_generate_dscim_input_files.py` with the new set of gases and then simply run `bash facts_runs.sh` again (outlined below), and rerun DSCIM after that is completed, and the new results will reflect the new set of gases). Do this again with lines 7 and 24 ran together. 

## Running FACTS with the new GMST and OHC inputs
In the command line, type `ubuntu`. This will activate the WSL. Check what is mounted to the virtual machine (VM) by typing `ls /`. Note the forward slash. Navigate to the “mounted” location of the cloned `dscim-facts-epa` and `facts` repositories by typing: 

```bash
cd /mnt/<LOCATION WHERE YOU CLONED THE DSCIM-FACTS-EPA and FACTS REPOSITORIES>
```

Note, your drives are lower case with no colon. For example, to get to your `D:` drive you would type: `cd /mnt/d`. Once you are in your mounted path, you can type `ls` without the `/` to see what directories are in there. 

Then log-into the Docker container by opening the Docker App you downloaded above and logging in within the App (Sign In, upper right). In the `wsl` command line type `docker login`. 

Go to the section 1.2, step 3 in the [FACTS quickstart guide](https://fact-sealevel.readthedocs.io/en/latest/quickstart.html), in this VM, navigate to the facts/docker path:

```bash
cd facts/docker
```

Open the develop.sh file in VScode. You will see in the lower right-hand side of the VScode the letters `CRLF`. Click on those letters, and on the top of the screen you will select `LF`. Save the file (`CTL+S`).  

For this next step you might need to disconnect from a workplace VPN. Still in the `/mnt/~/DSCIM/facts/docker` path, type: 

```bash
sh develop.sh
```

Navigate back to the root directory `DSCIM` (i.e., type `cd ../..`). 

Follow section 1.2, step 3 in the [FACTS quickstart guide](https://fact-sealevel.readthedocs.io/en/latest/quickstart.html) to start the Docker. The two occurrences of `$HOME` need to be replaced with the full path to the `dscim-facts-epa` and `facts` repositories. For example, if you have clones `dscim-facts-epa` and `facts` in the location `D:\schfcs`, you would replace `$HOME` with `d/schfcs`.

```bash
docker run -it --volume=/mnt/$HOME/facts:/opt/facts --volume=/mnt/$HOME/dscim-facts-epa:/opt/dscim-facts-epa -w /opt/dscim-facts-epa/scripts/facts.runs facts
```

Now you are in a (factsVe) environment (the prefix to your path). 

The run environment for `dscim-facts-epa` needs to be installed. Per [the troubleshooting instructions](https://github.com/ClimateImpactLab/dscim-facts-epa/blob/main/scripts/facts.runs/FACTS_TROUBLESHOOTING.md#facts-troubleshooting), start by removing one of the environments (if there is one, there might not be) with: 

```bash
rm -r ~/radical.pilot.sandbox/ve.local.localhost.@
```

Create the environment in the docker container: 

```bash 
python3 -m venv ~/radical.pilot.sandbox/ve.local.localhost.@
```

Then switch to that environment:

```bash
deactivate
. ~/radical.pilot.sandbox/ve.local.localhost.@/bin/activate
```

Then install the packages and their necessary versions: 

```bash
pip install netCDF4==1.6.5
pip install wheel
pip install setuptools==69.0.2
pip install radical.entk==1.42.0 radical.pilot==1.47.0 radical.utils==1.47.0 radical.saga==1.47.0 radical.gtod==1.47.0
```

With the packages installed, deactivate this environment and activate your run environment again:

```bash
deactivate
. /factsVe/bin/activate
```

There is a file titled `hfc_facts_runs.sh` in the `DSCIM` directory that you will need to move into the `dscim-facts-epa/scripts/facts.runs` directory. In the same way that you altered the line endings from `CRLF` to `LF` in the `develop.sh` script above, ensure that the line endings of this file are set to `LF` (open in VScode, look in the lower right corner, if you see `CRLF` click on it, change to `LF` in the drop-down menu at the top of your screen, and re-save). Either drag it in your file explorer, or copy and paste. Lines 12, 13, and 14 specify the gases that will be used in each run. Only have one line commented out each time, and the line that you have commented out (running) should correspond to the list of gases that you included when you ran `3_generate_dscim_input_files.py` in the steps above. 

This will automatically overwrite the input files for `dscim-facts-epa`.

In your `factsVe` virtual environment, the command line should be `/opt/dscim-facts-epa/scripts/facts.runs`. Then type:

```bash
bash facts_runs.sh
```

11. This step will need to be ran twice. There are errors that occur on the first go around as files are being references that are not yet finished being created. Once this first error is triggered, typically at `task 0000013`, go ahead and terminate the process by typing `CTL+C` in the terminal followed by `ENTER`. This should only happen once. Run facts again (i.e., `bash facts_runs.sh`) and it should complete within 30 minutes without any errors. 

## Estimating the DSCIM SC-GHGs
There are two files that are in the `DSCIM` directory of this repository that need to be copied and put in the `dscim-facts-epa/scripts` directory. In your file explorer, navigate to the `DSCIM` directory, highlight both `schfcs.yaml` and `estimate_schfcs.py`, copy them (`CTL+C`), navigate to `DSCIM/dscim-facts-epa/scripts` and paste them (`CTL+V`).

Now, in a `cmd` terminal, be sure you are in the `dscim-facts-epa` environment, navigate to the `dscim-facts-epa/scripts` path and type: 

```bash
python estimate_schfcs.py
```

`DSCIM` will now begin running in the terminal. Select the desired outputs, run the model, and the results will be found in `DSCIM/dscim-facts-epa/scripts/output`. 

In the same way that the user needs to comment and uncomment lines in the `3_generate_dscim_input_files.py` and `hfc_facts_runs.sh` scripts, the `schfcs.yaml` file will also need to have the appropriate lines commented out each time the estimation process is ran with a different set of gases. In the `schfcs.yaml` file, those lines are found from line 19 to line 29. 
