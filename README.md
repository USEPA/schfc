# The Social Cost of Hydrofluorocarbons
This repo provides replication instructions for estimating the social cost of hydrofluorocarbons (SC-HFCs) consistent with the methods outlined in the "Report on the Social Cost of Greenhouse Gases: Estimates Incorporating Recent Scientific Advances" developed by the U.S. Environmental Protection Agency (EPA). For more information about the report and peer review process, see [EPA's SC-GHG website](https://www.epa.gov/environmental-economics/scghg). For more information on the models and running them, please reference EPA's [SC-GHG repository](https://www.github.com/USEPA/scghg).

The methods and estimates contained within this repository were used as a sensitivity analysis in Appendix J of EPA's September 2024 rule titled: [Phasedown of Hydrofluorocarbons: Management of Certain Hydrofluorocarbons and Substitutes Under Subsection (h) of the American Innovation and Manufacturing Act of 2020](https://www.federalregister.gov/documents/2023/10/19/2023-22526/phasedown-of-hydrofluorocarbons-management-of-certain-hydrofluorocarbons-and-substitutes-under).

# Requirements
1. *Julia* is free and available for download [here](https://julialang.org/). Estimation of the SC-HFCs for the `GIVE` and `Meta-Analysis` damage modules, and the input files for `DSCIM` was performed on Julia 1.6. While newer versions of *Julia* are compatible with all the code (e.g., 1.7 or 1.8), the random number generators were updated and results might not be identical due to random differences in the random parameters underlying the Monte Carlo runs of GIVE and the Meta-Analysis. In addition, **Julia 1.6** should be used to avoid errors due to compatibility with environment and package version files (`Manifest.toml` and `Project.toml` files, which should be preserved in order to replicate the numbers in this repository). Install *Julia* and ensure that it can be invoked (ran) from where the replication repository is to be cloned ("in your path"). 

     - Julia ships with the Julia version manager [Juliaup](https://github.com/JuliaLang/juliaup) which is useful in this case for handling Julia versions. To add the option of running Julia version 1.6 to your machine type the following in the terminal.

          ```bash 
          juliaup add 1.6
          ```
          To run code using a specific version, as shown below in the replication code, you may indicate a version using `+version` ie.

          ```bash
          julia +1.6 myfile.jl
          ```

          You will also need to add the Mimi model registry to your machine. On the command line (after installing Julia), Type `julia` and you will see the Julia interface appear. Then type `]` and the `pkg` indicator will appear. Next, type: 

          ```
          registry add https://github.com/mimiframework/MimiRegistry.git`
          ```

          You should now be ready to run the `GIVE` and the `Meta-Analysis` models, and create the inputs for `DSCIM` using the steps outlined in each of their READMEs. 

2. *R* is free and available for download [here](https://www.r-project.org/). The *RStudio* integrated development environment is useful for replication, it is free and available for download [here](https://www.rstudio.com/products/rstudio/). *R* is used to collect the estimates from each damage module and create [a table of unrounded annual SC-HFCs](EPA/output/schfc_annual.csv). 

3. *Anaconda* is free and available for download [here](https://www.anaconda.com/). Other distributions can be used, too, such as [miniconda](https://docs.conda.io/en/latest/miniconda.html), or [mamba](https://mamba.readthedocs.io/en/latest/). Regardless of the user's desired distribution, *conda* packages are used to perform estimation of the `DSCIM` damage module. 

4. Optional: *Github* is free and available for download [here](https://github.com/git-guides/install-git). *Github* is used to house this repository and by installing and using it to clone the repository one will simplify the replication procedure. However, a user could also simply download a zipped file version of this repository, unzip in the desired location, and follow the replication procedures outlined below.

# Getting Started
Begin by cloning or downloading a copy of this repository. This can be done by clicking on the green "code" button in this repository and following those instructions, or by navigating in the terminal via the command line to the desired location of the cloned repository and then typing: 

```
git clone https://github.com/USEPA/schfc
```

Alternatively, you can make a `fork` of this repository and work from the fork in the same way. This allows for development on the `fork` while preserving its relationship with this repository.

# Estimating the SC-HFCs
Estimation of the three damage modules and their SC-HFCs is outlined below. For convenience, this repository already includes the completed model runs (in each damage module's `output` subdirectory), the full distributions of their estimates (in each damage module's `output\full_distributions` subdirectory), and [the final table of the combined estimates](/EPA/output/schfc_annual.csv) of annual SC-HFCs.

Each damage module subdirectory has its own `README` file with instruction on how to run the models using the damage module.  

# Compiling SC-HFC Estimates and Producing the Annual Tables
This repository already includes all estimates from running the three damage modules outlined above, located in the `output` subdirectory under each module's folder. The combined final estimates (simple averages across the three damage modules) are also already included in this repository under the [EPA](EPA) directory [`EPA\output\schfc_annual.csv`](/EPA/output/schfc_annual.csv). A user can replicate this averaging and interpolation to recover the annual SC-HFCs by using the *R* code provided in the [EPA](EPA) directory. Begin by navigating to the [EPA](EPA) directory in the file explorer (or equivalent). Open the *R* project titled `EPA.Rproj`. Then, navigate to the [code subdirectory](EPA/code) and open `compile_schfcs.R`. All remaining steps are documented in the code. 

# Additional Information
DSCIM is a product of [The Climate Impact Lab](https://impactlab.org/) in collaboration with [The Rhodium Group](https://rhg.com/). Addional information on DSCIM, including additional functionality, can be found in the user manual ([CIL 2023](DSCIM/CIL_DSCIM_User_Manual.pdf)) and in the [README](DSCIM/README.md) within the [DSCIM](DSCIM) subdirectory.

Both the GIVE and Meta-Analysis estimates are performed using the [MimiGIVE](https://github.com/rffscghg/MimiGIVE.jl) model, published by [Rennert et al. (2022b)](https://www.nature.com/articles/s41586-022-05224-9) as a product of the [Social Cost of Carbon Initiative](https://www.rff.org/topics/scc/social-cost-carbon-initiative/), a collaborative effort led by [Resources for the Future](https://www.rff.org/) and the [Energy Resources Group](https://erg.berkeley.edu/) at the University of California Berkeley. Additional functionality within this model can be found in the [MimiGIVE](https://github.com/rffscghg/MimiGIVE.jl) repository.

# License
The software code contained within this repository is made available under the [MIT license](http://opensource.org/licenses/mit-license.php). Any data and figures are made available under the [Creative Commons Attribution 4.0](https://creativecommons.org/licenses/by/4.0/) license.

# Citations
Bauer, M.D. and G.D. Rudebusch. 2021. The rising cost of climate change: evidence from the bond market. _The Review of Economics and Statistics_.

Carleton, T., A. Jina, M. Delgado, M. Greenstone, T. Houser, S. Hsiang, A. Hultgren, R. Kopp, K. McCusker, I. Nath, J. Rising, A. Ashwin, H Seo, A. Viaene, J. Yaun, A. Zhang. 2022. Valuing the Global Mortality Consequences of Climate Change Accounting for Adaptation Costs and Benefits. _The Quarterly Journal of Economics._ 

Climate Impact Lab (CIL). 2023. Data-driven Spatial Climate Impact Model User Manual, Version 092023-EPA.

Howard, P., and T. Sterner. 2017. Few and Not So Far Between: A Meta-Analysis of Climate Damage Estimates. _Environmental and Resource Economics_.

Newell, R., W. Pizer, and B. Prest. 2022. A Discounting Rule for the Social Cost of Carbon. _Journal of the Association of Environmental and Resource Economists_.

Rennert, K., F. Errickson, B. Prest, L. Rennels, R. Newell, W. Pizer, C. Kingdon, J. Wingenroth, R. Cooke, B. Parthum, D. Smith, K. Cromar, D. Diaz, F. Moore, U. Müller, R. Plevin, A. Raftery, H. Ševčíková, H. Sheets, J. Stock, T. Tan, M. Watson, T. Wong, and D. Anthoff. 2022b. Comprehensive Evidence Implies a Higher Social Cost of CO2. _Nature_.

Rode, A., T. Carleton, M. Delgado, M. Greenstone, T. Houser, S. Hsiang, A. Hultgren, A. Jina, R.E. Kopp, K.E. McCusker, and I. Nath. 2021. Estimating a social cost of carbon for global energy consumption. _Nature_.
