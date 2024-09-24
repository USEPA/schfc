# The Greenhouse Gas Impact Value Estimator (GIVE)
Replicating the estimates from GIVE can be done by following the steps outlined here and assumes that the user has downloaded and installed *Julia*. Begin by opening a terminal and navigating via the command line to the location of the cloned repository. Then, navigate to the [code](GIVE/code) subdirectory by typing:

```
cd GIVE\code
```

The directory `GIVE\code` should be the current location of the terminal. This directory includes the replication script `estimate_schfcs.jl`. Run this file by typing: 

```
julia +1.6 estimate_schfcs.jl
```

## Modifying the Model
The code in `estimate_schfcs.jl` provides the user with the ability to replicate the SC-HFCs as estimated by the EPA. Interested users can modify this code, or the MimiGIVE model directly. Please see the [MimiGIVE repository](https://github.com/rffscghg/MimiGIVE.jl) for additional instructions and helpful guidance. 

# License
The software code contained within this repository is made available under the [MIT license](http://opensource.org/licenses/mit-license.php). Any data and figures are made available under the [Creative Commons Attribution 4.0](https://creativecommons.org/licenses/by/4.0/) license.

# Citations
Rennert, K., F. Errickson, B. Prest, L. Rennels, R. Newell, W. Pizer, C. Kingdon, J. Wingenroth, R. Cooke, B. Parthum, D. Smith, K. Cromar, D. Diaz, F. Moore, U. Müller, R. Plevin, A. Raftery, H. Ševčíková, H. Sheets, J. Stock, T. Tan, M. Watson, T. Wong, and D. Anthoff. 2022b. Comprehensive Evidence Implies a Higher Social Cost of CO2. _Nature_.