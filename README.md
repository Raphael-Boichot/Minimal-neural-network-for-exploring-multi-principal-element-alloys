# A minimal Neural Network for exploring multi-principal element alloys

A very minimal implementation of neural network on Matlab to fit mechanical properties of a multi-principal element alloy. The example given fits the Vickers hardness in the Al-Co-Cr-Fe-Ni-Ti-Mo. Experimental data used are extracted from [this database](https://github.com/CitrineInformatics/MPEA_dataset). The code used is inspired from this [other repository](https://github.com/Raphael-Boichot/Accelerated-exploration-of-multinary-systems).

This code was only made to be simple to understand and reuse in similar context.

## Minimal requirement
- Matlab 23.2.0.2485118 (R2023b) Update 6
- Parallel computing toolbox (optional)
- Statistics and Machine Learning Toolbox

## What does this code ?
- It extracts data from an Excel spreadsheet
- it creates a NN network with 4 hidden layers. Descriptor is the alloy composition in molar fraction and output is the Vickers hardness
- it searches for the best network using k-folding and modified R-square/RMSE to sort the best nets
- it plots the best fit in n-th dimension using Delaunay triangulation
- additionally you can create animated gifs with the experimental and predicted data

## Example of code output for hardness
![](/Figure.png)

## Main metrics during training over large batches
![](/Metrics.png)

The minimal of RMSE does not coincide with the best ajusted R², which is not trivial to explain as the fit is overall quite good. I suspect that a bunch of experimental data should be removed from the training data to improves the fit.

## Experimental hardness data in 7D plot (Delaunay triangulation)
![](/Experimental_animated.gif)

## Predicted hardness data in 7D plot (Delaunay triangulation)
![](/Predicted_animated.gif)

The advantage of Delaunay triangulation is that n dimensions mixtures are as easy to plot as 3D ones.

## Warning
This codes were made for fun. I decline any responsibility in the event of a nuclear power plant melt-down following the misuse of these codes.

## Aknowledgements
- Elise GAREL, Constellium, France, for showing that the coktail effect in HEA is probably bullshit, which is once again confirmed here.
- Adrien GUILLE and Marek BRAUN, Grenoble Institute of Technology, France, for translating the Python code of Elise Garel to Matlab, which I used to start here.
