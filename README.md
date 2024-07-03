# bcm_math_anxiety
MATLAB scripts of bounded confidence model (BCM) of math anxiety

## Anxiety_model_time_series
Run one simulation of the BCM

## MonteCarlo_histogram
Run many simulations of the BCM. Output asymptotic anxiety data as histograms (percentage improved and mean final anxieties)

## single_param_sweep
Run Monte Carlo simulations of the BCM over a range of parameter values for any specified parameter. Outputs plot of percentage improved and mean final anxieties as a function of the swept parameter. Also outputs 3D histogram: each slice is a histogram of final anxiety levels.

## double_param_sweep
Run Monte Carlo simulations of BCM over range of both epsilon and gamma parameters. Outputs 3D plots of percentage improved and mean final anxieties

## Auxiliary files (needed for any of the scripts above)
BC_model_steps.m -> timestep BCM
f_interaction -> interaction function for peer interactions
groups_matrix -> creates adjacency matrix for randomly formed groups
groups_matrix_ordered -> creates adjacency matrix for homogeneously formed groups
