# A minimal Neural Network for exploring multi-principal element alloys

A very minimal implementation of neural network on Matlab to fit mechanical properties of a multi-principal element alloy (or HEA for high entropy alloys). The example given fits the Vickers hardness in the Al-Co-Cr-Fe-Ni-Ti-Mo system. Experimental alloy data used are extracted from [this database](https://github.com/CitrineInformatics/MPEA_dataset) and the Vickers hardnesses for pure elements from [webelements](https://www.webelements.com/titanium/physics.html). The code used is strongly inspired from this [other repository](https://github.com/Raphael-Boichot/Accelerated-exploration-of-multinary-systems).

This code was only made to be simple to understand and reuse in a similar context (fitting data into a multinary). It outputs enough statistics to assess the quality of the results.

## Minimal requirement
- Matlab 23.2.0.2485118 (R2023b) Update 6
- Matlab Parallel computing toolbox (optional)
- Matlab Statistics and Machine Learning Toolbox

This code is probably more or less easily translatable to GNU Octave as similar libraries are available but I did not take the time to do it.

## What does this code ?
- It extracts data from an Excel spreadsheet;
- It creates a NN network with 4 hidden layers. Descriptor is the alloy composition in molar fraction and output is the Vickers hardness;
- It searches for the best network using k-folding and modified R-square/RMSE to sort the best nets among many runs starting fram randomized bias/gain configurations;
- It plots the best fit in n-th dimension using Delaunay triangulation;
- Additionally you can create animated gifs with the experimental and predicted data, the predicted error based on variance/covariance matrix and the actual modeling error based on residuals.

## Example of code output for hardness
![](/Codes/Figure.png)

The code output is minimal: a linear plot of experimental (actual) and predicted hardness, the quantile-quantile plot of the residuals versus the theoretical quantile values from a normal distribution (If the distribution of residuals is normal, then the data plot appears linear), the experimental and the predicted datasets in 7D by Delaunay triangulation.

## Main metrics after a large number of independant trainings
![](/Codes//Metrics.png)

The metrics calculated over large simulation batches shows the interest of running dozens of independant NN trainings and keep the best network (NN seeding is randomized and [k-folding](https://en.wikipedia.org/wiki/Cross-validation_(statistics)) with pool randomization is used here). You may be very lucky to find a good network with only one training !

## Experimental hardness data in 7D plot (Delaunay triangulation)
![](/Codes//Experimental_animated.gif)

This graph exactly shows the issue with collecting experimental data from different literature sources (may them be reliable): the experimental compositions do not follow any pattern and the experimental error is never indicated. This why with Elise Garel we chose a [completely different approach](https://www.sciencedirect.com/science/article/pii/S0264127523004707) to tackle multinary exploration, using mixture design (a kind of space filling design) to place the compositions in an optimal pattern.

## Predicted hardness data in 7D plot (Delaunay triangulation)
![](/Codes//Predicted_animated.gif)

## Predicted hardness rescaled between 1000 and 1600 HV
![](/Codes//Predicted_animated_rescaled.gif)

Well, molybdenum rich alloys are hard as expected (but the Mo-Cr-Co ternary is surprisingly not the hardest) and there is probably something to dig in the Ti-Cr-Co ternary. As the prediction error is maximal near the vertices, a good strategy would be to complete these data with Vickers hardness measured along the Mo-X and Co-X binaries for example, then retry a training, then refine the area of interest, make new measurements and so on until convergence to an optimized alloy. This should be the basis of experimental HEA exploration, sadly not that often applied in 2024.

## Prediction error based variance/covariance matrix
![](/Codes//Error_animated.gif)

This plot shows the predicted modeling error based on data distribution. It does only care on the distance between the predicted point and the whole experimental dataset. It is completely model-independant. The conclusion is obvious: the farther from the experimental points, the bigger the prediction error will be. The vertices having only few points, the error is maximal here.

## Actual Neural Network residuals
![](/Codes//Residuals_animated.gif)

This represents the real prediction error based on the difference between experimental points and their predicted values. It shows possible statistic outliers but also localized lack of fit. Without any further indication on experimental errors, hard to tell if outliers must be removed or if there is an interest to complexify the network (with the risk of overfitting data).

## Kind warning
These codes were essentially made for fun and for training myself to study ANOVA resulting from NN fitting compared to other fitting methods like RSM for example (NN _per se_ are not interesting me that much due to their "black box" aspect). I decline any responsibility in the event of a nuclear power plant melt-down following the misuse of these codes. Why not a Python code ? Because the Python version is [yet here](https://github.com/Raphael-Boichot/Accelerated-exploration-of-multinary-systems).

## Aknowledgements
- Elise GAREL, Constellium, France, for the Matlab and Python codes used to start this repository.
- Adrien GUILLE and Marek BRAUN, Grenoble Institute of Technology, France, for translating some of the Python code from Elise Garel to Matlab and showing that similar results could be obtained in a full Matlab implementation.
